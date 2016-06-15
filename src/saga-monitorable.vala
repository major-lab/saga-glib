public interface Saga.Monitorable : Saga.Object
{
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

	public abstract void monitor ()                                                throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.PERMISSION_DENIED,
	                                                                                      Error.AUTHORIZATION_FAILED,
	                                                                                      Error.AUTHENTICATION_FAILED,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS;

	public virtual async void monitor_async (int priority = GLib.Priority.DEFAULT) throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.PERMISSION_DENIED,
	                                                                                      Error.AUTHORIZATION_FAILED,
	                                                                                      Error.AUTHENTICATION_FAILED,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS
	{
		monitor ();
	}
}
