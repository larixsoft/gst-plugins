namespace Video {
	public class Dailymotion : WebVideo {
		public Dailymotion (string uri) throws GLib.Error {
			var id = uri.split ("/")[uri.split ("/").length - 1].split ("_")[0];
			var stream = new DataInputStream (File.new_for_uri ("http://www.dailymotion.com/embed/video/" + id).read());
			string? line = null;
			while (true) {
				string l = stream.read_line();
				if ("var info = " in l) {
					line = l;
					line = line.substring (line.index_of ("var info = ") + "var info = ".length);
					line = line.substring (0, line.length - 1);
					break;
				}
			}
			if (line == null)
				throw new VideoError.NOT_FOUND ("line info not found.");
			var parser = new MeeJson.Parser();
			parser.load_from_string (line);
			title = (string)parser.root["title"].value;
			uint8[] data;
			File.new_for_uri (((string)parser.root["thumbnail_url"].value).replace ("\\/", "/")).load_contents (null, out data, null);
			picture = new ByteArray.take (data);
			foreach (var prop in parser.root.as_object().properties) {
				if (prop.node_value.is_null())
					continue;
				Quality q = Quality.STANDARD;
				if (prop.identifier == "stream_h264_ld_url")
					q = Quality.LOW;
				else if (prop.identifier == "stream_h264_hq_url")
					q = Quality.HIGH;
				else if (prop.identifier == "stream_h264_url")
					q = Quality.STANDARD;
				else if (prop.identifier == "stream_h264_hd_url")
					q = Quality.HD;
				else if (prop.identifier == "stream_h264_hd1080_url")
					q = Quality.HD2;
				else continue;
				urls.add ({ ((string)prop.value).replace ("\\/", "/"), q });
			}
			if (urls.size == 0)
				throw new VideoError.NOT_FOUND ("no video urls found !");
			quality = Quality.STANDARD;
		}
	}
}
