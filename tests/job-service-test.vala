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

	Test.add_func ("/job_service/torque", () => {
		var job_service = JobService.@new (new Session (), new Saga.URL ("torque://localhost/"));
	});

	return Test.run ();
}
