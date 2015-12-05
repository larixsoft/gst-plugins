namespace Video {
	public class Uptobox : WebVideo {
		public Uptobox (string uri) {
			string url = uri.replace ("uptobox.com", "uptostream.com");
			var document = new Mxml.HtmlDocument.from_uri (url, Mxml.HtmlDocument.default_options);
			title = document.get_element_by_id ("titleVid").content.strip();
			var video = document.get_elements_by_tag_name ("video")[0];
			var img_url = video.attributes["poster"];
			uint8[] data;
			File.new_for_uri (img_url).load_contents (null, out data, null);
			picture = new ByteArray.take (data);
			video.get_elements_by_tag_name ("source").foreach (source => {
				Quality q = Quality.LOW;
				if (source.attributes["data-res"] == "360p")
					q = Quality.STANDARD;
				if (source.attributes["data-res"] == "480p")
					q = Quality.HIGH;
				if (source.attributes["data-res"] == "720p")
					q = Quality.HD;
				if (source.attributes["data-res"] == "1080p")
					q = Quality.HD2;
				urls.add ({ source.attributes["src"], q });
				return true;
			});
			quality = Quality.STANDARD;
		}
	}
}
