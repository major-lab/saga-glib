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

public class Saga.Metric : Saga.Object
{
	public string     name        { get; construct; }
	public string     description { get; construct; }
	public string     mode        { get; construct; }
	public string     unit        { get; construct; }
	public GLib.Value @value      { get; construct; }

	public Metric (string name, string description, string mode, string unit, GLib.Value @value)
	{
		GLib.Object (name: name, description: description, mode: mode, unit: unit, @value: @value);
	}

	public override Session get_session () throws Error.DOES_NOT_EXIST
	{
		throw new Error.DOES_NOT_EXIST ("'Metric' objects do not have an attached session.");
	}
}
