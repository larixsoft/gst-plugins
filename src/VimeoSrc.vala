public class VimeoSrc : WebSrc {
	class construct {
		Gst.StaticCaps caps = { null, "text/html" };
		Gst.StaticPadTemplate src_template = {
			"src",
			Gst.PadDirection.SRC,
			Gst.PadPresence.ALWAYS,
			caps
		};
		add_pad_template (src_template.get());
		set_static_metadata ("VimeoSrc", "Video", "Vimeo source element", "Yannick Inizan <inizan.yannick@gmail.com>");
	}
	
	HashTable<Video.Quality, string> table;
	
	construct {
		notify["location"].connect (() => {
			string[] parts = location.split ("/");
			string id = "";
			if (parts[2] == "player.vimeo.com")
				id = parts[4];
			else if (parts[2] == "vimeo.com")
				id = parts[3];
			else if (location.has_prefix ("vimeo://"))
				id = parts[2];
			var parser = new Json.Parser();
			parser.load_from_stream (File.new_for_uri ("http://player.vimeo.com/video/%s/config".printf (id)).read());
			table = new HashTable<Video.Quality, string>(null, null);
			parser.get_root().get_object().get_object_member ("request").get_object_member ("files")
			.get_array_member ("progressive").foreach_element ((array, index, node) => {
				string q = node.get_object().get_string_member ("quality");
				string u = node.get_object().get_string_member ("url");
				if (q == "1080p")
					table[Video.Quality.HD2] = u;
				if (q == "720p")
					table[Video.Quality.HD] = u;
				if (q == "480p")
					table[Video.Quality.HIGH] = u;
				if (q == "360p")
					table[Video.Quality.STANDARD] = u;
				if (q == "240p")
					table[Video.Quality.LOW] = u;
			});
		});
	}
	
	public override InputStream get_stream() {
		return new SoupInputStream (table[quality]);
	}
	
	public string location { get; set; }
	public Video.Quality quality { get; set; default = Video.Quality.STANDARD; }
	
	// URIHandler section
	
	public string? get_uri() {
		return location;
	}
	
	[CCode (array_length = false, array_null_terminated = true)]
	public static string[]? get_protocols (GLib.Type gtype) {
		return new string[]{ "http", "https", "vimeo" };
	}
	
	public static Gst.URIType get_type_uri (GLib.Type gtype) {
		return Gst.URIType.SRC;
	}
	
	public static bool uri_is_valid (string uri) {
		string[] parts = uri.split ("/");
		string id = "0";
		if (parts[2] == "player.vimeo.com")
			id = parts[4];
		else if (parts[2] == "vimeo.com")
			id = parts[3];
		else if (uri.has_prefix ("vimeo://"))
			id = parts[2];
		else
			return false;
		var parser = new Json.Parser();
		parser.load_from_stream (File.new_for_uri ("http://player.vimeo.com/video/%s/config".printf (id)).read());
		return parser.get_root().get_object().get_object_member ("request").has_member ("files");
	}
}
