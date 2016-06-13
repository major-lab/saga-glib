[ModuleInit]
public Type job_init (TypeModule type_module)
{
	return typeof (Saga.TORQUE.JobService);
}

namespace Saga.TORQUE
{
	public class JobService : Saga.JobService
	{
		public JobService (Session session, URL url)
		{
			base (session, url);
		}

		public override Job create_job (JobDescription jd)
		{
			return null;
		}

		public override string[] list ()
		{
			var qstat = new Subprocess (SubprocessFlags.STDOUT_PIPE, "qstat", "-x");

			string stdout_buf;
			string stderr_buf;
			if (qstat.communicate_utf8 (null, null, out stdout_buf, out stderr_buf))
			{
				// TODO: decode xml..
				return {};
			}
			else
			{
				throw new Error.NO_SUCCESS ("Could not retreive the job identifiers");
			}
		}

		public override Job get_job (string id)
		{
			// TODO
			return null;
		}

		public override Job get_self () throws Error.NOT_IMPLEMENTED
		{
			throw new Error.NOT_IMPLEMENTED ("The 'TORQUE' backend is not managed using a job.");
		}
	}
}
