[ModuleInit]
public Saga.BackendTypes backend_init (GLib.TypeModule type_module)
{
	return {typeof (Saga.TORQUE.JobService)};
}

namespace Saga.TORQUE
{
	// TODO: use extern from the build
	private const string QALTER = "qalter";
	private const string QCHKPT = "qchkpt";
	private const string QDEL   = "qdel";
	private const string QHOLD  = "qhold";
	private const string QRLS   = "qrls";
	private const string QSIG   = "qsig";
	private const string QSTAT  = "qstat";
	private const string QSUB   = "qsub";

	private const string SH     = "/usr/bin/sh";

	private string[] qsub_args_from_job_description (URL service_url, JobDescription jd) throws Error.NO_SUCCESS
	{
		string[] args = {QSUB};

		// perform manual checkpoints
		args += "-c";
		args += "enabled";

		if (jd.spmd_variation != null)
		{
			warning ("TORQUE backend does not support 'spmd_variation'.");
		}

		string[] resource_list = {};

		resource_list += "nodes=%d:ppn=%d".printf (jd.total_cpu_count, jd.processes_per_host);

		if (jd.threads_per_process > 1)
			warning ("TORQUE backend does not support 'threads_per_process'.");

		if (jd.environment.length > 0)
		{
			args += "-v";
			args += string.joinv (",", jd.environment);
		}

		args += "-d";
		args += jd.working_directory;

		if (jd.interactive)
		{
			args += "-I";
			args += "-x";
		}
		else
		{
			if (jd.input != null)
			{
				warning ("TORQUE backend does not support 'input'.");
			}

			if (jd.output != null)
			{
				args += "-o";
				args += jd.output;
			}

			if (jd.error != null)
			{
				args += "-e";
				args += jd.error;
			}
		}

		string[] stagein  = {};
		string[] stageout = {};

		foreach (var ft in jd.file_transfer) {
			if (!ft.local_file.contains ("@"))
			{
				throw new Error.NO_SUCCESS ("Local files must specify a host in the 'local_file@hostname' format.");
			}
			switch (ft.operator) {
				case ">":
				case ">>":
					stagein += "%s:%s".printf (ft.local_file, ft.remote_file);
					break;
				case "<":
				case "<<":
					stageout += "%s:%s".printf (ft.local_file, ft.remote_file);
					break;
				default:
					warning ("Unknown operator '%s' for file transfer, the transfer was ignored.", ft.operator);
					break;
			}
		}

		if (stagein.length > 0)
		{
			args += "-W";
			args += "stagein=%s".printf (string.joinv (",", stagein));
		}

		if (stageout.length > 0)
		{
			args += "-W";
			args += "stageout=%s".printf (string.joinv (",", stageout));
		}

		if (jd.cleanup != null)
		{
			if (jd.cleanup)
			{
				args += "-k";
				args += "n";
			}
			else
			{
				args += "-k";
				args += "oe";
			}
		}

		if (jd.job_start_time != null)
		{
			args += "-a";
			args += jd.job_start_time.format ("%Y%%m%d%H%M.%S");
		}

		if (jd.wall_time_limit != null)
		{
			resource_list += ("walltime=%" + int64.FORMAT).printf (jd.wall_time_limit / TimeSpan.SECOND);
		}

		if (jd.total_cpu_time != null)
			resource_list += ("cput=%" + int64.FORMAT).printf (jd.total_cpu_time / TimeSpan.SECOND);

		if (jd.total_physical_memory != null)
			resource_list += "mem=%dmb".printf (jd.total_physical_memory);

		if (jd.cpu_architecture != null)
			resource_list += "arch=%s".printf (jd.cpu_architecture);

		if (jd.operating_system_type != null)
			resource_list += "opsys=%s".printf (jd.operating_system_type);

		if (resource_list.length > 0)
		{
			args += "-l";
			args += string.joinv (",", resource_list);
		}

		// TODO: 'candidate_hosts'
		if (jd.candidate_hosts.length > 0)
			warning ("The 'candidate_hosts' option is not implemented and was ignored.");

		args += "-q";
		if (jd.queue != null)
		{
			args += "%s@%s".printf (jd.queue, service_url.host);
		}
		else
		{
			args += "@%s".printf (service_url.host);
		}

		if (jd.job_project != null)
		{
			if (/^[[:alpha:]][[:graph:]]{0,14}/.match (jd.job_project))
			{
				args += "-N";
				args += jd.job_project;
			}
			else
			{
				throw new Error.NO_SUCCESS ("The job name must be at most 15 characters in length, must start with an alphabetic character and be composed of printable characters '%s' was provided.",
				                            jd.job_project);
			}
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
			args += "-M";
			args += string.joinv (",", user_list);
		}

		args += "-";

		return args;
	}

