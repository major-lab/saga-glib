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

	public virtual async Metric get_metric_async (string name, int priority = GLib.Priority.DEFAULT)
	                                                                               throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.PERMISSION_DENIED,
	                                                                                      Error.AUTHORIZATION_FAILED,
	                                                                                      Error.AUTHENTICATION_FAILED,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS
	{
		return get_metric (name);
	}
}
