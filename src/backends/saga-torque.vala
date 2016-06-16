[ModuleInit]
public Type backend_init (TypeModule type_module)
{
	return typeof (Saga.TORQUE.JobService);
}

namespace Saga.TORQUE
{
	// TODO: use extern from the build
	private const string QALTER = "qalter";
	private const string QCHKPT = "qchkpt";
	private const string QHOLD  = "qhold";
	private const string QRLS   = "qrls";
	private const string QSIG   = "qsig";
	private const string QSTAT  = "qstat";
	private const string QSUB   = "qsub";

	/**
	 * Generate arguments for 'qsub' and 'qalter'.
	 *
	 * @param create only generate options suitable for a migration with 'qalter'
	 * @param job_id if 'create' is specified, the job identifier
	 */
	private string[] args_from_job_description (JobDescription jd, bool create = true, string? job_id = null)
	{
		string[] args = {create ? QSUB : QALTER};

		// perform manual checkpoints
		args += "-c";
		args += "enabled";

		if (create && jd.arguments.length > 0) {
			args += "-F";
			string[] arguments = {};
			foreach (var argument in jd.arguments)
			{
				arguments += GLib.Shell.quote (argument);
			}
			args += string.joinv (" ", arguments);
		}

		// TODO: 'spmd_variation'

		var resource_list = new StringBuilder ();

		resource_list.append_printf ("nodes=%d:ppn=%d", jd.total_cpu_count, jd.processes_per_host);

		if (jd.threads_per_process > 1)
			warning ("TORQUE backend does not support 'threads_per_process'.");

		if (create && jd.environment.length > 0)
		{
			args += "-v";
			args += string.joinv (",", jd.environment);
		}

		if (create) {
			args += "-d";
			args += jd.working_directory;
		}

		if (create && jd.interactive)
		{
			args += "-I";
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
				args += "-k";
				args += "n";
			}
			else
			{
				args += "-k";
				args += "oe";
			}
		}

		if (stagein.length > 0)
		{
			args += "-W";
			args += string.joinv (",", stagein);
		}

		if (stageout.length > 0)
		{
			args += "-W";
			args += string.joinv (",", stageout);
		}

		if (jd.job_start_time != null)
		{
			args += "-a";
			args += jd.job_start_time.format ("%Y%%m%d%H%M.%S");
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
			args += "-l";
			args += resource_list.str;
		}

		// TODO: 'candidate_hosts'
		if (jd.candidate_hosts.length > 0)
			warning ("The 'candidate_hosts' option is not implemented and was ignored.");

		if (create && jd.queue != null)
		{
			args += "-q";
			args += jd.queue;
		}

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

		if (create)
		{
			args += jd.executable;
		}
		else
		{
			args += job_id;
		}

