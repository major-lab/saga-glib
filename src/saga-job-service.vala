public abstract class Saga.JobService : Saga.Object, GLib.Object
{
	public static new JobService @new (Session session, URL url) throws Error.NOT_IMPLEMENTED,
	                                                                    Error.BAD_PARAMETER,
	                                                                    Error.INCORRECT_URL,
	                                                                    Error.PERMISSION_DENIED,
	                                                                    Error.AUTHORIZATION_FAILED,
	                                                                    Error.AUTHENTICATION_FAILED,
	                                                                    Error.TIMEOUT,
	                                                                    Error.NO_SUCCESS
	{
		var module = new BackendModule (null, url.scheme);

		if (!module.load ())
		{
			throw new Error.NO_SUCCESS ("Could not load '%s'.", module.path);
		}

		var job_service = GLib.Object.@new (module.job_service_type) as JobService;

		job_service._session = session;

		return job_service;
	}

	construct
	{
		UUID.generate (_id);
	}

	private uint8 _id[16];

	public string get_id ()
	{
		return (string) _id;
	}

	private Session _session;

	public Session get_session ()
	{
		return _session;
	}

	public abstract Job create_job (JobDescription jd)                                throws Error.NOT_IMPLEMENTED,
	                                                                                         Error.BAD_PARAMETER,
	                                                                                         Error.PERMISSION_DENIED,
	                                                                                         Error.AUTHORIZATION_FAILED,
	                                                                                         Error.AUTHENTICATION_FAILED,
	                                                                                         Error.TIMEOUT,
	                                                                                         Error.NO_SUCCESS;

	public virtual async Job create_job_async (JobDescription jd, int priority = GLib.Priority.DEFAULT)
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

	public virtual void run_job (string command_line, string host = "")               throws Error.NOT_IMPLEMENTED,
	                                                                                         Error.BAD_PARAMETER,
	                                                                                         Error.PERMISSION_DENIED,
	                                                                                         Error.AUTHORIZATION_FAILED,
	                                                                                         Error.AUTHENTICATION_FAILED,
	                                                                                         Error.TIMEOUT,
	                                                                                         Error.NO_SUCCESS
	{
		throw new Error.NOT_IMPLEMENTED ("");
	}

	public virtual async void run_job_async (string command_line,
	                                         string host     = "",
	                                         int    priority = GLib.Priority.DEFAULT) throws Error.NOT_IMPLEMENTED,
	                                                                                         Error.BAD_PARAMETER,
	                                                                                         Error.PERMISSION_DENIED,
	                                                                                         Error.AUTHORIZATION_FAILED,
	                                                                                         Error.AUTHENTICATION_FAILED,
	                                                                                         Error.TIMEOUT,
	                                                                                         Error.NO_SUCCESS
	{
		run_job (command_line, host);
	}

	public abstract string[] list ()                                                  throws Error.NOT_IMPLEMENTED,
	                                                                                         Error.PERMISSION_DENIED,
	                                                                                         Error.AUTHORIZATION_FAILED,
	                                                                                         Error.AUTHENTICATION_FAILED,
	                                                                                         Error.TIMEOUT,
	                                                                                         Error.NO_SUCCESS;

	public virtual async string[] list_async ()                                       throws Error.NOT_IMPLEMENTED,
	                                                                                         Error.PERMISSION_DENIED,
	                                                                                         Error.AUTHORIZATION_FAILED,
	                                                                                         Error.AUTHENTICATION_FAILED,
	                                                                                         Error.TIMEOUT,
	                                                                                         Error.NO_SUCCESS
	{
		return list ();
	}

	public abstract Job get_job (string job_id)                                       throws Error.NOT_IMPLEMENTED,
	                                                                                         Error.BAD_PARAMETER,
	                                                                                         Error.DOES_NOT_EXIST,
	                                                                                         Error.PERMISSION_DENIED,
	                                                                                         Error.AUTHORIZATION_FAILED,
	                                                                                         Error.AUTHENTICATION_FAILED,
	                                                                                         Error.TIMEOUT,
	                                                                                         Error.NO_SUCCESS;

	public virtual async Job get_job_async (string job_id)                            throws Error.NOT_IMPLEMENTED,
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

	public abstract Job get_self ()                                                   throws Error.NOT_IMPLEMENTED,
	                                                                                         Error.PERMISSION_DENIED,
	                                                                                         Error.AUTHORIZATION_FAILED,
	                                                                                         Error.AUTHENTICATION_FAILED,
	                                                                                         Error.TIMEOUT,
	                                                                                         Error.NO_SUCCESS;

	public virtual async Job get_self_async ()                                        throws Error.NOT_IMPLEMENTED,
	                                                                                         Error.PERMISSION_DENIED,
	                                                                                         Error.AUTHORIZATION_FAILED,
	                                                                                         Error.AUTHENTICATION_FAILED,
	                                                                                         Error.TIMEOUT,
	                                                                                         Error.NO_SUCCESS
	{
		return get_self ();
	}
}
