[ModuleInit]
public Saga.BackendTypes backend_init (GLib.TypeModule type_module) {
	return {typeof (Saga.Local.JobService)};
}

namespace Saga.Local
{
	public class Job : Saga.Job
	{
		private uint8                   _id[16];
		private Session                 _session;
		private JobDescription          _job_description;
		private GLib.SubprocessLauncher _subprocess_launcher;
		private string[]                _args;
		private GLib.Subprocess?        _subprocess = null;

		public Job (Session session, SubprocessLauncher launcher, string[] args, JobDescription jd)
		{
			GLib.Object (job_id: jd.get_id (), created: new DateTime.now_utc ());
			_subprocess_launcher = launcher;
			_args                = args;
			_job_description     = jd;
		}

		construct
		{
			UUID.generate (_id);
		}

		public override string get_id ()
		{
			char @out[37];
			UUID.unparse (_id, @out);
			return (string) @out;
		}

		public override Session get_session ()
		{
			return _session;
		}

		public override string[] list_metrics ()
		{
			return {};
		}

		public override Metric get_metric (string name) throws Error.NOT_IMPLEMENTED
		{
			throw new Error.NOT_IMPLEMENTED ("The metric '%s' has not been implemented.", name);
		}

		public override void run () throws Error.NO_SUCCESS
		{
			try
			{
				_subprocess = _subprocess_launcher.spawnv (_args);
				started     = new GLib.DateTime.now_utc ();
				job_state (JobState.RUNNING);
				if (_job_description.wall_time_limit != null) {
					Timeout.add ((uint) (_job_description.wall_time_limit / TimeSpan.MILLISECOND), () => {
						_subprocess.send_signal (ProcessSignal.KILL);
						return false;
					});
				}
			}
			catch (GLib.Error err)
			{
				throw new Error.NO_SUCCESS (err.message);
			}
		}

		public override void cancel (double timeout = 0.0)
		{
			_subprocess.force_exit ();
		}

		private bool _waiting = false;

		public override void wait (double timeout = 0.0) throws Error.NO_SUCCESS
		{
			while (_subprocess == null)
			{
				GLib.Thread.@yield ();
			}

			try
			{
				_subprocess.wait ();
				_waiting = true;
			}
			catch (GLib.Error err)
			{
				throw new Error.NO_SUCCESS (err.message);
			}

			if (_subprocess.get_if_signaled ())
			{
				term_sig  = (GLib.ProcessSignal) _subprocess.get_term_sig ();
			}

			exit_code = _subprocess.get_exit_status ();
			finished  = new GLib.DateTime.now_utc ();
			job_state (exit_code == 0 ? JobState.DONE : JobState.FAILED);
		}

		public override async void wait_async (double timeout = 0.0, int priority = GLib.Priority.DEFAULT) throws Error.NO_SUCCESS
		{
			while (_subprocess == null)
			{
				GLib.Timeout.add (500, wait_async.callback);
				yield;
			}

			try
			{
				_waiting = true;
				yield _subprocess.wait_async ();

				if (_subprocess.get_if_signaled ())
				{
					term_sig  = (GLib.ProcessSignal) _subprocess.get_term_sig ();
				}

				exit_code = _subprocess.get_status ();
				finished  = new GLib.DateTime.now_utc ();
				job_state (exit_code == 0 ? JobState.DONE : JobState.FAILED);
			}
			catch (GLib.Error err)
			{
				throw new Error.NO_SUCCESS (err.message);
			}
		}

		public override TaskState get_state ()
		{
			if (_subprocess == null)
			{
				return TaskState.NEW;
			}
			else if (_waiting && _subprocess.get_if_exited ())
			{
				return _subprocess.get_successful () ? TaskState.DONE : TaskState.FAILED;
			}
			else
			{
				return TaskState.RUNNING;
			}
		}

		public override void permissions_allow (string id, Permission perm) throws Error.NOT_IMPLEMENTED
		{
			throw new Error.NOT_IMPLEMENTED ("");
		}

		public override void permissions_deny (string id, Permission perm) throws Error.NOT_IMPLEMENTED
		{
			throw new Error.NOT_IMPLEMENTED ("");
		}

		public override bool permissions_check (string id, Permission perm) throws Error.NOT_IMPLEMENTED
		{
			throw new Error.NOT_IMPLEMENTED ("");
		}

		public override string get_group () throws Error.NOT_IMPLEMENTED
		{
			throw new Error.NOT_IMPLEMENTED ("");
		}

		public override string get_owner () throws Error.NOT_IMPLEMENTED
		{
			throw new Error.NOT_IMPLEMENTED ("");
		}

		public override unowned JobDescription get_job_description ()
		{
			return _job_description;
		}

		public override GLib.OutputStream get_stdin () throws Error.INCORRECT_STATE
		{
			if (!_job_description.interactive)
				throw new Error.INCORRECT_STATE ("Only interactive job have attached standard input.");
			return _subprocess.get_stdin_pipe ();
		}

