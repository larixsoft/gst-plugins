public class Decryptor : GLib.Object {
	string js;
	string decrypt_method;
	
	public Decryptor (string js_url) {
		uint8[] data;
		File.new_for_uri (js_url).load_contents (null, out data, null);
		var stream = new DataInputStream (new MemoryInputStream.from_data (data, null));
		string line = null;
		while ((line = stream.read_line()) != null) {
			if (".sig||" in line) {
				decrypt_method = line.split (".sig||")[2].split ("(")[0];
				break;
			}
		}
		stream = new DataInputStream (new MemoryInputStream.from_data (data, null));
		line = null;
		string method = null;
		while ((line = stream.read_line()) != null) {
			if (line.has_prefix ("var " + decrypt_method)) {
				js = line.substring (0, line.index_of ("};") + 2);
				method = line.split (";")[1].split (".")[0];
				break;
			}
		}
		line = (string)data;
		line = line.substring (line.index_of ("var " + method));
		js += line.substring (0, 2 + line.index_of ("};"));
	}
	
	public string decrypt (string signature) {
		var real_js = js + "var signature = %s('%s'); print (signature);".printf (decrypt_method, signature);
		return eval_js (real_js);
	}
	
	string eval_js (string js) {
		FileIOStream stream;
		var file = File.new_tmp ("XXXXXX", out stream);
		stream.output_stream.write (js.data);
		string output; string err;
		Process.spawn_command_line_sync ("gjs %s".printf (file.get_path()), out output, out err, null);
		return output;
	}
}
