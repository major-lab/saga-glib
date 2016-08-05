public class Saga.Context : GLib.Object, Saga.Object
{
	internal static int compare (Context a, Context b)
	{
		// we use power of 2 to create a unique number for each combination
		return 1    * strcmp (a.context_type, b.context_type)       +
		       2    * strcmp (a.server, b.server)                   +
		       4    * strcmp (a.cert_repository, b.cert_repository) +
		       8    * strcmp (a.user_proxy, b.user_proxy)           +
		       16   * strcmp (a.user_cert, b.user_cert)             +
		       32   * strcmp (a.user_id, b.user_id)                 +
		       64   * strcmp (a.user_pass, b.user_pass)             +
		       128  * strcmp (a.user_vo, b.user_vo)                 +
		       256  * (a.lifetime - b.lifetime).clamp (-1, 1)       +
		       512  * strcmp (a.remote_id, b.remote_id)             +
		       1024 * strcmp (a.remote_host, b.remote_host)         +
		       2048 * (int) (a.remote_port - b.remote_port).clamp (-1, 1);
	}

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
