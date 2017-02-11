public class Descrambler : GLib.Object {
	string js;
	string method;
	
	public Descrambler (string url) throws GLib.Error {
		string js_url = url;
		if (js_url[0] == '/')
			js_url = "https://www.youtube.com" + url;
		uint8[] data;
		File.new_for_uri (js_url).load_contents (null, out data, null);
		var stream = new DataInputStream (new MemoryInputStream.from_data (data, null));
		string line = null;
		while ((line = stream.read_line()) != null) {
			if ("(f.s)" in line) {
				method = line.split ("(f.s)")[0];
				method = method.substring (method.length - 2);
				break;
			}
		}
		if (method == null)
			throw new IOError.NOT_FOUND ("method n°1 not found.");
		stream = new DataInputStream (new MemoryInputStream.from_data (data, null));
		line = null;
		while ((line = stream.read_line()) != null) {
			if ((method + "=function(") in line) {
				js = "var " + line + "\n";
			}
		}
		if (js == null)
			throw new IOError.NOT_FOUND ("method n°2 not found.");
		string method2 = js.split (";")[1].split (".")[0];
		string js_data = (string)data;
		string njs = js_data.substring (js_data.index_of ("var " + method2));
		js += njs.substring (0, njs.index_of ("}};") + 3) + "\n";
	}
	
	public string decrypt (string signature) {
		var real_js = js + "var signature = %s('%s'); console.log (signature);".printf (method, signature);
		return eval_js (real_js);
	}
	
	static string eval_js (string js) {
		FileIOStream stream;
		var file = File.new_tmp ("XXXXXX", out stream);
		stream.output_stream.write (js.data);
		string output; string err;
		Process.spawn_command_line_sync ("nodejs %s".printf (file.get_path()), out output, out err, null);
		file.delete();
		return output;
	}
	
	public string to_string() {
		return js;
	}
}
