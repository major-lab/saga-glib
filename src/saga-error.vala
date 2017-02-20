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

public errordomain Saga.Error
{
	INCORRECT_URL         = 1,
	BAD_PARAMETER         = 2,
	ALREADY_EXISTS        = 3,
	DOES_NOT_EXIST        = 4,
	INCORRECT_STATE       = 5,
	INCORRECT_TYPE        = 6,
	PERMISSION_DENIED     = 7,
	AUTHORIZATION_FAILED  = 8,
	AUTHENTICATION_FAILED = 9,
	TIMEOUT               = 10,
	NO_SUCCESS            = 11,
	NOT_IMPLEMENTED       = 12
}

