public abstract class Saga.TaskContainer : GLib.Object, Saga.Object, Saga.Monitorable
{
	public signal void task_container_state (string task_id);

	public abstract string get_id ();

	public Session get_session ()                                                  throws Error.DOES_NOT_EXIST
	{
		throw new Error.DOES_NOT_EXIST ("'TaskContainer' objects do not have attached session.");
	}

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

	public abstract void add (Task task)                                           throws Error.NOT_IMPLEMENTED,
                                                                                          Error.TIMEOUT,
                                                                                          Error.NO_SUCCESS;

	public abstract void remove (Task task)                                        throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.DOES_NOT_EXIST,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS;

	public abstract void run ()                                                    throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.INCORRECT_STATE,
	                                                                                      Error.DOES_NOT_EXIST,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS;

	public virtual async void run_async (int priority = GLib.Priority.DEFAULT)     throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.INCORRECT_STATE,
	                                                                                      Error.DOES_NOT_EXIST,
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

	public abstract Task wait (WaitMode mode = WaitMode.ALL, double timeout = 0.0) throws Error.NOT_IMPLEMENTED,
                                                                                          Error.INCORRECT_STATE,
                                                                                          Error.DOES_NOT_EXIST,
                                                                                          Error.TIMEOUT,
                                                                                          Error.NO_SUCCESS;

	public virtual async Task wait_async (WaitMode mode = WaitMode.ALL, double timeout = 0.0, int priority = GLib.Priority.DEFAULT)
	                                                                               throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.INCORRECT_STATE,
	                                                                                      Error.DOES_NOT_EXIST,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS
	{
		return wait (mode, timeout);
	}

	public virtual uint size ()                                                    throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS
	{
		return get_tasks ().length;
	}

	public abstract Task get_task (string id)                                      throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.DOES_NOT_EXIST,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS;

	public abstract Task[] get_tasks ()                                            throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS;

	public virtual TaskState[] get_states ()                                       throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS
	{
		TaskState[] states = {};
		foreach (var task in get_tasks ())
		{
			states += task.get_state ();
		}
		return states;
	}
}
