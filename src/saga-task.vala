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

public abstract class Saga.Task<T> : Saga.Object, Saga.Monitorable
{
	public signal void task_state (TaskState state);

	public abstract string[] list_metrics ()                                       throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.PERMISSION_DENIED,
	                                                                                      Error.AUTHORIZATION_FAILED,
	                                                                                      Error.AUTHENTICATION_FAILED,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS;

	public abstract Metric get_metric (string name)                                throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.PERMISSION_DENIED,
	                                                                                      Error.AUTHORIZATION_FAILED,
	                                                                                      Error.AUTHENTICATION_FAILED,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS;

	public abstract void run ()                                                    throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.INCORRECT_STATE,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS;

	public virtual async void run_async (int priority = GLib.Priority.DEFAULT)     throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.INCORRECT_STATE,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS
	{
		run ();
	}

	public abstract void cancel (double timeout = 0.0)                             throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.INCORRECT_STATE,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS;

	public virtual async void cancel_async (double timeout = 0.0, int priority = GLib.Priority.DEFAULT)
	                                                                               throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.INCORRECT_STATE,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS
	{
		cancel (timeout);
	}

	public abstract void wait (double timeout = 0.0)                               throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.INCORRECT_STATE,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS;

	public virtual async void wait_async (double timeout  = 0.0,
	                                      int    priority = GLib.Priority.DEFAULT) throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.INCORRECT_STATE,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS
	{
		wait (timeout);
	}

	public abstract TaskState get_state ()                                         throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS;

	public virtual async TaskState get_state_async (int priority = GLib.Priority.DEFAULT)
	                                                                               throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS
	{
		return get_state ();
	}

	public abstract T get_result ()                                                throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.INCORRECT_URL,
	                                                                                      Error.BAD_PARAMETER,
	                                                                                      Error.ALREADY_EXISTS,
	                                                                                      Error.DOES_NOT_EXIST,
	                                                                                      Error.INCORRECT_STATE,
	                                                                                      Error.INCORRECT_TYPE,
	                                                                                      Error.PERMISSION_DENIED,
	                                                                                      Error.AUTHORIZATION_FAILED,
	                                                                                      Error.AUTHENTICATION_FAILED,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS;

	public virtual async T get_result_async (int priority = GLib.Priority.DEFAULT) throws Error.NOT_IMPLEMENTED,
	                                                                                      Error.INCORRECT_URL,
	                                                                                      Error.BAD_PARAMETER,
	                                                                                      Error.ALREADY_EXISTS,
	                                                                                      Error.DOES_NOT_EXIST,
	                                                                                      Error.INCORRECT_STATE,
	                                                                                      Error.INCORRECT_TYPE,
	                                                                                      Error.PERMISSION_DENIED,
	                                                                                      Error.AUTHORIZATION_FAILED,
	                                                                                      Error.AUTHENTICATION_FAILED,
	                                                                                      Error.TIMEOUT,
	                                                                                      Error.NO_SUCCESS
	{
		return get_result ();
	}
}
