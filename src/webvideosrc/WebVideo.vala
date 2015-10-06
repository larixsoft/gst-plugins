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
						if ((int)item.quality == i) {
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
		public string title { get; protected set; }
		public string uri { get; private set; }
		
		public static bool uri_is_valid (string uri) {
			return ("://uptobox.com" in uri || "://uptostream.com" in uri ||
				"youtube.com" in uri || "youtu.be" in uri || 
				"dailymotion" in uri);
		}
		
		public static WebVideo? guess (string uri) {
			if ("://uptobox.com" in uri || "://uptostream.com" in uri)
				return new Uptobox (uri);
			var url = new MeeGst.Uri (uri);
			if (uri.has_prefix ("youtube://"))
				url = new MeeGst.Uri ("http://www.youtube.com/watch?v=" + uri.split ("youtube://")[1]);
			else if ("youtu.be" in uri)
				url = new MeeGst.Uri ("http://www.youtube.com/watch?v=" + uri.split ("/")[uri.split ("/").length - 1]);
			if ("youtube.com" in uri || "youtu.be" in uri || uri.has_prefix ("youtube://"))
				if (url.parameters["v"] == null)
					return null;
				else
					return new Youtube (url);
			if ("dailymotion" in uri)
				return new Dailymotion (uri);
			return null;
		}
	}
}
