namespace Video {
	public class Uptobox : WebVideo {
		public Uptobox (string uri) throws GLib.Error {
			if (!("uptostream.com" in uri) && !("uptobox.com" in uri))
				throw new VideoError.NOT_FOUND ("invalid URI.");
			var document = new HtmlDocument.from_uri (uri.replace ("uptobox", "uptostream"), HtmlDocument.default_options);
			if (document.get_elements_by_tag_name ("video").size == 0)
				throw new VideoError.NOT_FOUND ("no video element.");
			var video = document.get_elements_by_tag_name ("video")[0] as GXml.xElement;
			title = (document.get_elements_by_tag_name ("title")[0] as GXml.xElement).content;
			if (video.get_attribute ("poster") != null) {
				uint8[] data;
				File.new_for_uri (video.get_attribute ("poster")).load_contents (null, out data, null);
				picture = new ByteArray.take (data);
			}
			foreach (var source in document.get_elements_by_tag_name ("source")) {
				Quality q = Quality.STANDARD;
				if ((source as GXml.xElement).get_attribute ("data-res") == "480p")
					q = Quality.HIGH;
				if ((source as GXml.xElement).get_attribute ("data-res") == "720p")
					q = Quality.HD;
				urls.add ({ (source as GXml.xElement).get_attribute ("src"), q });
			}
			if (urls.size == 0 && video.get_attribute ("src") != null)
				urls.add ({ video.get_attribute ("src"), Quality.STANDARD });
			if (urls.size == 0)
				throw new VideoError.NOT_FOUND ("no video source in document.");
			quality = Quality.STANDARD;
		}
	}
}
