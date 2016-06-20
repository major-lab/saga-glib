namespace Saga
{
	/**
	 * Initialize a SAGA backend and register releveant class and interfaces.
	 *
	 * Features are loaded with 'out' parameters or left 'null' if not
	 * supported.
	 *
	 * @since 1.0
	 */
	public delegate BackendTypes BackendInitFunc (GLib.TypeModule type_module);
}
