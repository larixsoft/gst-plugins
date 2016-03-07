namespace Video {
	public class Dailymotion : WebVideo {
		string id;
		
		public Dailymotion (string uri) {
			id = uri.split ("/")[uri.split ("/").length - 1].split ("_")[0];
			uint8[] data;
			File.new_for_uri ("http://www.dailymotion.com/embed/video/" + id).load_contents (null, out data, null);
			var locator = "('player'), ";
			string json = ((string)data).substring (((string)data).index_of (locator) + locator.length);
			json = json.substring (0, json.index_of (");"));
			var parser = new Json.Parser();
			parser.load_from_data (json);
			var metadata = parser.get_root().get_object().get_object_member ("metadata");
			title = metadata.get_string_member ("title");
			File.new_for_uri (metadata.get_string_member ("poster_url").replace ("\\/", "/")).load_contents (null, out data, null);
			picture = new ByteArray.take (data);
		}
		
		public override Gee.List<Item?> load_urls() {
			var urls = new Gee.ArrayList<Item?>();
			uint8[] data;
			File.new_for_uri ("http://www.dailymotion.com/embed/video/" + id).load_contents (null, out data, null);
			var locator = "('player'), ";
			string json = ((string)data).substring (((string)data).index_of (locator) + locator.length);
			json = json.substring (0, json.index_of (");"));
			var parser = new Json.Parser();
			parser.load_from_data (json);
			var metadata = parser.get_root().get_object().get_object_member ("metadata");
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
					urls.add ({ node.get_array().get_object_element (0).get_string_member ("url"), q });
			});
			return urls;
		}
	}
}