	private string[] qalter_args_from_job_description (URL service_url, JobDescription jd, string job_id) throws Error.NO_SUCCESS
	{
		string[] args = {QALTER};

		string[] resource_list = {};

		resource_list += "nodes=%d:ppn=%d".printf (jd.total_cpu_count, jd.processes_per_host);

		if (jd.threads_per_process > 1)
			warning ("TORQUE backend does not support 'threads_per_process'.");

		if (jd.input != null)
		{
			warning ("TORQUE backend does not support 'input'.");
		}

		if (jd.output != null)
		{
			args += "-o";
			args += jd.output;
		}

		if (jd.error != null)
		{
			args += "-e";
			args += jd.error;
		}

		string[] stagein  = {};
		string[] stageout = {};

		foreach (var ft in jd.file_transfer) {
			if (!ft.local_file.contains ("@"))
			{
				throw new Error.NO_SUCCESS ("Local files must specify a host in the 'local_file@hostname' format.");
			}
			switch (ft.operator) {
				case ">":
				case ">>":
					stagein += "%s:%s".printf (ft.local_file, ft.remote_file);
					break;
				case "<":
				case "<<":
					stageout += "%s:%s".printf (ft.local_file, ft.remote_file);
					break;
				default:
					warning ("Unknown operator '%s' for file transfer, the transfer was ignored.", ft.operator);
					break;
			}
		}

		if (stagein.length > 0)
		{
			args += "-W";
			args += "stagein=%s".printf (string.joinv (",", stagein));
		}

		if (stageout.length > 0)
		{
			args += "-W";
			args += "stageout=%s".printf (string.joinv (",", stageout));
		}

		if (jd.cleanup != null)
		{
			if (jd.cleanup)
			{
				args += "-k";
				args += "n";
			}
			else
			{
				args += "-k";
				args += "oe";
			}
		}

		if (jd.job_start_time != null)
		{
			args += "-a";
			args += jd.job_start_time.format ("%Y%%m%d%H%M.%S");
		}


		if (jd.wall_time_limit != null)
		{
			resource_list += ("walltime=%" + int64.FORMAT).printf (jd.wall_time_limit / TimeSpan.SECOND);
		}

		if (jd.total_cpu_time != null)
			resource_list += ("cput=%" + int64.FORMAT).printf (jd.total_cpu_time / TimeSpan.SECOND);

		if (jd.total_physical_memory != null)
			resource_list += "mem=%dmb".printf (jd.total_physical_memory);

		if (jd.cpu_architecture != null)
			resource_list += "arch=%s".printf (jd.cpu_architecture);

		if (jd.operating_system_type != null)
			resource_list += "opsys=%s".printf (jd.operating_system_type);

		if (resource_list.length > 0)
		{
			args += "-l";
			args += string.joinv (",", resource_list);
		}

		// TODO: 'candidate_hosts'
		if (jd.candidate_hosts.length > 0)
			warning ("The 'candidate_hosts' option is not implemented and was ignored.");

		if (jd.job_project != null)
		{
			args += "-N";
			args += jd.job_project;
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
			args += "-M";
			args += string.joinv (",", user_list);
		}

		args += "%s@%s".printf (job_id, service_url.host);

		return args;
	}

	private static double parse_size_literal (string mu)
	{
		if (mu.length < 2)
		{
			return double.NAN;
		}
		switch (mu[-2])
		{
			case 't':
				return 1099511627776 * uint64.parse (mu.slice (0, mu.length - 2));
			case 'g':
				return 1073741824 * uint64.parse (mu.slice (0, mu.length - 2));
			case 'm':
				return 1048576 * uint64.parse (mu.slice (0, mu.length - 2));
			case 'k':
				return 1024 * uint64.parse (mu.slice (0, mu.length - 2));
			default:
				return uint64.parse (mu.slice (0, mu.length - 1));
		}
	}

