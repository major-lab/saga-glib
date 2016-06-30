public class Saga.Context : GLib.Object, Saga.Object
{
	private uint8 _id[16];

	/**
	 * Note: Since 'type' is not an acceptable property name, so 'context_type'
	 *       had to be used instead.
	 */
	public string context_type    { get; construct set;     }
	public string server          { get; set;               }
	public string cert_repository { get; set;               }
	public string user_proxy      { get; set;               }
	public string user_cert       { get; set;               }
	public string user_id         { get; set;               }
	public string user_pass       { get; set;               }
	public string user_vo         { get; set;               }
	public int    lifetime        { get; set; default = -1; }
	public string remote_id       { get; set;               }
	public string remote_host     { get; set;               }
	public uint   remote_port     { get; set;               }

	public Context (string type) throws Error.INCORRECT_STATE,
	                                    Error.TIMEOUT,
	                                    Error.NO_SUCCESS
	{
		GLib.Object (context_type: type);
	}

	construct
	{
		UUID.generate (_id);
	}

	public string get_id ()
	{
		char @out[37];
		UUID.unparse (_id, @out);
		return (string) @out;
	}

	public Session get_session () throws Error.DOES_NOT_EXIST
	{
		throw new Error.DOES_NOT_EXIST ("'Context' objects do not have attached sessions.");
	}
}
