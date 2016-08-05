/**
 * Struct containing all {@link GLib.Type} provided by a backend.
 *
 * If a specific feature is not to be provided, the {@link GLib.Type.INVALID}
 * has to be used as placeholder.
 *
 * @since 1.0
 */
public struct Saga.BackendTypes
{
	/**
	 * Type for the {@link Saga.JobService} implementation.
	 *
	 * @since 1.0
	 */
	GLib.Type job_service_type;
	/**
	 * @since 1.0
	 */
	GLib.Type stream_server_type;
	/**
	 * @since 1.0
	 */
	GLib.Type file_type;
	/**
	 * @since 1.0
	 */
	GLib.Type logical_file_type;
	/**
	 * @since 1.0
	 */
	GLib.Type stream_type;
	/**
	 * @since 1.0
	 */
	GLib.Type rpc_type;
}

