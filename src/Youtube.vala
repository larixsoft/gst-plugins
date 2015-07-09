namespace Video {
	public class Youtube : WebVideo {
		public Youtube (string uri) throws GLib.Error {
			var url = new MeeGst.Uri (uri);
			if ("youtu.be" in uri)
				url = new MeeGst.Uri ("http://www.youtube.com/watch?v=" + uri.split ("/")[uri.split ("/").length - 1]);
			if (url.parameters["v"] == null)
				throw new VideoError.NOT_FOUND ("video id not found");
			var video_id = url.parameters["v"];
			uint8[] data;
			var document = new HtmlDocument.from_uri ("http://www.youtube.com/watch?v=" + video_id, HtmlDocument.default_options);
			title = (document.get_elements_by_tag_name ("title")[0] as GXml.xElement).content;
			File.new_for_uri ("https://i.ytimg.com/vi/" + video_id + "/mqdefault.jpg").load_contents (null, out data, null);
			picture = new ByteArray.take (data);
			File.new_for_uri ("http://www.youtube.com/watch?v=" + url.parameters["v"]).load_contents (null, out data, null);
			var table = ((string)data).split("\"");
			string? _map = null;
			string? js_url = null;
			for (var i = 0; i < table.length; i++) {
				if (table[i] == "url_encoded_fmt_stream_map")
					_map = table[i+2];
				if (table[i] == "js")
					js_url = "http:" + table[i+2].replace ("\\/", "/");
			}
			if (_map == null) {
				string ruri = @"https://www.youtube.com/get_video_info?sts=1588&asv=3&hl=en&gl=US&el=embedded&video_id=$video_id&eurl=https%3A%2F%2Fyoutube.googleapis.com%2Fv%2F$video_id";
				File.new_for_uri (ruri).load_contents (null, out data, null);
				url = new MeeGst.Uri ("http://www.dummy.com?" + (string)data);
				if (url.parameters["url_encoded_fmt_stream_map"] != null)
					_map = GLib.Uri.unescape_string (url.parameters["url_encoded_fmt_stream_map"]);
			}
			if (_map == null)
				throw new VideoError.NOT_FOUND ("youtube map not found.");
			string[] map = _map.replace ("\\u0026", "&").split (",");
			foreach (string s in map) {
				string[] t = s.split ("&");
				string _quality = "";
				string u = "";
				string? signature = null;
				foreach (var val in t) {
					var t1 = val.split ("=")[0];
					var t2 = val.split ("=")[1];
					if (t1 == "sig")
						signature = "&signature=" + t2;
					if (t1 == "s") {
						if (js_url == null)
							return;
						signature = "&signature=" + descramble (t2, js_url);
					}
					if (t1 == "quality")
						_quality = t2;
					if (t1 == "url")
						u = GLib.Uri.unescape_string (t2);
				}
				Quality q = Quality.NONE;
				if(_quality == "hd1080")
					q = Quality.HD2;
				else if(_quality == "hd720")
					q = Quality.HD;
				else if(_quality == "large")
					q = Quality.HIGH;
				else if(_quality == "medium")
					q = Quality.STANDARD;
				else if(_quality == "small")
					q = Quality.LOW;
				urls.add ({ u + signature, q });
			}
			quality = Quality.STANDARD;
		}
		
		string descramble (string signature, string js_url) throws GLib.Error {
			string sig = signature;
			var stream = new DataInputStream (File.new_for_uri (js_url).read());
			string? descrambler = null;
			Gee.ArrayList<string> lines = new Gee.ArrayList<string>();
			while (descrambler == null) {
				string? line = stream.read_line();
				if (line == null)
					error ("can't read line.");
				lines.add (line);
				// Youtube change signature function symbol.
				if (!(".sig||" in line))
					continue;
				descrambler = line.substring (line.index_of (".sig||", line.index_of (".sig||") + 1) + ".sig||".length);
				descrambler = descrambler.substring (0, descrambler.index_of ("("));
			}
			string? trans = null;
			string? fn = null;
			for (var i = 0; i < lines.size; i++)
				if ("function %s(".printf (descrambler) in lines[i]) {
					trans = lines[i].split ("function %s(".printf (descrambler))[0];
					trans = trans.substring (trans.last_index_of ("={") + 2);
					var map = new Gee.HashMap<string,string>();
					foreach (var s in trans.split ("},")) {
						var t = s.split(":function");
						if (".splice" in t[1])
							map[t[0]] = "splice";
						if (".reverse" in t[1])
							map[t[0]] = "reverse";
						if ("var c=" in t[1])
							map[t[0]] = "swap";
					}
					fn = "function %s(".printf (descrambler) + lines[i].split ("function %s(".printf (descrambler))[1].split (";function")[0];
					var fns = fn.split (");");
					for (var j = 1; j < fns.length - 1; j++) {
						int k = int.parse (fns[j].substring (fns[j].last_index_of (",") + 1));
						string meth = fns[j].substring (fns[j].index_of (".") + 1);
						meth = meth.substring (0, meth.index_of ("("));
						if (map[meth] == "reverse")
							sig = sig.reverse();
						if (map[meth] == "swap") {
							uint8[] data = sig.data;
							uint8 u = data[0];
							data[0] = data[k % data.length];
							data[k] = u;
							sig = (string)data;
						}
						if (map[meth] == "splice") {
							uint8[] array = sig.data;
							int len = array.length;
							array.move (k, 0, len - k);
							sig = (string)array;
						}
					}
				}
			return sig;
		}
	}
}
