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

using GLib;

public int main (string[] args)
{
	Test.init (ref args);

	Test.add_func ("/url", () => {
		try
		{
			var str = "scheme://userinfo@host:80/path?query#fragment";
			var url = new Saga.URL (str);
			assert ("scheme" == url.scheme);
			assert ("userinfo" == url.userinfo);
			assert ("host" == url.host);
			assert (80 == url.port);
			assert ("/path" == url.path);
			assert ("query" == url.query);
			assert ("fragment" == url.fragment);
			message (url.get_string ());
			assert (str == url.get_string ());
		}
		catch (Error err)
		{
			message (err.message);
			assert_not_reached ();
		}
	});

	Test.add_func ("/url/mailto", () => {
		var url = new Saga.URL ("mailto://johndoe@example.com");
		assert ("mailto" == url.scheme);
		assert ("johndoe" == url.userinfo);
		assert ("example.com" == url.host);
		assert ("/" == url.path);
	});

	return Test.run ();
}
