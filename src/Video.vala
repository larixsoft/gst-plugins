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
		
		public static WebVideo? guess (string uri) {
			try {
				return new Youtube (uri);
			} catch {
				try {
					return new Dailymotion (uri);
				} catch {
					return null;
				}
			}
		}
	}
}
