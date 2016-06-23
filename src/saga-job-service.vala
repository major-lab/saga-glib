public abstract class Saga.JobService : Saga.Object, GLib.Object
{
	public static new JobService @new (Session session, URL url)                     throws Error.NOT_IMPLEMENTED,
	                                                                                        Error.BAD_PARAMETER,
	                                                                                        Error.INCORRECT_URL,
	                                                                                        Error.PERMISSION_DENIED,
	                                                                                        Error.AUTHORIZATION_FAILED,
	                                                                                        Error.AUTHENTICATION_FAILED,
	                                                                                        Error.TIMEOUT,
	                                                                                        Error.NO_SUCCESS
	{
		var module = BackendModule.new_for_url (url);

		if (module.types.job_service_type == GLib.Type.INVALID)
		{
			throw new Error.NOT_IMPLEMENTED ("The '%s' backend does not provide the job service.", url.scheme);
		}

		var job_service = GLib.Object.@new (module.types.job_service_type) as JobService;

		job_service._session     = session;
		job_service._service_url = url;

		return job_service;
	}

	construct
	{
		UUID.generate (_id);
	}

	private uint8 _id[16];

	public string get_id ()
	{
		char @out[37];
		UUID.unparse (_id, @out);
		return (string) @out;
	}

	private Session _session;

	public Session get_session ()
	{
		return _session;
	}

	private URL _service_url;

	public URL get_service_url ()
	{
		return _service_url;
	}

	public abstract Job create_job (owned JobDescription jd)                         throws Error.NOT_IMPLEMENTED,
	                                                                                        Error.BAD_PARAMETER,
	                                                                                        Error.PERMISSION_DENIED,
	                                                                                        Error.AUTHORIZATION_FAILED,
	                                                                                        Error.AUTHENTICATION_FAILED,
	                                                                                        Error.TIMEOUT,
	                                                                                        Error.NO_SUCCESS;

	public virtual async Job create_job_async (owned JobDescription jd, int priority = GLib.Priority.DEFAULT)
	                                                                                 throws Error.NOT_IMPLEMENTED,
	                                                                                        Error.BAD_PARAMETER,
	                                                                                        Error.PERMISSION_DENIED,
	                                                                                        Error.AUTHORIZATION_FAILED,
	                                                                                        Error.AUTHENTICATION_FAILED,
	                                                                                        Error.TIMEOUT,
	                                                                                        Error.NO_SUCCESS
	{
		return create_job (jd);
	}

	public virtual Job run_job (string                 command_line,
	                            string                 host   = "",
	                            out GLib.OutputStream? stdin  = null,
	                            out GLib.InputStream?  stdout = null,
	                            out GLib.InputStream?  stderr = null)                throws Error.NOT_IMPLEMENTED,
	                                                                                        Error.BAD_PARAMETER,
	                                                                                        Error.PERMISSION_DENIED,
	                                                                                        Error.AUTHORIZATION_FAILED,
	                                                                                        Error.AUTHENTICATION_FAILED,
	                                                                                        Error.TIMEOUT,
	                                                                                        Error.NO_SUCCESS
	{
		var jd = new JobDescription ();

		jd.interactive = true;
		jd.queue       = host;
		jd.executable  = command_line;

		try
		{
			string[] arguments;
			GLib.Shell.parse_argv (command_line, out arguments);
			jd.arguments = arguments;
		}
		catch (GLib.ShellError err)
		{
			throw new Error.NO_SUCCESS (err.message);
		}

		var job = create_job (jd);

		try
		{
			stdin  = job.get_stdin ();
		}
		catch (Error err)
		{
			stdin = null;
		}

		try
		{
			stdout  = job.get_stdout ();
		}
		catch (Error err)
		{
			stdout = null;
		}

		try
		{
			stderr  = job.get_stderr ();
		}
		catch (Error err)
		{
			stderr = null;
		}

		job.run ();

		return job;
	}

	public virtual async Job run_job_async (string                 command_line,
	                                        string                 host     = "",
	                                        int                    priority = GLib.Priority.DEFAULT,
	                                        out GLib.OutputStream? stdin    = null,
	                                        out GLib.InputStream?  stdout   = null,
	                                        out GLib.InputStream?  stderr   = null)  throws Error.NOT_IMPLEMENTED,
	                                                                                        Error.BAD_PARAMETER,
	                                                                                        Error.PERMISSION_DENIED,
	                                                                                        Error.AUTHORIZATION_FAILED,
	                                                                                        Error.AUTHENTICATION_FAILED,
	                                                                                        Error.TIMEOUT,
	                                                                                        Error.NO_SUCCESS
	{
		return run_job (command_line, host, out stdin, out stdout, out stderr);
	}

	public abstract string[] list ()                                                 throws Error.NOT_IMPLEMENTED,
	                                                                                        Error.PERMISSION_DENIED,
	                                                                                        Error.AUTHORIZATION_FAILED,
	                                                                                        Error.AUTHENTICATION_FAILED,
	                                                                                        Error.TIMEOUT,
	                                                                                        Error.NO_SUCCESS;

	public virtual async string[] list_async (int priority = GLib.Priority.DEFAULT)  throws Error.NOT_IMPLEMENTED,
	                                                                                        Error.PERMISSION_DENIED,
	                                                                                        Error.AUTHORIZATION_FAILED,
	                                                                                        Error.AUTHENTICATION_FAILED,
	                                                                                        Error.TIMEOUT,
	                                                                                        Error.NO_SUCCESS
	{
		return list ();
	}

	public abstract Job get_job (string job_id)                                      throws Error.NOT_IMPLEMENTED,
	                                                                                        Error.BAD_PARAMETER,
	                                                                                        Error.DOES_NOT_EXIST,
	                                                                                        Error.PERMISSION_DENIED,
	                                                                                        Error.AUTHORIZATION_FAILED,
	                                                                                        Error.AUTHENTICATION_FAILED,
	                                                                                        Error.TIMEOUT,
	                                                                                        Error.NO_SUCCESS;

	public virtual async Job get_job_async (string job_id, int priority = GLib.Priority.DEFAULT)
	                                                                                 throws Error.NOT_IMPLEMENTED,
	                                                                                        Error.BAD_PARAMETER,
	                                                                                        Error.DOES_NOT_EXIST,
	                                                                                        Error.PERMISSION_DENIED,
	                                                                                        Error.AUTHORIZATION_FAILED,
	                                                                                        Error.AUTHENTICATION_FAILED,
	                                                                                        Error.TIMEOUT,
	                                                                                        Error.NO_SUCCESS
	{
		return get_job (job_id);
	}

	public abstract Job get_self ()                                                  throws Error.NOT_IMPLEMENTED,
	                                                                                        Error.PERMISSION_DENIED,
	                                                                                        Error.AUTHORIZATION_FAILED,
	                                                                                        Error.AUTHENTICATION_FAILED,
	                                                                                        Error.TIMEOUT,
	                                                                                        Error.NO_SUCCESS;

	public virtual async Job get_self_async (int priority = GLib.Priority.DEFAULT)   throws Error.NOT_IMPLEMENTED,
	                                                                                        Error.PERMISSION_DENIED,
	                                                                                        Error.AUTHORIZATION_FAILED,
	                                                                                        Error.AUTHENTICATION_FAILED,
	                                                                                        Error.TIMEOUT,
	                                                                                        Error.NO_SUCCESS
	{
		return get_self ();
	}
}
