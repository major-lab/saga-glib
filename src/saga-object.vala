public interface Saga.Object : GLib.Object
{
	public abstract string get_id ();
	public abstract Session get_session () throws Error.DOES_NOT_EXIST;
}
