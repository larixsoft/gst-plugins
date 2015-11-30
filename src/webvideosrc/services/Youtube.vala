namespace Video {
	public class Youtube : WebVideo {
		public Youtube (MeeGst.Uri url) {
			base();
			var video_id = url.parameters["v"];
			uint8[] data;
			var document = new GXml.HtmlDocument.from_uri ("http://www.youtube.com/watch?v=" + video_id, GXml.HtmlDocument.default_options);
			foreach (var meta in document.get_elements_by_tag_name ("meta")) {
				var e = meta as GXml.xElement;
				if (e.get_attribute ("property") == "og:title")
					title = e.get_attribute ("content");
				if (e.get_attribute ("property") == "og:image") {
					File.new_for_uri (e.get_attribute ("content")).load_contents (null, out data, null);
					picture = new ByteArray.take (data);
				}
			}
			File.new_for_uri ("https://www.youtube.com/get_video_info?sts=1588&asv=3&hl=en&gl=US&el=detailpage&video_id=" + video_id + "&eurl=https%3A%2F%2Fyoutube.googleapis.com%2Fv%2F" + video_id).load_contents (null, out data, null);
			string _map = ((string)data).split ("url_encoded_fmt_stream_map=")[1].split ("&")[0];
			_map =  GLib.Uri.unescape_string (_map);
			if (_map != null) {
				Decryptor dec = new Decryptor();
				string[] map = _map.split (",");
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
							signature = "&signature=" + dec.decrypt (t2);
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
		}
	}
}