	public class Job : Saga.Job
	{
		private uint8 _id[16];

		private Session _session;

		private JobDescription _job_description;

		// states used to determine if we trigger metrics again
		private JobState? last_job_state = null;
		private string?   last_job_state_detail = null;

		public Job (Session session, string job_id, URL service_url, DateTime created, JobDescription job_description)
		{
			GLib.Object (job_id: job_id, service_url: service_url, created: created);
			_session         = session;
			_job_description = job_description;
		}

		private OutputStream? _stdin  = null;
		private InputStream?  _stdout = null;
		private InputStream?  _stderr = null;

		public Job.interactive (Session        session,
		                        string         job_id,
		                        URL            service_url,
		                        JobDescription job_description,
		                        OutputStream   stdin,
		                        InputStream    stdout,
		                        InputStream    stderr)
			requires (job_description.interactive)
		{
			this (session, job_id, service_url, new DateTime.now_utc (), job_description);
			_stdin  = stdin;
			_stdout = stdout;
			_stderr = stderr;
		}

		public Job.from_gxml_node (Session session, URL service_url, GXml.Node job_node) throws Error
		{
			var job_description = new JobDescription ();

			if (job_node.@get ("Variable_List") != null)
			{
				var env = job_node.@get ("Variable_List").@value.split (",");
				job_description.environment       = env;
				// careful here, 'PBS_O_INITDIR' is set to '-d' and defaults to
				// '$HOME', unlike 'PBS_O_WORKDIR' which is set only if '-d' is given
				job_description.working_directory = Environ.get_variable (env, "PBS_O_INITDIR");
			}

			job_description.total_cpu_count = int.parse (job_node.@get ("Resource_List").@get ("nodect").@value);

			var nodes = job_node.@get ("Resource_List").@get ("nodes").@value;
			// TODO: happy parsing..
			foreach (var node in nodes.split ("+"))
			{

			}

			job_description.wall_time_limit = int64.parse (job_node.@get ("Resource_List").@get ("walltime").@value) * TimeSpan.SECOND;
			job_description.output          = job_node.@get ("Output_Path").@value;
			job_description.error           = job_node.@get ("Error_Path").@value;
			job_description.cleanup         = job_node.@get ("Keep_Files").@value == "n";
			if (job_node.@get ("start_time") != null) {
				job_description.job_start_time  = new GLib.DateTime.from_unix_utc (int.parse (job_node.@get ("start_time").@value));
			}
			job_description.queue           = job_node.@get ("queue").@value;
			job_description.job_project     = job_node.@get ("Job_Name").@value;

			if (job_node.@get ("Mail_Users") != null)
			{
				URL[] job_contact = {};
				foreach (var mail_user in job_node.@get ("Mail_Users").@value.split (","))
				{
					job_contact += new URL ("mailto:%s".printf (mail_user));
				}
				job_description.job_contact = job_contact;
			}

			var _created = new DateTime.from_unix_utc (int64.parse (job_node.@get ("ctime").@value));

			this (session, job_node.@get ("Job_Id").@value, service_url, _created, job_description);
			update_from_gxml_node (job_node);
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
			return {
				"job.state",
				"job.state_detail",
				"job.signal",
				"job.cpu_time",
				"job.memory_use",
				"job.vmemory_use",
				"job.performance"
			};
		}

		public override Metric get_metric (string name) throws Error.NOT_IMPLEMENTED
		{
			switch (name)
			{
				case "job.state":
					return new Metric ("job.state", "", "", "", (last_job_state ?? JobState.NEW).to_string ().substring (15));
				case "job.state_detail":
					return new Metric ("job.state", "", "", "", last_job_state_detail ?? (last_job_state ?? JobState.NEW).to_string ());
				default:
					throw new Error.NOT_IMPLEMENTED ("The metric '%s' has not been implemented.", name);
			}
		}

		public override void run () throws Error
		{
			resume ();
		}

		public override async void run_async (int priority = GLib.Priority.DEFAULT) throws Error
		{
			yield resume_async (priority);
		}

