public class Decryptor : GLib.Object {
	string cr;
	string dr;
	
	public Decryptor() {
		dr = """var dr={m5:function(a,b){a.splice(0,b)}, N0:function(a,b){var c=a[0];a[0]=a[b%a.length];a[b]=c}, Pe:function(a){a.reverse()}};""";
		cr = """var cr=function(a){a=a.split("");dr.N0(a,26);dr.m5(a,3);dr.Pe(a,0);dr.m5(a,3);dr.Pe(a,16);dr.m5(a,3);dr.N0(a,61);dr.m5(a,3);dr.Pe(a,9);return a.join("")};""";
	}
	
	public string decrypt (string signature) {
		string js = dr + cr + "var signature = cr('%s'); print (signature);".printf (signature);
		return eval_js (js);
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
