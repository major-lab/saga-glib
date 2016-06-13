public class Saga.JobModule : Saga.Module
{
	public override bool load ();

	public override void unload ()
	{
		module = null;
	}
}
