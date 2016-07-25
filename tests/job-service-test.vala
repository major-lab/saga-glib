using GLib;
using Saga;

public int main (string[] args)
{
	Test.init (ref args);

	Test.add_func ("/job_service/torque", () => {
		var job_service = JobService.@new (new Session (), new Saga.URL ("torque://localhost/"));
	});

	return Test.run ();
}
