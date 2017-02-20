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

/**
 * Struct containing all {@link GLib.Type} provided by a backend.
 *
 * If a specific feature is not to be provided, the {@link GLib.Type.INVALID}
 * has to be used as placeholder.
 *
 * @since 1.0
 */
public struct Saga.BackendTypes
{
	/**
	 * Type for the {@link Saga.JobService} implementation.
	 *
	 * @since 1.0
	 */
	GLib.Type job_service_type;
	/**
	 * @since 1.0
	 */
	GLib.Type stream_server_type;
	/**
	 * @since 1.0
	 */
	GLib.Type file_type;
	/**
	 * @since 1.0
	 */
	GLib.Type logical_file_type;
	/**
	 * @since 1.0
	 */
	GLib.Type stream_type;
	/**
	 * @since 1.0
	 */
	GLib.Type rpc_type;
}

