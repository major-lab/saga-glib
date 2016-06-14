public abstract class Saga.Job : Saga.Object, Saga.Permissions, GLib.Object
{
	// attributes
	// TODO: check how they are set individually
	public string             job_id          { get; construct; }
	public string             service_url     { get; private set; }
	public string             execution_hosts { get; private set; }
	public GLib.DateTime      created         { get; private set; }
	public GLib.DateTime      started         { get; private set; }
	public GLib.DateTime      finished        { get; private set; }
	public int                exit_code       { get; private set; }
	public GLib.ProcessSignal term_sig        { get; private set; }

	// metrics
	public signal void job_state        (string             state);
	public signal void job_state_detail (string             state_detail);
	public signal void job_signal       (GLib.ProcessSignal sig);
	public signal void job_cpu_time     (int                second);
	public signal void job_memory_use   (float              megabyte);
	public signal void job_vmemory_use  (float              megabyte);
	public signal void job_performance  (float              flops);

	public abstract string get_id ();

	public abstract Session get_session () throws Error.DOES_NOT_EXIST;

	public abstract void permissions_allow (string id, Permission perm)            throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.BAD_PARAMETER,
	                                                                                      Error.PERMISSION_DENIED,
	                                                                                      Error.AUTHORIZATION_FAILED,
	                                                                                      Error.AUTHENTICATION_FAILED,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS;

	public abstract void permissions_deny (string id, Permission perm)             throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.BAD_PARAMETER,
	                                                                                      Error.PERMISSION_DENIED,
	                                                                                      Error.AUTHORIZATION_FAILED,
	                                                                                      Error.AUTHENTICATION_FAILED,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS;

	public abstract bool permissions_check (string id, Permission perm)            throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.BAD_PARAMETER,
	                                                                                      Error.PERMISSION_DENIED,
	                                                                                      Error.AUTHORIZATION_FAILED,
	                                                                                      Error.AUTHENTICATION_FAILED,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS;

	public abstract string get_group ()                                            throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.BAD_PARAMETER,
	                                                                                      Error.PERMISSION_DENIED,
	                                                                                      Error.AUTHORIZATION_FAILED,
	                                                                                      Error.AUTHENTICATION_FAILED,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS;

	public abstract string get_owner ()                                            throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.BAD_PARAMETER,
	                                                                                      Error.PERMISSION_DENIED,
	                                                                                      Error.AUTHORIZATION_FAILED,
	                                                                                      Error.AUTHENTICATION_FAILED,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS;

	public abstract JobDescription get_job_description ()                          throws Error.NOT_IMPLEMENTED,
                                                                                          Error.DOES_NOT_EXIST,
                                                                                          Error.PERMISSION_DENIED,
                                                                                          Error.AUTHORIZATION_FAILED,
                                                                                          Error.AUTHENTICATION_FAILED,
                                                                                          Error.TIMEOUT,
                                                                                          Error.NO_SUCCESS;

	public abstract OutputStream get_stdin ()                                      throws Error.NOT_IMPLEMENTED,
                                                                                          Error.DOES_NOT_EXIST,
                                                                                          Error.PERMISSION_DENIED,
                                                                                          Error.AUTHORIZATION_FAILED,
                                                                                          Error.AUTHENTICATION_FAILED,
                                                                                          Error.TIMEOUT,
                                                                                          Error.NO_SUCCESS;

	public abstract InputStream get_stdout ()                                      throws Error.NOT_IMPLEMENTED,
                                                                                          Error.DOES_NOT_EXIST,
                                                                                          Error.PERMISSION_DENIED,
                                                                                          Error.AUTHORIZATION_FAILED,
                                                                                          Error.AUTHENTICATION_FAILED,
                                                                                          Error.TIMEOUT,
                                                                                          Error.NO_SUCCESS;

	public abstract InputStream get_stderr ()                                      throws Error.NOT_IMPLEMENTED,
                                                                                          Error.DOES_NOT_EXIST,
                                                                                          Error.PERMISSION_DENIED,
                                                                                          Error.AUTHORIZATION_FAILED,
                                                                                          Error.AUTHENTICATION_FAILED,
                                                                                          Error.TIMEOUT,
                                                                                          Error.NO_SUCCESS;

	public abstract void suspend ()                                                throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.INCORRECT_STATE,
	                                                                                      Error.PERMISSION_DENIED,
	                                                                                      Error.AUTHORIZATION_FAILED,
	                                                                                      Error.AUTHENTICATION_FAILED,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS;

	public virtual async void suspend_async (int priority = GLib.Priority.DEFAULT) throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.INCORRECT_STATE,
	                                                                                      Error.PERMISSION_DENIED,
	                                                                                      Error.AUTHORIZATION_FAILED,
	                                                                                      Error.AUTHENTICATION_FAILED,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS
	{
		suspend ();
	}

	public abstract void resume ()                                                 throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.INCORRECT_STATE,
	                                                                                      Error.PERMISSION_DENIED,
	                                                                                      Error.AUTHORIZATION_FAILED,
	                                                                                      Error.AUTHENTICATION_FAILED,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS;

	public virtual async void resume_async (int priority = GLib.Priority.DEFAULT)  throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.INCORRECT_STATE,
	                                                                                      Error.PERMISSION_DENIED,
	                                                                                      Error.AUTHORIZATION_FAILED,
	                                                                                      Error.AUTHENTICATION_FAILED,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS
	{
		resume ();
	}

	public abstract void checkpoint ()                                             throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.INCORRECT_STATE,
	                                                                                      Error.PERMISSION_DENIED,
	                                                                                      Error.AUTHORIZATION_FAILED,
	                                                                                      Error.AUTHENTICATION_FAILED,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS;

	public virtual void checkpoint_async (int priority = GLib.Priority.DEFAULT)    throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.INCORRECT_STATE,
	                                                                                      Error.PERMISSION_DENIED,
	                                                                                      Error.AUTHORIZATION_FAILED,
	                                                                                      Error.AUTHENTICATION_FAILED,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS
	{
		checkpoint ();
	}

	public abstract void migrate (JobDescription jd)                               throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.INCORRECT_STATE,
	                                                                                      Error.PERMISSION_DENIED,
	                                                                                      Error.AUTHORIZATION_FAILED,
	                                                                                      Error.AUTHENTICATION_FAILED,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS;

	public virtual async void migrate_async (JobDescription jd, int priority = GLib.Priority.DEFAULT)
	                                                                               throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.INCORRECT_STATE,
	                                                                                      Error.PERMISSION_DENIED,
	                                                                                      Error.AUTHORIZATION_FAILED,
	                                                                                      Error.AUTHENTICATION_FAILED,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS
	{
		migrate (jd);
	}

	public abstract void @signal (GLib.ProcessSignal signum)                       throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.INCORRECT_STATE,
	                                                                                      Error.PERMISSION_DENIED,
	                                                                                      Error.AUTHORIZATION_FAILED,
	                                                                                      Error.AUTHENTICATION_FAILED,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS;

	public async virtual void signal_async (GLib.ProcessSignal signum, int priority = GLib.Priority.DEFAULT)
	                                                                               throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.INCORRECT_STATE,
	                                                                                      Error.PERMISSION_DENIED,
	                                                                                      Error.AUTHORIZATION_FAILED,
	                                                                                      Error.AUTHENTICATION_FAILED,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS
	{
		@signal (signum);
	}
}
