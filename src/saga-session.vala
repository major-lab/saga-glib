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
		unowned SList<Context> node = _contexts.search<Context> (context, (a, b) => {
			// we use power of 2 to create a unique number for each combination
			return        strcmp (a.context_type, b.context_type)       +
			       2    * strcmp (a.server, b.server)                   +
			       4    * strcmp (a.cert_repository, b.cert_repository) +
			       8    * strcmp (a.user_proxy, b.user_proxy)           +
			       16   * strcmp (a.user_cert, b.user_cert)             +
			       32   * strcmp (a.user_id, b.user_id)                 +
			       64   * strcmp (a.user_pass, b.user_pass)             +
			       128  * strcmp (a.user_vo, b.user_vo)                 +
			       256  * (a.lifetime - b.lifetime)                     +
			       512  * strcmp (a.remote_id, b.remote_id)             +
			       1024 * strcmp (a.remote_host, b.remote_host)         +
			       2048 * (int) (a.remote_port - b.remote_port);
		});

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
