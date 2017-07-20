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
using Saga;

public int main (string[] args)
{
	Test.init (ref args);

	Test.add_func ("/job_service/local", () => {
		var job_service = JobService.@new (new Session (), new Saga.URL ("local://"));

		var jd = new JobDescription ();

		jd.executable = "true";

		Job job;
		try
		{
			job = job_service.create_job (jd);
		}
		catch (Saga.Error err)
		{
			assert_not_reached ();
		}
		assert (TaskState.NEW == job.get_state ());

		try
		{
			assert (job == job_service.get_job (job.job_id));
		}
		catch (Saga.Error err)
		{
			assert_not_reached ();
		}

		try
		{
			job.run ();
		}
		catch (Saga.Error err)
		{
			assert_not_reached ();
		}
		assert (TaskState.RUNNING == job.get_state ());

		try
		{
			job.wait ();
		}
		catch (Saga.Error err)
		{
			assert_not_reached ();
		}
		assert (TaskState.DONE == job.get_state ());
		assert (0 == job.get_result ());
	});

	Test.add_func ("/job_service/torque/job-array", () => {
		if (Environment.get_variable ("SAGA_GLIB_JOB_SERVICE_TORQUE_URL") == null)
		{
			Test.skip ("Set the 'SAGA_GLIB_JOB_SERVICE_TORQUE_URL' environment variable to run this test.");
			return;
		}

		var job_service = JobService.@new (new Session (),
		                                   new Saga.URL (Environment.get_variable ("SAGA_GLIB_JOB_SERVICE_TORQUE_URL")));

		var jd = new JobDescription ();

		jd.executable = "true";
		jd.number_of_processes = 8;

		try
		{
			var job = job_service.create_job (jd);
			job.run ();
			assert (0 == job.get_result ());
			assert (TaskState.DONE == job.get_state ());
		}
		catch (Saga.Error err)
		{
			assert_not_reached ();
		}
	});

	return Test.run ();
}
