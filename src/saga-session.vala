public class Saga.Session : Saga.Object, GLib.Object
{
	private static Session? _default = null;

	public static Session get_default ()
	{
		if (_default == null)
			_default = new Session ();
		return _default;
	}

	construct
	{
		UUID.generate (_id);
	}

	private uint8 _id[16];

	public string get_id ()
	{
		return (string) _id;
	}

	public Session get_session ()             throws Error.DOES_NOT_EXIST
	{
		throw new Error.DOES_NOT_EXIST ("'Session' objects do not have an attached sessions.");
	}

	private SList<Context> contexts = new SList<Context> ();

	public void add_context (Context context) throws Error.NO_SUCCESS, Error.TIMEOUT
	{
		contexts.append (context);
	}

	public unowned SList<Context> list_contexts () {
		return contexts;
	}
}
