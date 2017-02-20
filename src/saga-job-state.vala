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

public enum Saga.JobState
{
	NEW       = 1,
	RUNNING   = 2,
	DONE      = 3,
	CANCELED  = 4,
	FAILED    = 5,
	SUSPENDED = 6
}
