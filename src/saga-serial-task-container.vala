public class Saga.SerialTaskContainer : Saga.TaskContainer
{
	private SList<Task> _tasks = new SList<Task> ();

	construct
	{
		UUID.generate (_id);
	}

	private uint8 _id[16];

	public override string get_id ()
	{
		char @out[37];
		UUID.unparse (_id, @out);
		return (string) @out;
	}

	public override string[] list_metrics ()
	{
		return {"task_container.state"};
	}

	public override Metric get_metric (string name)                                     throws Error.NOT_IMPLEMENTED
	{
		throw new Error.NOT_IMPLEMENTED ("");
	}

	public override void add (Task task)
	{
		_tasks.append (task);
	}

	public override void remove (Task task)
	{
		_tasks.remove (task);
	}

	public override void run ()                                                         throws Error.NOT_IMPLEMENTED,
	                                                                                           Error.INCORRECT_STATE,
	                                                                                           Error.DOES_NOT_EXIST,
	                                                                                           Error.TIMEOUT,
	                                                                                           Error.NO_SUCCESS
	{
		foreach (var task in _tasks)
		{
			task.run ();
		}
	}

	public override async void run_async (int priority = GLib.Priority.DEFAULT)         throws Error.NOT_IMPLEMENTED,
	                                                                                           Error.INCORRECT_STATE,
	                                                                                           Error.DOES_NOT_EXIST,
	                                                                                           Error.TIMEOUT,
                                                                                               Error.NO_SUCCESS
	{
		foreach (var task in _tasks)
		{
			yield task.run_async (priority);
		}
	}

	public override void cancel (double timeout = 0.0)                                  throws Error.NOT_IMPLEMENTED,
                                                                                               Error.INCORRECT_STATE,
                                                                                               Error.TIMEOUT,
                                                                                               Error.NO_SUCCESS
	{
		foreach (var task in _tasks)
		{
			task.cancel (timeout);
		}
	}

	public override async void cancel_async (double timeout = 0.0, int priority = GLib.Priority.DEFAULT)
	                                                                                    throws Error.NOT_IMPLEMENTED,
                                                                                               Error.INCORRECT_STATE,
                                                                                               Error.TIMEOUT,
                                                                                               Error.NO_SUCCESS
	{
		foreach (var task in _tasks)
		{
			yield task.cancel_async (timeout, priority);
		}
	}

	public override Task wait (WaitMode wait_mode = WaitMode.ALL, double timeout = 0.0) throws Error.NOT_IMPLEMENTED,
                                                                                               Error.INCORRECT_STATE,
                                                                                               Error.DOES_NOT_EXIST,
                                                                                               Error.TIMEOUT,
                                                                                               Error.NO_SUCCESS
	{
		if (_tasks == null)
		{
			throw new Error.DOES_NOT_EXIST ("");
		}

		// TODO: wait_mode
		foreach (var task in _tasks)
		{
			task.wait ();
		}

		return _tasks.data;
	}

	public override async Task wait_async (WaitMode wait_mode = WaitMode.ALL,
	                                       double   timeout   = 0.0,
	                                       int      priority  = GLib.Priority.DEFAULT)  throws Error.NOT_IMPLEMENTED,
                                                                                               Error.INCORRECT_STATE,
                                                                                               Error.DOES_NOT_EXIST,
                                                                                               Error.TIMEOUT,
                                                                                               Error.NO_SUCCESS
	{
		if (_tasks == null)
		{
			throw new Error.DOES_NOT_EXIST ("");
		}

		// TODO: wait_mode
		foreach (var task in _tasks)
		{
			yield task.wait_async (timeout, priority);
		}

		return _tasks.data;
	}

	public override uint size ()
	{
		return _tasks.length ();
	}

	public override Task get_task (string id)
	{
		return _tasks.search<string> (id, (a, b) => { return strcmp (a.get_id (), b); }).data;
	}

	public override Task[] get_tasks ()
	{
		return {};
	}
}
