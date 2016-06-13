public abstract class Saga.JobService : Saga.Object, GLib.Object
{
	private uint8   _id[16];
	private Session _session;

	public JobService (Session session, URL url)
	{
		UUID.generate (_id);
		_session = session;
	}

	public string get_id ()
	{
		return (string) _id;
	}

	public Session get_session ()
	{
		return _session;
	}

	public abstract Job create_job (JobDescription jd) throws Error.NOT_IMPLEMENTED,
	                                                          Error.BAD_PARAMETER,
	                                                          Error.PERMISSION_DENIED,
	                                                          Error.AUTHORIZATION_FAILED,
	                                                          Error.AUTHENTICATION_FAILED,
	                                                          Error.TIMEOUT,
	                                                          Error.NO_SUCCESS;

	public virtual void run_job (string command_line, string host = "") throws Error.NOT_IMPLEMENTED,
	                                                                           Error.BAD_PARAMETER,
	                                                                           Error.PERMISSION_DENIED,
	                                                                           Error.AUTHORIZATION_FAILED,
	                                                                           Error.AUTHENTICATION_FAILED,
	                                                                           Error.TIMEOUT,
	                                                                           Error.NO_SUCCESS
	{
		var job = create_job (new JobDescription ());
	}

	public abstract string[] list () throws Error.NOT_IMPLEMENTED,
	                                        Error.PERMISSION_DENIED,
	                                        Error.AUTHORIZATION_FAILED,
	                                        Error.AUTHENTICATION_FAILED,
	                                        Error.TIMEOUT,
	                                        Error.NO_SUCCESS;

	public virtual async string[] list_async () throws Error.NOT_IMPLEMENTED,
	                                                   Error.PERMISSION_DENIED,
	                                                   Error.AUTHORIZATION_FAILED,
	                                                   Error.AUTHENTICATION_FAILED,
	                                                   Error.TIMEOUT,
	                                                   Error.NO_SUCCESS
	{
		return list ();
	}

	public abstract Job get_job (string job_id) throws Error.NOT_IMPLEMENTED,
	                                                   Error.BAD_PARAMETER,
	                                                   Error.DOES_NOT_EXIST,
	                                                   Error.PERMISSION_DENIED,
	                                                   Error.AUTHORIZATION_FAILED,
	                                                   Error.AUTHENTICATION_FAILED,
	                                                   Error.TIMEOUT,
	                                                   Error.NO_SUCCESS;

	public abstract Job get_self () throws Error.NOT_IMPLEMENTED,
	                                       Error.PERMISSION_DENIED,
	                                       Error.AUTHORIZATION_FAILED,
	                                       Error.AUTHENTICATION_FAILED,
	                                       Error.TIMEOUT,
	                                       Error.NO_SUCCESS;
}
