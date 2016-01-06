namespace Video {
	public enum Quality {
		NONE,
		LOW,
		STANDARD,
		HIGH,
		HD,
		HD2
	}
	
	public errordomain VideoError {
		NULL,
		INVALID,
		NOT_FOUND
	}
	
	public struct Item {
		public string url;
		public Quality quality;
	}
	
	public class WebVideo : GLib.Object {
		construct {
			notify["quality"].connect (() => {
				for (var i = (int)quality; i >= 0; i--) {
					foreach (var item in urls)
						if ((int)item.quality == i && "video%2Fmp4" in item.url) {
							this.uri = item.url;
							return;
						}
				}
			});
			urls = new Gee.ArrayList<Item?>();
		}
		
		internal Gee.ArrayList<Item?> urls { get; private set; }
		public ByteArray picture { get; protected set; }
		public Quality quality { get; set; }
		
		public string artist { get; protected set; }
		public string title { get; protected set; }
		public string uri { get; private set; }
		
		public static WebVideo? guess (string location) {
			if (uri_is_valid_youtube (location)) {
				var url = new MeeGst.Uri (location);
				if (location.has_prefix ("youtube://"))
					url = new MeeGst.Uri ("https://www.youtube.com/watch?v=" + location.split ("/")[2]);
				return new Youtube (url);
			}
			var md = dailymotion_object (location);
			if (!md.has_member ("error"))
				return new Dailymotion.from_object (md);
			return null;
		}
		
		public static bool uri_is_valid_youtube (string uri) {
			var url = new MeeGst.Uri (uri);
			if (uri.has_prefix ("youtube://"))
				url = new MeeGst.Uri ("https://www.youtube.com/watch?v=" + uri.split ("/")[2]);
			var video_id = url.parameters["v"];
			if (video_id == null)
				return false;
			uint8[] data;
			File.new_for_uri ("https://www.youtube.com/get_video_info?sts=1588&asv=3&hl=en&gl=US&el=detailpage&video_id=" + video_id + "&eurl=https%3A%2F%2Fyoutube.googleapis.com%2Fv%2F" + video_id).load_contents (null, out data, null);
			var fake_uri = new MeeGst.Uri ("http://toto.com?" + (string)data);
			if ("errorcode" in fake_uri.parameters)
				return false;
			return true;
		}
		
		public static Json.Object dailymotion_object (string uri) {
			var id = uri.split ("/")[uri.split ("/").length - 1].split ("_")[0];
			uint8[] data;
			File.new_for_uri ("http://www.dailymotion.com/embed/video/" + id).load_contents (null, out data, null);
			var locator = "('player'), ";
			string json = ((string)data).substring (((string)data).index_of (locator) + locator.length);
			json = json.substring (0, json.index_of (");"));
			var parser = new Json.Parser();
			parser.load_from_data (json);
			return parser.get_root().get_object().get_object_member ("metadata");
		}
		
		public static bool uri_is_valid (string uri) {
			if (!(uri.has_prefix ("youtube://") || "youtube.com" in uri || "youtu.be" in uri))
				return false;
			if (uri_is_valid_youtube (uri))
				return true;
			var md = dailymotion_object (uri);
			if (!md.has_member ("error"))
				return true;
			return true;
		}
	}
}
