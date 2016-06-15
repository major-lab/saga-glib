public class Saga.URL : Saga.Object, GLib.Object
{
	public string scheme   { get; set; }
	public string host     { get; set; }
	public uint16 port     { get; set; }
	public string fragment { get; set; }
	public string path     { get; set; }
	public string query    { get; set; }
	public string userinfo { get; set; }

	public URL (string url) throws Error.BAD_PARAMETER,
	                               Error.NO_SUCCESS
	{
		set_string (url);
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

	public Session get_session () throws Error.DOES_NOT_EXIST
	{
		throw new Error.DOES_NOT_EXIST ("'URI' objects do not have attached sessions.");
	}

	public string get_string ()
	{
		return "%s://%s@%s:%u%s?%s#%s".printf (scheme, userinfo, host, port, path, query, fragment);
	}

	public void set_string (string url) throws Error.BAD_PARAMETER
	{
		// TODO
		scheme = GLib.Uri.parse_scheme (url);
	}

	public string get_escaped ()
	{
		return GLib.Uri.escape_string (get_string ());
	}

	public URL translate (Session s, string? scheme = null) throws Error.BAD_PARAMETER,
	                                                               Error.NO_SUCCESS
	{
		// TODO
		return new URL (get_string ());
	}
}
