public class Saga.Session : GLib.Object, Saga.Object
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
		char @out[37];
		UUID.unparse (_id, @out);
		return (string) @out;
	}

	public Session get_session ()                   throws Error.DOES_NOT_EXIST
	{
		throw new Error.DOES_NOT_EXIST ("'Session' objects do not have an attached sessions.");
	}

	private SList<Context> _contexts = new SList<Context> ();

	public void add_context (owned Context context) throws Error.NO_SUCCESS, Error.TIMEOUT
	{
		_contexts.append (context);
	}

	public void remove_context (Context context) throws Error.DOES_NOT_EXIST
	{
		unowned SList<Context> node = _contexts.search<Context> (context, context.compare);

		if (node == null)
		{
			throw new Error.DOES_NOT_EXIST ("");
		}

		_contexts.remove_link (node);
	}

	public (unowned Context)[] list_contexts ()
	{
		(unowned Context)[] contexts = {};
		foreach (var context in _contexts)
		{
			contexts += context;
		}
		return contexts;
	}
}
