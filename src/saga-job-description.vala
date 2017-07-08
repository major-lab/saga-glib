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

public class Saga.JobDescription : Saga.Object
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

	public override Session get_session () throws Error.DOES_NOT_EXIST
	{
		throw new Error.DOES_NOT_EXIST ("'JobDescription' objects does not have an attached session.");
	}
}
