/**
 * @since 1.0
 */
public class Saga.BackendModule : GLib.TypeModule
{
	private static GLib.HashTable<string, BackendModule>? _backends = null;

	/**
	 * Load a {@link Saga.BackendModule} from a name ensuring that a given
	 * backend is never loaded twice.
	 *
	 * if the 'SAGA_GLIB_BACKEND_PATH' environment variable is specified, this
	 * path will be used instead of system's defaults.
	 *
	 * @since 1.0
	 */
	public static BackendModule new_for_name (string name) throws Error.NO_SUCCESS
	{
		if (_backends == null)
		{
			_backends = new GLib.HashTable<string, BackendModule> (str_hash, str_equal);
		}

		BackendModule module;

		if (name in _backends)
		{
			module = _backends[name];
		}
		else
		{
			module = new BackendModule (Environment.get_variable ("SAGA_GLIB_BACKEND_PATH"), name);

			if (!module.load ())
			{
				throw new Error.NO_SUCCESS ("Could not load backend '%s' from '%s'.", name, module.path);
			}

			_backends[name] = module;
		}

		return module;
	}

	/**
	 * @since 1.0
	 */
	public static BackendModule new_for_url (URL url) throws Error.NO_SUCCESS
	{
		return new_for_name (url.scheme);
	}

	/**
	 * The directory where the backend implementation is to be found, or 'null'
	 * to use system's defaults.
	 *
	 * @since 1.0
	 */
	public string? directory { construct; get; }

	/**
	 * The name of the backend to use.
	 *
	 * @since 1.0
	 */
	public string name { construct; get; }

	/**
	 * The computed path used to retreive the shared library.
	 *
	 * @since 1.0
	 */
	public string path { construct; get; }

	/**
	 * Struct containing types provided by the backend.
	 *
	 * @since 1.0
	 */
	public Saga.BackendTypes types { get; private set; }

	private GLib.Module? module = null;

	/**
	 * @since 1.0
	 */
	public BackendModule (string? directory, string name)
	{
		GLib.Object (directory: directory, name: name);
	}

	construct
	{
		path = GLib.Module.build_path (directory, "saga-glib-%s".printf (name));
	}

	public override bool load ()
	{
		module = GLib.Module.open (path, GLib.ModuleFlags.BIND_LAZY);

		if (module == null)
		{
			critical (Module.error ());
			return false;
		}

		void* func;
		if (!module.symbol ("backend_init", out func))
		{
			critical (Module.error ());
			return false;
		}

		if (func == null)
		{
			return false;
		}

		var _types = ((BackendInitFunc) func) (this);

		if (_types.job_service_type != GLib.Type.INVALID &&
		    !_types.job_service_type.is_a (typeof (JobService)))
		{
			return false;
		}

		types = _types;

		return true;
	}

	public override void unload ()
	{
		module = null;
	}
}
