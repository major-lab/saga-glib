using GLib;

public int main (string[] args)
{
	Test.init (ref args);

	Test.add_func ("/url", () => {
		try
		{
			var str = "scheme://userinfo@host:80/path?query#fragment";
			var url = new Saga.URL (str);
			assert ("scheme" == url.scheme);
			assert ("userinfo" == url.userinfo);
			assert ("host" == url.host);
			assert (80 == url.port);
			assert ("/path" == url.path);
			assert ("query" == url.query);
			assert ("fragment" == url.fragment);
			message (url.get_string ());
			assert (str == url.get_string ());
		}
		catch (Error err)
		{
			message (err.message);
			assert_not_reached ();
		}
	});

	Test.add_func ("/url/mailto", () => {
		var url = new Saga.URL ("mailto://johndoe@example.com");
		assert ("mailto" == url.scheme);
		assert ("johndoe" == url.userinfo);
		assert ("example.com" == url.host);
		assert ("/" == url.path);
	});

	return Test.run ();
}
