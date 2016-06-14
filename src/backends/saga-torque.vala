[ModuleInit]
public Type backend_init (TypeModule type_module)
{
	return typeof (Saga.TORQUE.JobService);
}

namespace Saga.TORQUE
{
	public class Job : Saga.Job
	{
		private uint8 _id[16];

		private JobDescription _job_description;

		private Subprocess _qsub_subprocess;

		public Job (string job_id, JobDescription job_description, Subprocess qsub_subprocess)
		{
			GLib.Object (job_id: job_id);
			UUID.generate (_id);
			_job_description = job_description;
			_qsub_subprocess = qsub_subprocess;
		}

		public override string get_id ()
		{
			return (string) _id;
		}

		public override Session get_session () throws Error.DOES_NOT_EXIST
		{
			throw new Error.DOES_NOT_EXIST ("");
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

		public override JobDescription get_job_description ()
		{
			return _job_description;
		}

		public override GLib.OutputStream get_stdin ()
		{
			return _qsub_subprocess.get_stdin_pipe ();
		}

		public override GLib.InputStream get_stdout ()
		{
			return _qsub_subprocess.get_stdout_pipe ();
		}

		public override GLib.InputStream get_stderr ()
		{
			return _qsub_subprocess.get_stderr_pipe ();
		}

		public override void suspend () throws Error.NOT_IMPLEMENTED
		{
			throw new Error.NOT_IMPLEMENTED ("");
		}

		public override void resume () throws Error.NOT_IMPLEMENTED
		{
			throw new Error.NOT_IMPLEMENTED ("");
		}

		public override void checkpoint () throws Error.NOT_IMPLEMENTED
		{
			// TODO: use 'qchkpt'
			throw new Error.NOT_IMPLEMENTED ("");
		}

		public override void migrate (JobDescription jd) throws Error.NOT_IMPLEMENTED
		{
			// TODO: use 'qmove'
			throw new Error.NOT_IMPLEMENTED ("");
		}

		public override void @signal (GLib.ProcessSignal signum) throws Error.NOT_IMPLEMENTED
		{
			// TODO: use 'qsig'
			throw new Error.NOT_IMPLEMENTED ("");
		}
	}

