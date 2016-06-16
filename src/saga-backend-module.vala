public class Saga.BackendModule : GLib.TypeModule
{
	public string? directory { construct; get; }

	public string name { construct; get; }

	public string path { construct; get; }

	public GLib.Type? job_service_type { get; private set; default = null; }

	/**
	 * It should be marked as 'protected', but we don't want it exposed in the
	 * binding as it would require 'gmodule-2.0' publicly.
	 */
	private GLib.Module? module = null;

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
		module = Module.open (path, GLib.ModuleFlags.BIND_LAZY);

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

		Type? _job_service_type;
		((BackendInitFunc) func) (this, out _job_service_type);

		if (_job_service_type.is_a (typeof (JobService)))
		{
			job_service_type = _job_service_type;
		}
		else
		{
			return false;
		}

		return true;
	}

	public override void unload ()
	{
		module = null;
	}
}
