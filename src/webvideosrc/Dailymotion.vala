namespace Video {
	public class Dailymotion : WebVideo {
		public Dailymotion (string uri) {
			var id = uri.split ("/")[uri.split ("/").length - 1].split ("_")[0];
			var stream = new DataInputStream (File.new_for_uri ("http://www.dailymotion.com/embed/video/" + id).read());
			string? line = null;
			var locator = "('player'), ";
			while (true) {
				string l = stream.read_line();
				if (l == null)
					break;
				if (locator in l) {
					line = l;
					line = line.substring (line.index_of (locator) + locator.length);
					line = line.substring (0, line.length - 2);
					break;
				}
			}
			if (line == null)
				return;
			var parser = new Json.Parser();
			parser.load_from_data (line);
			var metadata = parser.get_root().get_object().get_object_member ("metadata");
			title = metadata.get_string_member ("title");
			uint8[] data;
			File.new_for_uri (metadata.get_string_member ("poster_url").replace ("\\/", "/")).load_contents (null, out data, null);
			picture = new ByteArray.take (data);
			metadata.get_object_member ("qualities").foreach_member ((object, name, node) => {
				Quality q = Quality.STANDARD;
				if (name == "240")
					q = Quality.LOW;
				else if (name == "380")
					q = Quality.STANDARD;
				else if (name == "480")
					q = Quality.HIGH;
				else if (name == "720")
					q = Quality.HD;
				else if (name == "1080")
					q = Quality.HD2;
				else return;
				if (node.get_array().get_length() > 0)
					urls.add ({ node.get_array().get_object_element (0).get_string_member ("url").replace ("\\/", "/"), q });
			});
			quality = Quality.STANDARD;
		}
	}
}
