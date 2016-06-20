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
	 * Type fot the {@link Saga.JobService} implementation.
	 *
	 * @since 1.0
	 */
	GLib.Type job_service_type;
}

