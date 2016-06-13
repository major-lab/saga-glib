public class Saga.JobDescription : Saga.Object, GLib.Object
{
	private uint8 _id[16];

	public string   executable            {}
	public string[] arguments             {}
	public string   spmd_variation        {}
	public int      total_cpu_count       { default = 1; }
	public int      number_of_processes   {}
	public int      processes_per_host    {}
	public string[] environment           {}
	public string   working_directory     { default = "."; }
	public bool     interactive           { default = false; }
	public string   input                 {}
	public string   output                {}
	public string   error                 {}
	public string   file_transfer         {}
	public string   cleanup               { default = "Default"; }
	public int      job_start_time        {}
	public int      wall_time_limit       {}
	public int      total_cpu_time        {}
	public int      total_physical_memory {}
	public string   cpu_architecture      {}
	public string   operating_system_type {}
	public string[] candidate_host        {}
	public string   queue                 {}
	public string   job_project           {}
	public string   job_contact           {}

	public JobDescription () throws Error.NOT_IMPLEMENTED, Error.NO_SUCCESS
	{
		UUID.generate (_id);
	}

	public string get_id ()
	{
		return (string) _id;
	}

	public Session get_session () throws Error.DOES_NOT_EXIST
	{
		throw new Error.DOES_NOT_EXIST ("'JobDescription' objects does not have an attached session.");
	}

}