		return args;
	}

	public class Job : Saga.Job
	{
		private uint8 _id[16];

		private Session _session;

		private JobDescription _job_description;

		public Job (Session session, string job_id, URL service_url, JobDescription job_description)
		{
			GLib.Object (job_id: job_id, service_url: service_url);
			UUID.generate (_id);
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
			this (session, job_id, service_url, job_description);
			_stdin  = stdin;
			_stdout = stdout;
			_stderr = stderr;
		}

		public Job.from_xml_node (Session session, URL service_url, Xml.Node* job) throws Error.NOT_IMPLEMENTED,
		                                                                                  Error.NO_SUCCESS
		{
			string? job_id      = null;
			var job_description = new JobDescription ();

			for (var child = job->children; child->next != null; child = child->next)
			{
				switch (child->name)
				{
					case "Job_Id":
						job_id = child->get_content ();
						break;
					case "submit_args":
						string[] arguments = {};
						foreach (var argument in child->get_content ().split (" "))
						{
							try
							{
								arguments += GLib.Shell.unquote (argument);
							}
							catch (ShellError err)
							{
								throw new Error.NO_SUCCESS (err.message);
							}
						}
						job_description.arguments = arguments;
						break;
					case "Resource_List":
						for (var resource = child->children; resource->next != null; resource = resource->next)
						{
							switch (resource->name)
							{
								case "nodect":
									job_description.total_cpu_count = int.parse (resource->get_content ());
									break;
								case "nodes":
									// TODO: happy parsing..
									foreach (var node in resource->get_content ().split ("+"))
									{

									}
									break;
								case "walltime":
									job_description.wall_time_limit = int.parse (resource->get_content ());
									break;
							}
						}
						break;
					case "Output_Path":
						job_description.output = child->get_content ();
						break;
					case "Error_Path":
						job_description.error = child->get_content ();
						break;
					case "Keep_Files":
						job_description.cleanup = child->get_content () == "n";
						break;
					case "start_time":
						// TODO: check local vs UTC
						job_description.job_start_time = new GLib.DateTime.from_unix_local (int.parse (child->get_content ()));
						break;
					case "queue":
						job_description.queue = child->get_content ();
						break;
					case "Job_Name":
						job_description.job_project = child->get_content ();
						break;
					case "Mail_Users":
						URL[] job_contact = {};
						foreach (var mail_user in child->get_content ().split (","))
						{
							job_contact += new URL ("mailto:%s".printf (mail_user));
						}
						job_description.job_contact = job_contact;
						break;
				}
			}

			if (job_id == null)
			{
				throw new Error.NO_SUCCESS ("The job identifier could not be retreived.");
			}

			this (session, job_id, service_url, job_description);
		}

		public override string get_id ()
		{
			return (string) _id;
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
			throw new Error.NOT_IMPLEMENTED ("") ;
		}

		private JobState last_job_state;
		private string   last_job_state_detail;

		private static double parse_memory_usage (string mu)
		{
			if (mu.has_suffix ("tb"))
			{
				return 1099511627776 * uint64.parse (mu.slice (0, mu.length - 2));
			}
			else if (mu.has_suffix ("gb"))
			{
				return 1073741824 * uint64.parse (mu.slice (0, mu.length - 2));
			}
			else if (mu.has_suffix ("mb"))
			{
				return 1048576 * uint64.parse (mu.slice (0, mu.length - 2));
			}
			else if (mu.has_suffix ("kb"))
			{
				return 1024 * uint64.parse (mu.slice (0, mu.length - 2));
			}
			else if (mu.has_suffix ("b"))
			{
				return uint64.parse (mu.slice (0, mu.length - 1));
			}
			else
			{
				return uint64.parse (mu);
			}
		}

		public async void monitor_async (string[] metrics, int priority = GLib.Priority.DEFAULT)
		{
			var failures = 0;

			do
			{
				string xml;
				try
				{
					var qstat = new Subprocess (SubprocessFlags.STDOUT_PIPE, QSTAT, "-x", job_id);
					string stdout_buf;
					string stderr_buf;
					// TODO: async with callback
					yield qstat.communicate_utf8_async (null, null, out stdout_buf, out stderr_buf);
					xml = stdout_buf;
				}
				catch (GLib.Error err)
				{
					critical (err.message);
					failures++;
					if (failures > 10)
						throw new Error.NO_SUCCESS ("Could not successfully launch 'qstat' ('%d' failures occured).",
						                            failures);
					// TODO: exponential backoff
					// new TimeoutSource ((uint) Math.exp (failures)).set_callback (monitor_async.callback);
					yield;
					continue;
				}

				var doc  = Xml.Parser.parse_doc (xml);
				var data = doc->get_root_element ();

				if (data->children == null)
					return;

				var job  = data->children;

				for (var child = job->children; child->next != null; child = child->next)
				{
					switch (child->name)
					{
						// attributes
						case "exec_host":
							execution_hosts = {child->get_content ()};
							break;
						case "exit_code":
							exit_code = int.parse (child->get_content ());
							break;
						// metrics
						case "job_state":
							if (GLib.strv_contains (metrics, "job.state"))
							{
								switch (child->get_content ())
								{
									case "C":
									case "E":
										if (last_job_state != JobState.DONE)
										{
											last_job_state = JobState.DONE;
											job_state (JobState.DONE);
										}
										break;
									case "H":
									case "Q":
										break;
									case "R":
										if (last_job_state != JobState.RUNNING)
										{
											last_job_state = JobState.RUNNING;
											job_state (JobState.RUNNING);
										}
										break;
									case "T":
									case "W":
										break;
									case "S":
										if (last_job_state != JobState.SUSPENDED)
										{
											last_job_state = JobState.SUSPENDED;
											job_state (JobState.SUSPENDED);
										}
										break;
								}
							}
							if (GLib.strv_contains (metrics, "job.state_detail") && child->get_content () != last_job_state_detail)
							{
								last_job_state_detail = child->get_content ();
								job_state_detail (child->get_content ());
							}
							break;
						case "resources_used":
							for (var resource = child->children; resource->next != null; resource = resource->next)
							{
								switch (resource->name)
								{
									case "mem":
										if (GLib.strv_contains (metrics, "job.memory_use"))
										{
											job_memory_use (parse_memory_usage (resource->get_content ()));
										}
										break;
									case "vmem":
										if (GLib.strv_contains (metrics, "job.vmemory_use"))
										{
											job_vmemory_use (parse_memory_usage (resource->get_content ()));
										}
										break;
								}
							}
							break;
						}
				}

				// avoid flooding TORQUE
				// TODO: efficient polling
				new TimeoutSource (2000).set_callback (monitor_async.callback);
				yield;
			}
			while (true);
		}

		public override void run ()
		{
			// TODO: qrun
		}

		public override void cancel (double timeout = 0.0)
		{
			// TODO: qdel
		}

		public override void wait (double timeout = 0.0)
		{}

		public override TaskState get_state ()
		{
			// TODO: qstat
			throw new Error.NOT_IMPLEMENTED ("");
		}

		public override int get_result ()
		{
			throw new Error.NOT_IMPLEMENTED ("");
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
				var qhold = new Subprocess (SubprocessFlags.NONE, QHOLD, job_id);
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
				var qhold = new Subprocess (SubprocessFlags.NONE, QHOLD, job_id);
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
				var qrls = new Subprocess (SubprocessFlags.NONE, QRLS, job_id);
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
				var qrls = new Subprocess (SubprocessFlags.NONE, QRLS, job_id);
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
				var qchkpt = new Subprocess (SubprocessFlags.NONE, QCHKPT, job_id);
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
				var qchkpt = new Subprocess (SubprocessFlags.NONE, QCHKPT, job_id);
				yield qchkpt.wait_check_async ();
			}
			catch (GLib.Error err)
			{
				throw new Error.NO_SUCCESS (err.message);
			}
		}

		public override void migrate (JobDescription jd) throws Error.NO_SUCCESS
		{
			try
			{
				var qalter = new Subprocess.newv (args_from_job_description (jd, false, job_id), SubprocessFlags.NONE);
				qalter.wait_check ();
			}
			catch (GLib.Error err)
			{
				throw new Error.NO_SUCCESS (err.message);
			}
		}

		public override async void migrate_async (JobDescription jd, int priority = GLib.Priority.DEFAULT)
			throws Error.NO_SUCCESS
		{
			try
			{
				var qalter = new Subprocess.newv (args_from_job_description (jd, false, job_id), SubprocessFlags.NONE);
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
				var qsig = new Subprocess (SubprocessFlags.NONE, QSIG, "-s", signum.to_string (), job_id);
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
				var qsig = new Subprocess (SubprocessFlags.NONE, QSIG, "-s", signum.to_string (), job_id);
				yield qsig.wait_check_async ();
			}
			catch (GLib.Error err)
			{
				throw new Error.NO_SUCCESS (err.message);
			}
		}
	}

	public class JobService : Saga.JobService
	{
		private SList<Job> monitored_jobs = new SList<Job> ();

		/**
		 * Extract the job identifier from the first line of an interactive
		 * output.
		 */
		private static string job_id_from_interactive_stdout_line (string stdout)
		{
			// TODO:
			return "";
		}

		public override Saga.Job create_job (JobDescription jd) throws Error.NO_SUCCESS, Error.NO_SUCCESS
		{
			try
			{
				// TODO: create a job on hold
				var qsub = new Subprocess.newv (args_from_job_description (jd, true),
				                                jd.interactive ? SubprocessFlags.STDIN_PIPE  |
				                                                 SubprocessFlags.STDOUT_PIPE |
				                                                 SubprocessFlags.STDERR_PIPE : SubprocessFlags.STDOUT_PIPE);

				Job job;

				if (jd.interactive)
				{
					var dis = new DataInputStream (qsub.get_stdout_pipe ());

					var job_id_line = dis.read_line ();

					// TODO: push-back the line into the stream

					job = new Job.interactive (get_session (),
					                           job_id_from_interactive_stdout_line (job_id_line),
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
					qsub.communicate_utf8 (null, null, out stdout_buf, out stderr_buf);

					job = new Job (get_session (), stdout_buf, get_service_url(), jd);
				}

				// hold the job to prevent its immediate execution (until qrls is called)
				// TODO: check if we can start a job on hold
				var qhold = new Subprocess (SubprocessFlags.NONE, "qhold", job.job_id);
				qhold.wait_check ();

				return job;
			}
			catch (GLib.Error err)
			{
				throw new Error.NO_SUCCESS (err.message);
			}
		}

		// TODO: create_job_async

		public override void run_job (string            command_line,
		                              string            host   = "",
		                              out OutputStream? stdin  = null,
		                              out InputStream?  stdout = null,
		                              out InputStream?  stderr = null)
			throws Error.NO_SUCCESS
		{
			throw new Error.NO_SUCCESS ("");
		}

		/**
		 * Extract job identifiers from a XML stdout.
		 *
		 * Only the 'Job_Id' attribute is considered, so the document should be
		 * stripped at most.
		 */
		public static string[] job_identifiers_from_xml_stdout (string xml)
		{
			var doc  = Xml.Parser.parse_doc (xml);
			var data = doc->get_root_element ();

			string[] job_identifiers = {};

			for (var job = data->children; job->next != null; job = job->next)
			{
				for (var child = job->children; child->next != null; child = child->next)
				{
					if (child->name == "Job_Id")
					{
						job_identifiers += child->get_content ();
						break;
					}
				}
			}

			return job_identifiers;
		}

		public override string[] list () throws Error.NO_SUCCESS
		{
			try
			{
				var qstat = new Subprocess (SubprocessFlags.STDOUT_PIPE, "qstat", "-x");

				string stdout_buf;
				string stderr_buf;
				if (qstat.communicate_utf8 (null, null, out stdout_buf, out stderr_buf))
				{
					return job_identifiers_from_xml_stdout (stdout_buf);
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

		public override async string[] list_async (int priority = GLib.Priority.DEFAULT) throws Error.NO_SUCCESS
		{
			try
			{
				var qstat = new Subprocess (SubprocessFlags.STDOUT_PIPE, "qstat", "-x");

				string stdout_buf;
				string stderr_buf;
				if (yield qstat.communicate_utf8_async (null, null, out stdout_buf, out stderr_buf))
				{
					return job_identifiers_from_xml_stdout (stdout_buf);
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

		/**
		 * Extract {@link Job} objects described in 'qstat' XML stdout.
		 */
		private SList<Job> jobs_from_xml_stdout (string xml)
		{
			var jobs = new SList<Job> ();

			var doc  = Xml.Parser.parse_doc (xml);
			var data = doc->get_root_element ();

			// traversed in reverse order to perform O(1) insert
			for (var job = data->last; job->prev != null; job = job->prev)
			{
				jobs.prepend (new Job.from_xml_node (get_session (), get_service_url (), job));
			}

			return jobs;
		}

		public override Saga.Job get_job (string id) throws Error.NO_SUCCESS
		{
			try
			{
				var qstat = new Subprocess (SubprocessFlags.STDOUT_PIPE, "qstat", "-x", id);

				string stdout_buf;
				string stderr_buf;
				qstat.communicate_utf8 (null, null, out stdout_buf, out stderr_buf);

				// it should be the first one
				foreach (var job in jobs_from_xml_stdout (stdout_buf))
				{
					if (job.job_id == id)
					{
						return job;
					}
				}

				throw new Error.NO_SUCCESS ("Could not fetch the job from the TORQUE backend");
			}
			catch (GLib.Error err)
			{
				throw new Error.NO_SUCCESS (err.message);
			}
		}

		public override async Saga.Job get_job_async (string id, int priority = GLib.Priority.DEFAULT)
			throws Error.NO_SUCCESS
		{
			try
			{
				var qstat = new Subprocess (SubprocessFlags.STDOUT_PIPE, "qstat", "-x", id);

				string stdout_buf;
				string stderr_buf;
				yield qstat.communicate_utf8_async (null, null, out stdout_buf, out stderr_buf);

				// it should be the first one
				foreach (var job in jobs_from_xml_stdout (stdout_buf))
				{
					if (job.job_id == id)
					{
						return job;
					}
				}

				throw new Error.NO_SUCCESS ("Could not fetch the job from the TORQUE backend");
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
