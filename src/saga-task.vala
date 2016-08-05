public abstract class Saga.Task<T> : GLib.Object, Saga.Object, Saga.Monitorable
{
	public signal void task_state (TaskState state);

	public abstract string get_id ();

	public abstract Session get_session ()                                         throws Error.DOES_NOT_EXIST;

	public abstract string[] list_metrics ()                                       throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.PERMISSION_DENIED,
	                                                                                      Error.AUTHORIZATION_FAILED,
	                                                                                      Error.AUTHENTICATION_FAILED,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS;

	public abstract Metric get_metric (string name)                                throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.PERMISSION_DENIED,
	                                                                                      Error.AUTHORIZATION_FAILED,
	                                                                                      Error.AUTHENTICATION_FAILED,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS;

	public abstract void run ()                                                    throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.INCORRECT_STATE,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS;

	public virtual async void run_async (int priority = GLib.Priority.DEFAULT)     throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.INCORRECT_STATE,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS
	{
		run ();
	}

	public abstract void cancel (double timeout = 0.0)                             throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.INCORRECT_STATE,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS;

	public virtual async void cancel_async (double timeout = 0.0, int priority = GLib.Priority.DEFAULT)
	                                                                               throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.INCORRECT_STATE,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS
	{
		cancel (timeout);
	}

	public abstract void wait (double timeout = 0.0)                               throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.INCORRECT_STATE,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS;

	public virtual async void wait_async (double timeout  = 0.0,
	                                      int    priority = GLib.Priority.DEFAULT) throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.INCORRECT_STATE,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS
	{
		wait (timeout);
	}

	public abstract TaskState get_state ()                                         throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS;

	public virtual async TaskState get_state_async (int priority = GLib.Priority.DEFAULT)
	                                                                               throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS
	{
		return get_state ();
	}

	public abstract T get_result ()                                                throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.INCORRECT_URL,
	                                                                                      Error.BAD_PARAMETER,
	                                                                                      Error.ALREADY_EXISTS,
	                                                                                      Error.DOES_NOT_EXIST,
	                                                                                      Error.INCORRECT_STATE,
	                                                                                      Error.INCORRECT_TYPE,
	                                                                                      Error.PERMISSION_DENIED,
	                                                                                      Error.AUTHORIZATION_FAILED,
	                                                                                      Error.AUTHENTICATION_FAILED,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS;

	public virtual async T get_result_async (int priority = GLib.Priority.DEFAULT) throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.INCORRECT_URL,
	                                                                                      Error.BAD_PARAMETER,
	                                                                                      Error.ALREADY_EXISTS,
	                                                                                      Error.DOES_NOT_EXIST,
	                                                                                      Error.INCORRECT_STATE,
	                                                                                      Error.INCORRECT_TYPE,
	                                                                                      Error.PERMISSION_DENIED,
	                                                                                      Error.AUTHORIZATION_FAILED,
	                                                                                      Error.AUTHENTICATION_FAILED,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS
	{
		return get_result ();
	}
}