	public class JobService : Saga.JobService
	{
		private static GLib.Subprocess qsub_from_job_description (JobDescription jd) throws GLib.Error
		{
			string[] qsub_args = {"qsub", "-c", "enabled"};

			if (jd.arguments.length > 0) {
				qsub_args += "-F";
				// TODO: quote each arguments with GLib.Shell.quote
				qsub_args += string.joinv (" ", jd.arguments);
			}

			// TODO: 'spmd_variation'

			var resource_list = new StringBuilder ();

			resource_list.append_printf ("nodes=%d:ppn=%d", jd.total_cpu_count, jd.processes_per_host);

			if (jd.threads_per_process > 1)
				warning ("TORQUE backend does not support 'threads_per_process'.");

			if (jd.environment.length > 0)
			{
				qsub_args += "-v";
				qsub_args += string.joinv (",", jd.environment);
			}

			qsub_args += "-d";
			qsub_args += jd.working_directory;

			if (jd.interactive)
			{
				qsub_args += "-I";
			}
			else
			{
				if (jd.input != null)
				{
					warning ("TORQUE backend does not support 'input'.");
				}

				if (jd.output != null)
				{
					qsub_args += "-o";
					qsub_args += jd.output;
				}

				if (jd.error != null)
				{
					qsub_args += "-e";
					qsub_args += jd.error;
				}
			}

			string[] stagein  = {};
			string[] stageout = {};

			foreach (var ft in jd.file_transfer) {
				switch (ft.operator) {
					case ">":
					case ">>":
						stagein += ft.local_file + ":" + ft.remote_file;
						break;
					case "<":
					case "<<":
						stageout += ft.local_file + ":" + ft.remote_file;
						break;
					default:
						warning ("Unknown operator '%s' for file transfer, the transfer was ignored.", ft.operator);
						break;
				}
			}

			if (jd.cleanup != null)
			{
				if (jd.cleanup)
				{
					qsub_args += "-k";
					qsub_args += "n";
				}
				else
				{
					qsub_args += "-k";
					qsub_args += "oe";
				}
			}

			if (stagein.length > 0)
			{
				qsub_args += "-W";
				qsub_args += string.joinv (",", stagein);
			}

			if (stageout.length > 0)
			{
				qsub_args += "-W";
				qsub_args += string.joinv (",", stageout);
			}

			if (jd.job_start_time != null)
			{
				qsub_args += "-a";
				qsub_args += jd.job_start_time.format ("%Y%%m%d%H%M.%S");
			}

			if (jd.wall_time_limit != null)
				resource_list.append_printf ("walltime=%d", jd.wall_time_limit);

			if (jd.total_cpu_time != null)
				resource_list.append_printf ("cput=%d", jd.total_cpu_time);

			if (jd.total_physical_memory != null)
				resource_list.append_printf ("mem=%dmb", jd.total_physical_memory);

			if (jd.cpu_architecture != null)
				resource_list.append_printf ("arch=%s", jd.cpu_architecture);

			if (jd.operating_system_type != null)
				resource_list.append_printf ("opsys=%s", jd.operating_system_type);

			if (resource_list.len > 0)
			{
				qsub_args += "-l";
				qsub_args += resource_list.str;
			}

			// TODO: 'candidate_hosts'

			if (jd.queue != null)
			{
				qsub_args += "-q";
				qsub_args += jd.queue;
			}

			if (jd.job_project != null)
			{
				qsub_args += "-N";
				qsub_args += jd.job_project;
			}

			string[] user_list = {};
			foreach (var jc in jd.job_contact)
			{
				if (jc.scheme == "mailto")
				{
					user_list += jc.userinfo + "@" + jc.host;
				}
			}

			if (user_list.length > 0)
			{
				qsub_args += "-M";
				qsub_args += string.joinv (",", user_list);
			}

			qsub_args += jd.executable;

			return new Subprocess.newv (qsub_args,
			                            jd.interactive ? SubprocessFlags.STDIN_PIPE  |
			                                             SubprocessFlags.STDOUT_PIPE |
			                                             SubprocessFlags.STDERR_PIPE : SubprocessFlags.STDOUT_PIPE);
		}

		public override Saga.Job create_job (JobDescription jd) throws Error.NO_SUCCESS
		{
			try
			{
				var qsub = qsub_from_job_description (jd);

				// TODO: job_id if interactive?

				string stdout_buf;
				string stderr_buf;
				qsub.communicate_utf8 (null, null, out stdout_buf, out stderr_buf);

				return new Job (stdout_buf, jd, qsub);
			}
			catch (GLib.Error err)
			{
				throw new Error.NO_SUCCESS (err.message);
			}
		}

		public override async Saga.Job create_job_async (JobDescription jd,
		                                            int            priority = GLib.Priority.DEFAULT) throws Error.NO_SUCCESS
		{
			try
			{
				var qsub = qsub_from_job_description (jd);

				string stdout_buf;
				string stderr_buf;
				yield qsub.communicate_utf8_async (null, null, out stdout_buf, out stderr_buf);

				return new Job (stdout_buf, jd, qsub);
			}
			catch (GLib.Error err)
			{
				throw new Error.NO_SUCCESS (err.message);
			}
		}

		public override string[] list () throws Error.NOT_IMPLEMENTED, Error.NO_SUCCESS
		{
			try
			{
				var qstat = new Subprocess (SubprocessFlags.STDOUT_PIPE, "qstat", "-x");

				string stdout_buf;
				string stderr_buf;
				if (qstat.communicate_utf8 (null, null, out stdout_buf, out stderr_buf))
				{
					// TODO: decode xml..
					throw new Error.NOT_IMPLEMENTED ("");
				}
				else
				{
					throw new Error.NO_SUCCESS ("Could not retreive the job identifiers");
				}
			}
			catch (GLib.Error err)
			{
				throw new Error.NO_SUCCESS (err.message);
			}
		}

		public override Saga.Job get_job (string id) throws Error.NOT_IMPLEMENTED
		{
			// TODO: 'qstat'
			throw new Error.NOT_IMPLEMENTED ("");
		}

		public override Saga.Job get_self () throws Error.NOT_IMPLEMENTED
		{
			throw new Error.NOT_IMPLEMENTED ("The 'TORQUE' backend is not managed using a job.");
		}
	}
}