		public override void cancel (double timeout = 0.0) throws Error.NO_SUCCESS
		{
			try
			{
				var qdel = new GLib.Subprocess.newv ({QDEL, "-b", "%d".printf ((int) timeout), "%s@%s".printf (job_id, service_url.host)},
				                                     GLib.SubprocessFlags.NONE);
				qdel.wait_check ();
			}
			catch (GLib.Error err)
			{
				throw new Error.NO_SUCCESS (err.message);
			}
		}

		public override void wait (double timeout = 0.0) throws Error
		{
			do
			{
				Thread.@yield ();
			}
			while (get_state () < 3);
		}

		public override async void wait_async (double timeout = 0.0, int priority = GLib.Priority.DEFAULT) throws Error
		{
			do
			{
				Timeout.add_seconds (5, wait_async.callback);
				yield;
			}
			while ((yield get_state_async ()) < 3);
		}

		public override TaskState get_state () throws Error.NO_SUCCESS
		{
			string stdout_buf;
			string stderr_buf;
			try
			{
				var qstat = new GLib.Subprocess.newv ({QSTAT, "-x", "%s@%s".printf (job_id, service_url.host)},
				                                      SubprocessFlags.STDOUT_PIPE);
				qstat.communicate_utf8 (null, null, out stdout_buf, out stderr_buf);
				GLib.Process.check_exit_status (qstat.get_exit_status ());
			}
			catch (GLib.Error err)
			{
				throw new Error.NO_SUCCESS (err.message);
			}

			GXml.GDocument doc;
			try
			{
				doc = new GXml.GDocument.from_string (stdout_buf);
			}
			catch (GLib.Error err)
			{
				throw new Error.NO_SUCCESS (err.message);
			}

			var data = doc.children.first ();

			if (data.children.is_empty)
			{
				throw new Error.NO_SUCCESS ("Could not retreive the state of task '%s' from the TORQUE backend.", job_id);
			}

			update_from_gxml_node (data.children.first ());

			switch (data.children.first ().@get ("job_state").@value)
			{
				case "H":
				case "Q":
				case "T":
				case "W":
					return TaskState.NEW;
				case "R":
				case "S":
					return TaskState.RUNNING;
				case "C":
				case "E":
					return exit_code == 0 ? TaskState.DONE : TaskState.FAILED;
				default:
					throw new Error.NO_SUCCESS ("Unexpected value for 'job_state'.");
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

		public override GLib.OutputStream get_stdin () throws Error.INCORRECT_STATE, Error.DOES_NOT_EXIST
		{
			if (!_job_description.interactive)
				throw new Error.INCORRECT_STATE ("Only interactive job have attached standard input.");
			if (_stdin == null)
				throw new Error.DOES_NOT_EXIST ("The standard input is not available.");
			return _stdin;
		}

		public override GLib.InputStream get_stdout () throws Error.INCORRECT_STATE, Error.DOES_NOT_EXIST
		{
			if (!_job_description.interactive)
				throw new Error.INCORRECT_STATE ("Only interactive job have attached standard output.");
			if (_stdout == null)
				throw new Error.DOES_NOT_EXIST ("The standard output is not available.");
			return _stdout;
		}

		public override GLib.InputStream get_stderr () throws Error.INCORRECT_STATE, Error.DOES_NOT_EXIST
		{
			if (!_job_description.interactive)
				throw new Error.INCORRECT_STATE ("Only interactive job have attached standard error.");
			if (_stderr == null)
				throw new Error.DOES_NOT_EXIST ("The standard error is not available.");
			return _stderr;
		}

		public override void suspend () throws Error.NO_SUCCESS
		{
			try
			{
				var qhold = new GLib.Subprocess.newv ({QHOLD, "%s@%s".printf (job_id, service_url.host)},
				                                      GLib.SubprocessFlags.NONE);
				qhold.wait_check ();
			}
			catch (GLib.Error err)
			{
				throw new Error.NO_SUCCESS (err.message);
			}
		}

		public override async void suspend_async (int priority = GLib.Priority.DEFAULT) throws Error.NO_SUCCESS
		{
			try
			{
				var qhold = new GLib.Subprocess.newv ({QHOLD, "%s@%s".printf (job_id, service_url.host)},
				                                      GLib.SubprocessFlags.NONE);
				yield qhold.wait_check_async ();
			}
			catch (GLib.Error err)
			{
				throw new Error.NO_SUCCESS (err.message);
			}
		}

		public override void resume () throws Error.NO_SUCCESS
		{
			try
			{
				var qrls = new GLib.Subprocess.newv ({QRLS, "%s@%s".printf (job_id, service_url.host)},
				                                     GLib.SubprocessFlags.NONE);
				qrls.wait_check ();
			}
			catch (GLib.Error err)
			{
				throw new Error.NO_SUCCESS (err.message);
			}
		}

		public override async void resume_async (int priority = GLib.Priority.DEFAULT) throws Error.NO_SUCCESS
		{
			try
			{
				var qrls = new GLib.Subprocess.newv ({QRLS, "%s@%s".printf (job_id, service_url.host)},
				                                     GLib.SubprocessFlags.NONE);
				yield qrls.wait_check_async ();
			}
			catch (GLib.Error err)
			{
				throw new Error.NO_SUCCESS (err.message);
			}
		}

		public override void checkpoint () throws Error.NO_SUCCESS
		{
			try
			{
				var qchkpt = new GLib.Subprocess.newv ({QCHKPT, "%s@%s".printf (job_id, service_url.host)},
				                                       GLib.SubprocessFlags.NONE);
				qchkpt.wait_check ();
			}
			catch (GLib.Error err)
			{
				throw new Error.NO_SUCCESS (err.message);
			}
		}

		public override async void checkpoint_async (int priority = GLib.Priority.DEFAULT) throws Error.NO_SUCCESS
		{
			try
			{
				var qchkpt = new GLib.Subprocess.newv ({QCHKPT, "%s@%s".printf (job_id, service_url.host)},
				                                       GLib.SubprocessFlags.NONE);
				yield qchkpt.wait_check_async ();
			}
			catch (GLib.Error err)
			{
				throw new Error.NO_SUCCESS (err.message);
			}
		}

		public override void migrate (owned JobDescription jd) throws Error.NO_SUCCESS
		{
			try
			{
				var qalter = new GLib.Subprocess.newv (qalter_args_from_job_description (service_url, jd, job_id),
				                                       GLib.SubprocessFlags.NONE);
				qalter.wait_check ();
			}
			catch (GLib.Error err)
			{
				throw new Error.NO_SUCCESS (err.message);
			}
		}

		public override async void migrate_async (owned JobDescription jd, int priority = GLib.Priority.DEFAULT)
			throws Error.NO_SUCCESS
		{
			try
			{
				var qalter = new GLib.Subprocess.newv (qalter_args_from_job_description (service_url, jd, job_id),
				                                       GLib.SubprocessFlags.NONE);
				yield qalter.wait_check_async ();
			}
			catch (GLib.Error err)
			{
				throw new Error.NO_SUCCESS (err.message);
			}
		}

		public override void @signal (GLib.ProcessSignal signum) throws Error.NO_SUCCESS
		{
			try
			{
				var qsig = new GLib.Subprocess.newv ({QSIG, "-s", signum.to_string (), "%s@%s".printf (job_id, service_url.host)},
				                                     GLib.SubprocessFlags.NONE);
				qsig.wait_check ();
			}
			catch (GLib.Error err)
			{
				throw new Error.NO_SUCCESS (err.message);
			}
		}

		public override async void signal_async (GLib.ProcessSignal signum, int priority = GLib.Priority.DEFAULT)
			throws Error.NO_SUCCESS
		{
			try
			{
				var qsig = new GLib.Subprocess.newv ({QSIG, "-s", signum.to_string (), "%s@%s".printf (job_id, service_url.host)},
				                                     GLib.SubprocessFlags.NONE);
				yield qsig.wait_check_async ();
			}
			catch (GLib.Error err)
			{
				throw new Error.NO_SUCCESS (err.message);
			}
		}

		public void update_from_gxml_node (GXml.Node job_node)
		{
			if (job_node.@get ("exec_host") != null)
			{
				execution_hosts = {job_node.@get ("exec_host").@value};
			}

			if (job_node.@get ("start_time") != null)
			{
				started = new DateTime.from_unix_utc (int64.parse (job_node.@get ("start_time").@value));
			}

			if (job_node.@get ("comp_time") != null)
			{
				finished = new DateTime.from_unix_utc (int64.parse (job_node.@get ("comp_time").@value));
			}

			if (job_node.@get ("exit_status") != null)
			{
				exit_code = int.parse (job_node.@get ("exit_status").@value);

				if (exit_code > 256)
				{
					term_sig = (ProcessSignal) (exit_code - 256);
				}
			}

			JobState current_job_state;
			switch (job_node.@get ("job_state").@value)
			{
				case "H":
				case "Q":
				case "T":
					current_job_state = JobState.NEW;
					break;
				case "R":
					current_job_state = JobState.RUNNING;
					break;
				case "W":
				case "S":
					current_job_state = JobState.SUSPENDED;
					break;
				case "C":
				case "E":
					if (term_sig == 9 || term_sig == 15)
					{
						current_job_state = JobState.CANCELED;
					}
					else
					{
						current_job_state = exit_code == 0 ? JobState.DONE : JobState.FAILED;
					}
					break;
				default:
					warning ("Unexpected value '%s' for 'job_state' in 'qstat' output.", job_node.@get ("job_state").@value);
					current_job_state = last_job_state;
					break;
			}

			if (last_job_state != current_job_state)
			{
				last_job_state = current_job_state;
				job_state (current_job_state);
			}

			if (job_node.@get ("resources_used") != null)
			{
				var cput_parts = job_node.@get ("resources_used").@get ("cput").@value.split (":");
				job_cpu_time (3600 * int.parse (cput_parts[0]) + 60 * int.parse (cput_parts[1]) + int.parse (cput_parts[2]));
				job_memory_use (parse_size_literal (job_node.@get ("resources_used").@get ("mem").@value));
				job_vmemory_use (parse_size_literal (job_node.@get ("resources_used").@get ("vmem").@value));
			}
		}
	}

	public class JobService : Saga.JobService
	{
		private HashTable<string, Job> monitored_jobs = new HashTable<string, Job> (str_hash, str_equal);

		construct
		{
			GLib.Timeout.add_seconds (5, () => {
				try
				{
					string[] qstat_args = {QSTAT, "-x"};

					monitored_jobs.foreach_remove ((_, job) => {
						if (job.ref_count < 3)
						{
							return true; // we (and the 'SList') are the only reference
						}
						else
						{
							qstat_args += "%s@%s".printf (job.job_id, get_service_url ().host);
							return false;
						}
					});

					if (qstat_args.length < 3)
					{
						return Source.CONTINUE;
					}

					var qstat = new GLib.Subprocess.newv (qstat_args, GLib.SubprocessFlags.STDOUT_PIPE);

					// TODO: use something asynchronous here..
					string stdout_buf;
					string stderr_buf;
					qstat.communicate_utf8 (null, null, out stdout_buf, out stderr_buf);

					GLib.Process.check_exit_status (qstat.get_exit_status ());

					update_monitored_jobs_from_gxml_doc (new GXml.GDocument.from_string (stdout_buf));
				}
				catch (GLib.Error err)
				{
					critical (err.message);
				}

				return Source.CONTINUE;
			}, GLib.Priority.LOW);
		}

		/**
		 * Update monitored jobs from a 'qstat -x' output.
		 */
		private void update_monitored_jobs_from_gxml_doc (GXml.GDocument doc)
		{
			if (doc.children.is_empty)
				return;

			var data = doc.children.first ();

			foreach (var job_node in data.children)
			{
				var job_id = job_node.@get ("Job_Id");

				if (job_id == null)
				{
					critical ("Expected element 'Job_Id' in 'Job' node.");
					continue;
				}

				var job = monitored_jobs.lookup (job_id.@value);

				if (job == null)
				{
					continue;
				}

				job.update_from_gxml_node (job_node);
			}
		}

		public override Saga.Job create_job (owned JobDescription jd) throws Error.NO_SUCCESS
		{
			try
			{
				if (jd.working_directory != null)
				{
					if (DirUtils.create_with_parents (jd.working_directory, 0755) == -1)
					{
						throw new Error.NO_SUCCESS ("Could not create working directory '%s'.", jd.working_directory);
					}
				}

				string[] quoted_arguments = {};

				foreach (var argument in jd.arguments)
				{
					quoted_arguments += GLib.Shell.quote (argument);
				}

				var stdin_buf = "#!%s\n%s %s".printf (SH, jd.executable, string.joinv (" ", quoted_arguments));

				// TODO: create a job on hold
				var qsub = new GLib.Subprocess.newv (qsub_args_from_job_description (get_service_url (), jd),
				                                     (jd.interactive ? GLib.SubprocessFlags.STDERR_PIPE : GLib.SubprocessFlags.NONE) |
				                                     GLib.SubprocessFlags.STDIN_PIPE                                                 |
				                                     GLib.SubprocessFlags.STDOUT_PIPE);

				Job job;

				if (jd.interactive)
				{
					var dis = new DataInputStream (qsub.get_stdout_pipe ());

					// qsub: waiting for job <job_id> to start
					// qsub: job <job_id> ready
					//
					// ------------------------------------------------------

					// TODO: extract the job identifier
					var job_id = dis.read_line ();

					string? line = null;
					do
					{
						line = dis.read_line ();
					}
					while (line != "------------------------------------------------------");

					// Job is running on node <server>
					//   Working directory:  <working_directory>
					//   TMPDIR:             ... (available space:  ...)
					// ------------------------------------------------------

					do
					{
						line = dis.read_line ();
					}
					while (line != "------------------------------------------------------");

					// script I/O start here, but we cannot determine when it actually finish

					// TODO: filter out the following output

					//
					// qsub: job <job_id> completed

					job = new Job.interactive (get_session (),
					                           job_id,
					                           get_service_url (),
					                           jd,
					                           qsub.get_stdin_pipe (),
					                           dis,
					                           qsub.get_stdout_pipe ());
				}
				else
				{
					string stdout_buf;
					string stderr_buf;
					qsub.communicate_utf8 (stdin_buf, null, out stdout_buf, out stderr_buf);

					GLib.Process.check_exit_status (qsub.get_exit_status ());

					job = new Job (get_session (), stdout_buf.chomp (), get_service_url(), new DateTime.now_utc (), jd);
				}

				monitored_jobs.insert (job.job_id, job);

				// hold the job to prevent its immediate execution (until 'qrls' is called)
				// TODO: check if we can start the job on-hold
				 var qhold = new GLib.Subprocess.newv ({"qhold", "%s@%s".printf (job.job_id, get_service_url ().host)}, GLib.SubprocessFlags.NONE);
				 qhold.wait_check ();

				return job;
			}
			catch (GLib.Error err)
			{
				throw new Error.NO_SUCCESS (err.message);
			}
		}

		public override Saga.Job run_job (string            command_line,
		                                  string            host   = "",
		                                  out OutputStream? stdin  = null,
		                                  out InputStream?  stdout = null,
		                                  out InputStream?  stderr = null)
			throws Error
		{
			return base.run_job (command_line, host.length > 0 ? "@%s".printf (host): "", out stdin, out stdout, out stderr);
		}

		public override async Saga.Job run_job_async (string            command_line,
		                                              string            host     = "",
		                                              int               priority = GLib.Priority.DEFAULT,
		                                              out OutputStream? stdin    = null,
		                                              out InputStream?  stdout   = null,
		                                              out InputStream?  stderr   = null)
			throws Error
		{
			return yield base.run_job_async (command_line,
			                                 host.length > 0 ? "@%s".printf (host) : "",
			                                 priority,
			                                 out stdin,
			                                 out stdout,
			                                 out stderr);
		}

		// TODO: 'run_job_async'

		/**
		 * Extract job identifiers from a XML stdout.
		 *
		 * Only the 'Job_Id' attribute is considered, so the document should be
		 * stripped at most.
		 */
		public static string[] job_identifiers_from_gxml_doc (GXml.GDocument doc)
		{
			string[] job_identifiers = {};

			var data = doc.children.first ();

			foreach (var job in data.children)
			{
				job_identifiers += job.@get ("Job_Id").@value;
			}

			return job_identifiers;
		}

		public override string[] list () throws Error.NO_SUCCESS
		{
			try
			{
				var qstat = new GLib.Subprocess.newv ({QSTAT, "-x", "@%s".printf (get_service_url ().host)}, GLib.SubprocessFlags.STDOUT_PIPE);

				string stdout_buf;
				string stderr_buf;
				qstat.communicate_utf8 (null, null, out stdout_buf, out stderr_buf);

				GLib.Process.check_exit_status (qstat.get_exit_status ());

				var doc = new GXml.GDocument.from_string (stdout_buf);
				update_monitored_jobs_from_gxml_doc (doc);

				return job_identifiers_from_gxml_doc (doc);
			}
			catch (GLib.Error err)
			{
				throw new Error.NO_SUCCESS (err.message);
			}
		}

		public override async string[] list_async (int priority = GLib.Priority.DEFAULT) throws Error.NO_SUCCESS
		{
			try
			{
				var qstat = new GLib.Subprocess.newv ({QSTAT, "-x", "@%s".printf (get_service_url ().host)}, GLib.SubprocessFlags.STDOUT_PIPE);

				string stdout_buf;
				string stderr_buf;
				yield qstat.communicate_utf8_async (null, null, out stdout_buf, out stderr_buf);

				GLib.Process.check_exit_status (qstat.get_exit_status ());

				var doc = new GXml.GDocument.from_string (stdout_buf);
				update_monitored_jobs_from_gxml_doc (doc);

				return job_identifiers_from_gxml_doc (doc);
			}
			catch (GLib.Error err)
			{
				throw new Error.NO_SUCCESS (err.message);
			}
		}

		public override Saga.Job get_job (string id) throws Error.NO_SUCCESS, Error.DOES_NOT_EXIST
		{
			if (monitored_jobs.contains (id))
			{
				return monitored_jobs.lookup (id);
			}

			try
			{
				var qstat = new GLib.Subprocess.newv ({QSTAT, "-x", "%s@%s".printf (id, get_service_url ().host)}, GLib.SubprocessFlags.STDOUT_PIPE);

				string stdout_buf;
				string stderr_buf;
				qstat.communicate_utf8 (null, null, out stdout_buf, out stderr_buf);

				GLib.Process.check_exit_status (qstat.get_exit_status ());

				var doc = new GXml.GDocument.from_string (stdout_buf);

				update_monitored_jobs_from_gxml_doc (doc);

				var data = doc.children.first ();

				if (data.children.is_empty)
				{
					throw new Error.DOES_NOT_EXIST ("Could not fetch the job '%s' from the TORQUE backend.", id);
				}

				var job = new Job.from_gxml_node (get_session (), get_service_url (), data.children.first ());

				monitored_jobs.insert (job.job_id, job);

				return job;
			}
			catch (GLib.Error err)
			{
				throw new Error.NO_SUCCESS (err.message);
			}
		}

		public override async Saga.Job get_job_async (string id, int priority = GLib.Priority.DEFAULT)
			throws Error.NO_SUCCESS, Error.DOES_NOT_EXIST
		{
			if (monitored_jobs.contains (id))
			{
				return monitored_jobs.lookup (id);
			}

			try
			{
				var qstat = new GLib.Subprocess.newv ({QSTAT, "-x", "%s@%s".printf (id, get_service_url ().host)}, GLib.SubprocessFlags.STDOUT_PIPE);

				string stdout_buf;
				string stderr_buf;
				yield qstat.communicate_utf8_async (null, null, out stdout_buf, out stderr_buf);

				GLib.Process.check_exit_status (qstat.get_exit_status ());

				var doc = new GXml.GDocument.from_string (stdout_buf);

				update_monitored_jobs_from_gxml_doc (doc);

				var data = doc.children.first ();

				if (data.children.is_empty)
				{
					throw new Error.DOES_NOT_EXIST ("Could not fetch the job '%s' from the TORQUE backend.", id);
				}

				var job = new Job.from_gxml_node (get_session (), get_service_url (), data.children.first ());

				monitored_jobs.insert (job.job_id, job);

				return job;
			}
			catch (GLib.Error err)
			{
				throw new Error.NO_SUCCESS (err.message);
			}
		}
		public override Saga.Job get_self () throws Error.NO_SUCCESS
		{
			throw new Error.NO_SUCCESS ("The 'TORQUE' backend is not managed using a job.");
		}
	}
}
