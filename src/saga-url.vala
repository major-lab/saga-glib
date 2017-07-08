/* Copyright 2016 Guillaume Poirier-Morency <guillaumepoiriermorency@gmail.com>
 *
 * This file is part of SAGA-GLib.
 *
 * SAGA-GLib is free software: you can redistribute it and/or modify it under the
 * terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) any
 * later version.
 *
 * SAGA-GLib is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with SAGA-GLib.  If not, see <http://www.gnu.org/licenses/>.
 */

public class Saga.URL : Saga.Object
{
	private static GLib.Regex url_regex = /^(?<scheme>.+):\/\/(?:(?<userinfo>.+?)@)?(?:(?<host>.+?)(?::(?<port>.+?))?)?(?<path>\/.*?)?(?:\?(?<query>.*?))?(?:#(?<fragment>.*))?$/;

	public string  scheme   { get; set;                 }
	public string? host     { get; set; default = null; }
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

	public override Session get_session ()                  throws Error.DOES_NOT_EXIST
	{
		throw new Error.DOES_NOT_EXIST ("'URI' objects do not have attached sessions.");
	}

	public string get_string ()
	{
		var str = new StringBuilder ();

		str.append_printf ("%s://", scheme);

		if (userinfo != null)
			str.append_printf ("%s@", userinfo);

		if (host != null)
		{
			str.append (host);

			if (port != null)
				str.append_printf (":%u", port);
		}

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
			scheme = match_info.fetch_named ("scheme");
			host   = match_info.fetch_named ("host") == null ? null : match_info.fetch_named ("host");

			if (match_info.fetch_named ("port") == null)
			{
				port = null;
			}
			else
			{
				uint64 port_u64;
				if (uint64.try_parse (match_info.fetch_named ("port"), out port_u64))
				{
					port = (uint) port_u64;
				}
				else
				{
					throw new Error.BAD_PARAMETER ("The specific port '%s' is invalid.", match_info.fetch_named ("port"));
				}
			}

			fragment = match_info.fetch_named ("fragment") == null ? null : GLib.Uri.unescape_string (match_info.fetch_named ("fragment"));
			path     = GLib.Uri.unescape_string (match_info.fetch_named ("path")) ?? "/";
			query    = match_info.fetch_named ("query") == null ? null : GLib.Uri.unescape_string (match_info.fetch_named ("query"));
			userinfo = match_info.fetch_named ("userinfo");
		}
		else
		{
			throw new Error.BAD_PARAMETER ("The specified URL is invalid.");
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
