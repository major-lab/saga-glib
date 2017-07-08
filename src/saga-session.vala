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

public class Saga.Session : Saga.Object
{
	private static Session? _default = null;

	public static Session get_default ()
	{
		if (_default == null)
			_default = new Session ();
		return _default;
	}

	public override Session get_session ()                   throws Error.DOES_NOT_EXIST
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
