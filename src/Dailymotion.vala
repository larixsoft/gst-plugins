namespace Video {
	public class Dailymotion : WebVideo {
		public Dailymotion (string uri) {
			this.from_object (dailymotion_object (uri));
		}
		
		public Dailymotion.from_object (Json.Object metadata) {
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
					urls.add ({ node.get_array().get_object_element (0).get_string_member ("url"), q });
			});
			quality = Quality.STANDARD;
		}
	}
}
