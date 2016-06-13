public abstract class Saga.Module : GLib.TypeModule
{
	private GLib.Module? module = null;

	protected abstract get_symbol ();

	public override bool load ()
	{
		return false;
	}

	public override void unload ()
	{
		module = null;
	}
}