		public override GLib.InputStream get_stdout () throws Error.INCORRECT_STATE
		{
			if (!_job_description.interactive)
				throw new Error.INCORRECT_STATE ("Only interactive job have attached standard output.");
			return _subprocess.get_stdout_pipe ();
		}

		public override GLib.InputStream get_stderr () throws Error.INCORRECT_STATE
		{
			if (!_job_description.interactive)
				throw new Error.INCORRECT_STATE ("Only interactive job have attached standard error.");
			return _subprocess.get_stderr_pipe ();
		}

		public override void suspend () throws Error
		{
			@signal (GLib.ProcessSignal.STOP);
		}

		public override void resume () throws Error
		{
			@signal (GLib.ProcessSignal.CONT);
		}

		public override void checkpoint ()
		{
			// TODO
		}

		public override void migrate (owned JobDescription jd) throws Error.NOT_IMPLEMENTED
		{
			throw new Error.NOT_IMPLEMENTED ("");
		}

		public override void @signal (GLib.ProcessSignal signum)
		{
			_subprocess.send_signal (signum);
		}
	}

	public class JobService : Saga.JobService
	{
		private HashTable<string, Job> _jobs = new HashTable<string, Job> (GLib.str_hash, GLib.str_equal);

		public override Saga.Job create_job (owned JobDescription jd) throws Error
		{
			if (jd.working_directory != null)
			{
				if (DirUtils.create_with_parents (jd.working_directory, 0755) == -1)
				{
					throw new Error.NO_SUCCESS ("Could not create working directory '%s'.", jd.working_directory);
				}
			}

			SubprocessLauncher launcher;

			if (jd.interactive)
			{
				launcher = new GLib.SubprocessLauncher (GLib.SubprocessFlags.STDIN_PIPE  |
				                                        GLib.SubprocessFlags.STDOUT_PIPE |
				                                        GLib.SubprocessFlags.STDERR_PIPE);
			}
			else
			{
				launcher = new GLib.SubprocessLauncher (GLib.SubprocessFlags.NONE);
			}

			string[] args = {jd.executable};

			foreach (var arg in jd.arguments)
				args += arg;

#if VALA_0_34
			launcher.set_environ (jd.environment);
#else
			// cannot use 'set_environ' here, see https://bugzilla.gnome.org/show_bug.cgi?id=771307
			if (jd.environment.length > 0)
				critical ("Cannot use 'GLib.SubprocessLauncher.set_environ', the fix was introduced in Vala 0.34.");
#endif

			var wd = File.new_for_path (jd.working_directory);
			if (jd.input != null)
				launcher.set_stdin_file_path (wd.resolve_relative_path (jd.input).get_path ());
			if (jd.output != null)
				launcher.set_stdout_file_path (wd.resolve_relative_path (jd.output).get_path ());
			if (jd.error != null)
				launcher.set_stderr_file_path (wd.resolve_relative_path (jd.error).get_path ());

			launcher.set_cwd (jd.working_directory);

			// TODO: 'file_transfer'

			// TODO: 'cleanup'

			launcher.set_child_setup (() => {
				if (jd.total_cpu_time != null)
				{
					Linux.RLimit rlimit_cpu;
					Linux.getrlimit (Linux.RLIMIT_CPU, out rlimit_cpu);
					rlimit_cpu.rlim_cur = int64.min (jd.total_cpu_time / TimeSpan.SECOND, rlimit_cpu.rlim_max);
					if (Linux.setrlimit (Linux.RLIMIT_CPU, rlimit_cpu) == -1)
					{
						critical (strerror (errno));
					}
				}

				if (jd.total_physical_memory != null)
				{
					Linux.RLimit rlimit_as;
					Linux.getrlimit (Linux.RLIMIT_AS, out rlimit_as);
					rlimit_as.rlim_cur = int64.min (jd.total_physical_memory, rlimit_as.rlim_max);
					if (Linux.setrlimit (Linux.RLIMIT_AS, rlimit_as) == -1)
					{
						critical (strerror (errno));
					}
				}
			});

			var job = new Job (get_session (), launcher, args, jd);

			_jobs.insert (job.job_id, job);

			// cleanup done, failed or canceled jobs
			job.job_state.connect ((state) => {
				if (state > 2 && state < 6)
					_jobs.remove (job.job_id);
			});

			return job;
		}

		public override Saga.Job get_job (string id) throws Error.DOES_NOT_EXIST
		{
			if (_jobs.contains (id))
			{
				return _jobs.lookup (id);
			}
			else
			{
				throw new Error.DOES_NOT_EXIST ("Could not fetch the job '%s' from the local backend.", id);
			}
		}

		public override string[] list ()
		{
			return _jobs.get_keys_as_array ();
		}

		public override Saga.Job get_self () throws Error.NO_SUCCESS
		{
			// TODO: return Job.from_subprocess (this);
			throw new Error.NO_SUCCESS ("The 'local' backend is not managed using a job.");
		}
	}
}
