public class Saga.Session : Saga.Object, GLib.Object
{
	private uint8 _id[16];

	private SList<Context> contexts = new SList<Context> ();

	public Session (bool @default = true) throws Error.NO_SUCCESS {
		UUID.generate (_id);
	}

	public string get_id ()
	{
		return (string) _id;
	}

	public Session get_session () throws Error.DOES_NOT_EXIST
	{
		throw new Error.DOES_NOT_EXIST ("'Session' objects do not have an attached sessions.");
	}

	public void add_context (Context context) throws Error.NO_SUCCESS, Error.TIMEOUT
	{
		contexts.append (context);
	}

	public unowned SList<Context> list_contexts () {
		return contexts;
	}
}
