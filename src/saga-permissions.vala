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

public interface Saga.Permissions : Saga.Object
{
	public abstract void permissions_allow (string id, Permission perm) throws Error.NOT_IMPLEMENTED,
	                                                                           Error.BAD_PARAMETER,
	                                                                           Error.PERMISSION_DENIED,
	                                                                           Error.AUTHORIZATION_FAILED,
	                                                                           Error.AUTHENTICATION_FAILED,
	                                                                           Error.TIMEOUT,
	                                                                           Error.NO_SUCCESS;

	public abstract void permissions_deny (string id, Permission perm)  throws Error.NOT_IMPLEMENTED,
	                                                                           Error.BAD_PARAMETER,
	                                                                           Error.PERMISSION_DENIED,
	                                                                           Error.AUTHORIZATION_FAILED,
	                                                                           Error.AUTHENTICATION_FAILED,
	                                                                           Error.TIMEOUT,
	                                                                           Error.NO_SUCCESS;

	public abstract bool permissions_check (string id, Permission perm) throws Error.NOT_IMPLEMENTED,
	                                                                           Error.BAD_PARAMETER,
	                                                                           Error.PERMISSION_DENIED,
	                                                                           Error.AUTHORIZATION_FAILED,
	                                                                           Error.AUTHENTICATION_FAILED,
	                                                                           Error.TIMEOUT,
	                                                                           Error.NO_SUCCESS;

	public abstract string get_group ()                                 throws Error.NOT_IMPLEMENTED,
	                                                                           Error.BAD_PARAMETER,
	                                                                           Error.PERMISSION_DENIED,
	                                                                           Error.AUTHORIZATION_FAILED,
	                                                                           Error.AUTHENTICATION_FAILED,
	                                                                           Error.TIMEOUT,
	                                                                           Error.NO_SUCCESS;

	public abstract string get_owner ()                                 throws Error.NOT_IMPLEMENTED,
	                                                                           Error.BAD_PARAMETER,
	                                                                           Error.PERMISSION_DENIED,
	                                                                           Error.AUTHORIZATION_FAILED,
	                                                                           Error.AUTHENTICATION_FAILED,
	                                                                           Error.TIMEOUT,
	                                                                           Error.NO_SUCCESS;
}
