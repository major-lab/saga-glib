public class Saga.Metric : Saga.Object, GLib.Object
{
	public string     name        { get; construct; }
	public string     description { get; construct; }
	public string     mode        { get; construct; }
	public string     unit        { get; construct; }
	public GLib.Value @value      { get; construct; }

	public Metric (string name, string description, string mode, string unit, GLib.Value @value)
	{
		GLib.Object (name: name, description: description, mode: mode, unit: unit, @value: @value);
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
		throw new Error.DOES_NOT_EXIST ("'Metric' objects do not have an attached session.");
	}
}
