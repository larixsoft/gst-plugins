public class UptoboxSrc : VideoSrc {
	class construct {
		set_static_metadata ("UtpboxSrc", "Video", "Uptobox source element", "Yannick Inizan <inizan.yannick@gmail.com>");
	}
	
	construct {
		notify["location"].connect (() => {
			try {
				if (location != null)
					video = new Video.Uptobox (location);
			} catch {
			
			}
		});
	}
	
	// URIHandler section
	
	public string? get_uri() {
		return location;
	}
	
	public bool set_uri (string uri) throws GLib.Error {
		try {
			var yt = new Video.Uptobox (uri);
			location = uri;
			return true;
		} catch {
			return false;
		}
	}
	
	[CCode (array_length = false, array_null_terminated = true)]
	public static string[]? get_protocols (GLib.Type gtype) {
		return new string[]{"http", "https"};
	}
	
	public static Gst.URIType get_type_uri (GLib.Type gtype) {
		return Gst.URIType.SRC;
	}
}
