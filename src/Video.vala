static extern Type youtube_src_real_type();
static extern Type uptobox_src_real_type();

namespace Video {	
	public static bool init (Gst.Plugin plugin) {
		if (!Gst.Element.register (plugin, "youtubesrc", 1024, youtube_src_real_type()))
			return false;
		if (!Gst.Element.register (plugin, "uptoboxsrc", 1024, uptobox_src_real_type()))
			return false;
		return true;
	}
	
	public errordomain VideoError {
		NULL,
		INVALID,
		NOT_FOUND
	}
	
	public enum Quality {
		NONE,
		LOW,
		STANDARD,
		HIGH,
		HD,
		HD2
	}
	
	public struct Item {
		public string url;
		public Quality quality;
	}
	
	public class WebVideo : GLib.Object {
		internal Gee.ArrayList<Item?> urls { get; private set; }
		public Quality quality { get; set; }
		public string uri { get; private set; }
		public string title { get; set; }
		public ByteArray picture { get; set; }
		
		construct {
			urls = new Gee.ArrayList<Item?>();
			notify["quality"].connect (() => {
				for (var i = (int)quality; i >= 0; i--) {
					foreach (var item in urls)
						if ((int)item.quality == i) {
							this.uri = item.url;
							return;
						}
				}
			});
		}
	}
}

