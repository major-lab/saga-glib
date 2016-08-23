public class Saga.URL : GLib.Object, Saga.Object
{
	private static GLib.Regex url_regex = /^\w+:\/\/((?<userinfo>.+)@)?(?<host>[^:^?^#^\/]+)(:(?<port>\d+))?(?<path>\/[^?^#]*)?(\?(?<query>[^#]*))?(#(?<fragment>.*))?$/;

	public string  scheme   { get; set;                 }
	public string  host     { get; set;                 }
	public uint?   port     { get; set; default = null; }
	public string? fragment { get; set; default = null; }
	public string  path     { get; set; default = "/";  }
	public string? query    { get; set; default = null; }
	public string? userinfo { get; set; default = null; }

	public URL (string url)                                 throws Error.BAD_PARAMETER,
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
		char @out[37];
		UUID.unparse (_id, @out);
		return (string) @out;
	}

	public Session get_session ()                           throws Error.DOES_NOT_EXIST
	{
		throw new Error.DOES_NOT_EXIST ("'URI' objects do not have attached sessions.");
	}

	public string get_string ()
	{
		var str = new StringBuilder ();

		str.append_printf ("%s://", scheme);

		if (userinfo != null)
			str.append_printf ("%s@", userinfo);

		str.append (host);

		if (port != null)
			str.append_printf (":%u", port);

		if (path.has_prefix ("/"))
		{
			str.append (path);
		}
		else
		{
			str.append_printf ("/%s", path);
		}

		if (query != null)
			str.append_printf ("?%s", GLib.Uri.escape_string (query));

		if (fragment != null)
			str.append_printf ("#%s", GLib.Uri.escape_string (fragment));

		return str.str;
	}

	public void set_string (string url)                     throws Error.BAD_PARAMETER
	{
		GLib.MatchInfo match_info;
		if (url_regex.match (url, 0, out match_info))
		{
			scheme   = GLib.Uri.parse_scheme (url);
			host     = match_info.fetch_named ("host");
			if (match_info.fetch_named ("port") == null)
			{
				port = null;
			}
			else
			{
				port = (uint) int.parse (match_info.fetch_named ("port"));
			}
			fragment = match_info.fetch_named ("fragment") == null ? null : GLib.Uri.unescape_string (match_info.fetch_named ("fragment"));
			path     = GLib.Uri.unescape_string (match_info.fetch_named ("path")) ?? "/";
			query    = match_info.fetch_named ("query") == null ? null : GLib.Uri.unescape_string (match_info.fetch_named ("query"));
			userinfo = match_info.fetch_named ("userinfo");
		}
		else
		{
			throw new Error.BAD_PARAMETER ("The specified URL is not valid.");
		}
	}

	public string get_escaped ()
	{
		return GLib.Uri.escape_string (get_string ());
	}

	public URL translate (Session? s, string scheme) throws Error.BAD_PARAMETER,
	                                                        Error.NO_SUCCESS
	{
		// TODO: check scheme compatibility with backends
		return new URL (get_string ().splice (0, this.scheme.length - 1, scheme));
	}
}
