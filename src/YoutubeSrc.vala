public class YoutubeSrc : VideoSrc {
	class construct {
		set_static_metadata ("YoutubeSrc", "Video", "Youtube source element", "Yannick Inizan <inizan.yannick@gmail.com>");
	}
	
	construct {
		notify["location"].connect (() => {
			try {
				if (location != null)
					video = new Video.Youtube (location);
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
			var yt = new Video.Youtube (uri);
			location = uri;
			return true;
		} catch {
			return false;
		}
	}
	
	[CCode (array_length = false, array_null_terminated = true)]
	public static string[]? get_protocols (GLib.Type gtype) {
		return new string[]{"http", "https", "youtube"};
	}
	
	public static Gst.URIType get_type_uri (GLib.Type gtype) {
		return Gst.URIType.SRC;
	}
}
