interface Saga.Permissions : Saga.Object
{
	public abstract void permissions_allow (string id, Saga.Permission perm) throws Error.NOT_IMPLEMENTED,
	                                                                       Error.BAD_PARAMETER,
	                                                                       Error.PERMISSION_DENIED,
	                                                                       Error.AUTHORIZATION_FAILED,
	                                                                       Error.AUTHENTICATION_FAILED,
	                                                                       Error.TIMEOUT,
	                                                                       Error.NO_SUCCESS;

	public abstract void permissions_deny (string id, Saga.Permission perm) throws Error.NOT_IMPLEMENTED,
	                                                                      Error.BAD_PARAMETER,
	                                                                      Error.PERMISSION_DENIED,
	                                                                      Error.AUTHORIZATION_FAILED,
	                                                                      Error.AUTHENTICATION_FAILED,
	                                                                      Error.TIMEOUT,
	                                                                      Error.NO_SUCCESS;

	public abstract bool permissions_check (string id, Saga.Permission perm) throws Error.NOT_IMPLEMENTED,
	                                                                       Error.BAD_PARAMETER,
	                                                                       Error.PERMISSION_DENIED,
	                                                                       Error.AUTHORIZATION_FAILED,
	                                                                       Error.AUTHENTICATION_FAILED,
	                                                                       Error.TIMEOUT,
	                                                                       Error.NO_SUCCESS;

	public abstract string get_group () throws Error.NOT_IMPLEMENTED,
	                                           Error.BAD_PARAMETER,
	                                           Error.PERMISSION_DENIED,
	                                           Error.AUTHORIZATION_FAILED,
	                                           Error.AUTHENTICATION_FAILED,
	                                           Error.TIMEOUT,
	                                           Error.NO_SUCCESS;

	public abstract string get_owner () throws Error.NOT_IMPLEMENTED,
	                                           Error.BAD_PARAMETER,
	                                           Error.PERMISSION_DENIED,
	                                           Error.AUTHORIZATION_FAILED,
	                                           Error.AUTHENTICATION_FAILED,
	                                           Error.TIMEOUT,
	                                           Error.NO_SUCCESS;
}
