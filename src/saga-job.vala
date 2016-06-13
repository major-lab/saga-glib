public abstract class Saga.Job : Saga.Object, GLib.Object
{
	// attributes
	// TODO: check how they are set individually
	public string             job_id          { get; private set; }
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

	public abstract Session get_session ();

	public abstract JobDescription get_job_description () throws Error.NOT_IMPLEMENTED,
                                                                 Error.DOES_NOT_EXIST,
                                                                 Error.PERMISSION_DENIED,
                                                                 Error.AUTHORIZATION_FAILED,
                                                                 Error.AUTHENTICATION_FAILED,
                                                                 Error.TIMEOUT,
                                                                 Error.NO_SUCCESS;

	public abstract OutputStream get_stdin () throws Error.NOT_IMPLEMENTED,
                                                     Error.DOES_NOT_EXIST,
                                                     Error.PERMISSION_DENIED,
                                                     Error.AUTHORIZATION_FAILED,
                                                     Error.AUTHENTICATION_FAILED,
                                                     Error.TIMEOUT,
                                                     Error.NO_SUCCESS;

	public abstract InputStream get_stdout () throws Error.NOT_IMPLEMENTED,
                                                     Error.DOES_NOT_EXIST,
                                                     Error.PERMISSION_DENIED,
                                                     Error.AUTHORIZATION_FAILED,
                                                     Error.AUTHENTICATION_FAILED,
                                                     Error.TIMEOUT,
                                                     Error.NO_SUCCESS;

	public abstract InputStream get_stderr () throws Error.NOT_IMPLEMENTED,
                                                     Error.DOES_NOT_EXIST,
                                                     Error.PERMISSION_DENIED,
                                                     Error.AUTHORIZATION_FAILED,
                                                     Error.AUTHENTICATION_FAILED,
                                                     Error.TIMEOUT,
                                                     Error.NO_SUCCESS;

	public abstract void suspend () throws Error.NOT_IMPLEMENTED,
	                              Error.INCORRECT_STATE,
	                              Error.PERMISSION_DENIED,
	                              Error.AUTHORIZATION_FAILED,
	                              Error.AUTHENTICATION_FAILED,
	                              Error.TIMEOUT,
	                              Error.NO_SUCCESS;

	public abstract void resume () throws Error.NOT_IMPLEMENTED,
	                                      Error.INCORRECT_STATE,
	                                      Error.PERMISSION_DENIED,
	                                      Error.AUTHORIZATION_FAILED,
	                                      Error.AUTHENTICATION_FAILED,
	                                      Error.TIMEOUT,
	                                      Error.NO_SUCCESS;

	public abstract void checkpoint () throws Error.NOT_IMPLEMENTED,
	                                          Error.INCORRECT_STATE,
	                                          Error.PERMISSION_DENIED,
	                                          Error.AUTHORIZATION_FAILED,
	                                          Error.AUTHENTICATION_FAILED,
	                                          Error.TIMEOUT,
	                                          Error.NO_SUCCESS;

	public abstract void migrate (JobDescription jd) throws Error.NOT_IMPLEMENTED,
	                                               Error.INCORRECT_STATE,
	                                               Error.PERMISSION_DENIED,
	                                               Error.AUTHORIZATION_FAILED,
	                                               Error.AUTHENTICATION_FAILED,
	                                               Error.TIMEOUT,
	                                               Error.NO_SUCCESS;

	public abstract void @signal (int signum) throws Error.NOT_IMPLEMENTED,
	                                        Error.INCORRECT_STATE,
	                                        Error.PERMISSION_DENIED,
	                                        Error.AUTHORIZATION_FAILED,
	                                        Error.AUTHENTICATION_FAILED,
	                                        Error.TIMEOUT,
	                                        Error.NO_SUCCESS;
}
