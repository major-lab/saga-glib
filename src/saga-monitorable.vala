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

public interface Saga.Monitorable : Saga.Object
{
	public abstract string[] list_metrics ()                                         throws Error.NOT_IMPLEMENTED,
	                                                                                        Error.PERMISSION_DENIED,
	                                                                                        Error.AUTHORIZATION_FAILED,
	                                                                                        Error.AUTHENTICATION_FAILED,
	                                                                                        Error.TIMEOUT,
	                                                                                        Error.NO_SUCCESS;

	public abstract Metric get_metric (string name)                                  throws Error.NOT_IMPLEMENTED,
	                                                                                        Error.PERMISSION_DENIED,
	                                                                                        Error.AUTHORIZATION_FAILED,
	                                                                                        Error.AUTHENTICATION_FAILED,
	                                                                                        Error.TIMEOUT,
	                                                                                        Error.NO_SUCCESS;

	public virtual async Metric get_metric_async (string name, int priority = GLib.Priority.DEFAULT)
	                                                                                 throws Error.NOT_IMPLEMENTED,
	                                                                                        Error.PERMISSION_DENIED,
	                                                                                        Error.AUTHORIZATION_FAILED,
	                                                                                        Error.AUTHENTICATION_FAILED,
	                                                                                        Error.TIMEOUT,
	                                                                                        Error.NO_SUCCESS
	{
		return get_metric (name);
	}
}
