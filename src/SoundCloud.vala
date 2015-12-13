public class SoundCloundTrack : GLib.Object {
	public SoundCloundTrack.from_uri (string uri) throws GLib.Error {
		int id = 0;
		if (uri.has_prefix ("soundcloud://sounds:"))
			id = int.parse (uri.split ("soundcloud://sounds:")[1]);
		else if (uri.has_prefix ("soundcloud://"))
			id = int.parse (uri.split ("soundcloud://")[1]);
		else {
			var document = new Html.Document.from_uri (uri, Html.Document.default_options);
			document.get_elements_by_tag_name ("meta").foreach (meta => {
				var elem = meta as GXml.xElement;
				if (elem.get_attribute ("content").has_prefix ("soundcloud://sounds:")) {
					id = int.parse (elem.get_attribute ("content").split ("soundcloud://sounds:")[1]);
					return false;
				}
				return true;
			});
		}
		this (id);
	}

	public SoundCloundTrack (int id) throws GLib.Error {
		var parser = new Json.Parser();
		parser.load_from_stream (File.new_for_uri ("https://api-partners.soundcloud.com/twitter/tracks/soundcloud:sounds:%d/vmap".printf (id)).read());
		var object = parser.get_root().get_object().get_array_member ("tracks").get_object_element (0);
		uint index = object.get_array_member ("sources").get_length() - 1;
		if (index < 0)
			throw new Video.VideoError.NOT_FOUND ("no uri found.");
		uri = object.get_array_member ("sources").get_object_element (index).get_string_member ("url");
		artist = object.get_object_member ("artist").get_string_member ("name");
		title = object.get_string_member ("title");
		artwork = object.get_string_member ("artwork");
	}
	
	public string artist { get; private set; }
	public string artwork { get; private set; }
	public string title { get; private set; }
	public string uri { get; private set; }
}

public class SoundCloudSrc : WebSrc {
	class construct {
		Gst.StaticCaps caps = { null, "text/html" };
		Gst.StaticPadTemplate src_template = {
			"src",
			Gst.PadDirection.SRC,
			Gst.PadPresence.ALWAYS,
			caps
		};
		add_pad_template (src_template.get());
		set_static_metadata ("SoundCloudSrc", "Audioo", "SoundClound source element", "Yannick Inizan <inizan.yannick@gmail.com>");
	}
	
	SoundCloundTrack track;
	
	construct {
		notify["location"].connect (() => {
			track = new SoundCloundTrack.from_uri (location);
		});
		started.connect (() => {
			var list = new Gst.TagList.empty();
			list.add (Gst.TagMergeMode.APPEND, "artist", track.artist);
			list.add (Gst.TagMergeMode.APPEND, "title", track.title);
			uint8[] data;
			File.new_for_uri (track.artwork).load_contents (null, out data, null);
			var sample = new Gst.Sample (new Gst.Buffer.wrapped (data), null, null, null);
			list.add (Gst.TagMergeMode.APPEND, "image", sample);
			var msg = new Gst.Message.tag (this, list);
			post_message (msg);
		});
	}
	
	public string location { get; set; }
	
	public override InputStream get_stream() {
		if (track == null)
			return null;
		return File.new_for_uri (track.uri).read();
	}
	
	public string? get_uri() {
		return location;
	}
	
	[CCode (array_length = false, array_null_terminated = true)]
	public static string[]? get_protocols (GLib.Type gtype) {
		return new string[]{ "http", "https", "soundcloud" };
	}
	
	public static Gst.URIType get_type_uri (GLib.Type gtype) {
		return Gst.URIType.SRC;
	}
	
	public static bool uri_is_valid (string uri) {
		try {
			var sc = new SoundCloundTrack.from_uri (uri);
			return true;
		} catch {
			return false;
		}
	}
}
