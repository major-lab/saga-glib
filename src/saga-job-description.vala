public class Saga.JobDescription : GLib.Object, Saga.Object
{
	public string          executable            { get; set; default = "";    }
	public string[]        arguments             { get; set; default = {};    }
	public string?         spmd_variation        { get; set; default = null;  }
	public int             total_cpu_count       { get; set; default = 1;     }
	public int             number_of_processes   { get; set; default = 1;     }
	public int             processes_per_host    { get; set; default = 1;     }
	public int             threads_per_process   { get; set; default = 1;     }
	public string[]        environment           { get; set; default = {};    }
	public string          working_directory     { get; set; default = ".";   }
	public bool            interactive           { get; set; default = false; }
	public string?         input                 { get; set; default = null;  }
	public string?         output                { get; set; default = null;  }
	public string?         error                 { get; set; default = null;  }
	public FileTransfer[]  file_transfer         { get; set; default = {};    }
	public bool?           cleanup               { get; set; default = null;  }
	public GLib.DateTime?  job_start_time        { get; set; default = null;  }
	public GLib.TimeSpan?  wall_time_limit       { get; set; default = null;  }
	public GLib.TimeSpan?  total_cpu_time        { get; set; default = null;  }
	public int?            total_physical_memory { get; set; default = null;  }
	public string?         cpu_architecture      { get; set; default = null;  }
	public string?         operating_system_type { get; set; default = null;  }
	public string[]        candidate_hosts       { get; set; default = {};    }
	public string?         queue                 { get; set; default = null;  }
	public string?         job_project           { get; set; default = null;  }
	public URL[]           job_contact           { get; set; default = {};    }

	construct
	{
		UUID.generate (_id);
	}

	private uint8 _id[16];

	public string get_id ()
	{
		char @out[37];
		UUID.unparse (_id, @out);
		return (string) @out;
	}

	public Session get_session () throws Error.DOES_NOT_EXIST
	{
		throw new Error.DOES_NOT_EXIST ("'JobDescription' objects does not have an attached session.");
	}
}
