namespace Video {
	public class Uptobox : GLib.Object {
		public Uptobox (string uri) throws GLib.Error {
			notify["quality"].connect (() => {
				for (var i = (int)quality; i >= 0; i--) {
					foreach (var item in urls)
						if ((int)item.quality == i) {
							this.uri = item.url;
							return;
						}
				}
			});
			urls = new Gee.ArrayList<Item?>();
			if (!("uptostream.com" in uri) && !("uptobox.com" in uri))
				throw new VideoError.NOT_FOUND ("invalid URI.");
			var document = new HtmlDocument.from_uri (uri.replace ("uptobox", "uptostream"), HtmlDocument.default_options);
			if (document.get_elements_by_tag_name ("video").size == 0)
				throw new VideoError.NOT_FOUND ("no video element.");
			var video = document.get_elements_by_tag_name ("video")[0] as GXml.xElement;
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
		
		internal Gee.ArrayList<Item?> urls { get; private set; }
		public Quality quality { get; set; }
		public string uri { get; private set; }
	}
}
