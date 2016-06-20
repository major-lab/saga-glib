public class Saga.JobDescription : Saga.Object, GLib.Object
{
	public string          executable            { get; construct set; default = "";    }
	public string[]        arguments             { get; construct set; default = {};    }
	public string?         spmd_variation        { get; construct set; default = null;  }
	public int             total_cpu_count       { get; construct set; default = 1;     }
	public int             number_of_processes   { get; construct set; default = 1;     }
	public int             processes_per_host    { get; construct set; default = 1;     }
	public int             threads_per_process   { get; construct set; default = 1;     }
	public string[]        environment           { get; construct set; default = {};    }
	public string          working_directory     { get; construct set; default = ".";   }
	public bool            interactive           { get; construct set; default = false; }
	public string?         input                 { get; construct set; default = null;  }
	public string?         output                { get; construct set; default = null;  }
	public string?         error                 { get; construct set; default = null;  }
	public FileTransfer[]  file_transfer         { get; set;           default = {};    }
	public bool?           cleanup               { get; set;           default = null;  }
	public GLib.DateTime?  job_start_time        { get; set;           default = null;  }
	public int?            wall_time_limit       { get; set;           default = null;  }
	public int?            total_cpu_time        { get; set;           default = null;  }
	public int?            total_physical_memory { get; set;           default = null;  }
	public string?         cpu_architecture      { get; construct set; default = null;  }
	public string?         operating_system_type { get; construct set; default = null;  }
	public string[]        candidate_hosts       { get; construct set; default = {};    }
	public string?         queue                 { get; construct set; default = null;  }
	public string?         job_project           { get; construct set; default = null;  }
	public URL[]           job_contact           { get; set;           default = {};    }

	public JobDescription ()      throws Error.NOT_IMPLEMENTED,
	                                     Error.NO_SUCCESS
	{

	}

	construct
	{
		UUID.generate (_id);
	}

	private uint8 _id[16];

	public string get_id ()
	{
		return (string) _id;
	}

	public Session get_session () throws Error.DOES_NOT_EXIST
	{
		throw new Error.DOES_NOT_EXIST ("'JobDescription' objects does not have an attached session.");
	}

}
