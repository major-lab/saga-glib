public class Saga.Context : Saga.Object, GLib.Object
{
	private uint8 _id[16];

	/**
	 * Note: Since 'type' is not an acceptable property name, so 'context_type'
	 *       had to be used instead.
	 */
	public string context_type    { get; construct set; }

	public string server          { get; set; }
	public string cert_repository { get; set; }
	public string user_proxy      { get; set; }
	public string user_cert       { get; set; }
	public string user_id         { get; set; }
	public string user_pass       { get; set; }
	public string user_vo         { get; set; }
	public int    lifetime        { get; set; default = -1; }
	public string remote_id       { get; private set; }
	public string remote_host     { get; private set; }
	public uint16 remote_port     { get; private set; }

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
		return (string) _id;
	}

	public Session get_session () throws Error.DOES_NOT_EXIST
	{
		throw new Error.DOES_NOT_EXIST ("'Context' objects do not have attached sessions.");
	}
}
