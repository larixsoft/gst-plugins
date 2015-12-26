public class WebVideoSrc : WebSrc {
	class construct {
		Gst.StaticCaps caps = { null, "text/html" };
		Gst.StaticPadTemplate src_template = {
			"src",
			Gst.PadDirection.SRC,
			Gst.PadPresence.ALWAYS,
			caps
		};
		add_pad_template (src_template.get());
		set_static_metadata ("YouTubeSrc", "Video", "YouTube source element", "Yannick Inizan <inizan.yannick@gmail.com>");
	}
	
	Video.WebVideo video;
	
	construct {
		notify["location"].connect (() => {
			video = Video.WebVideo.guess (location);
		});
		started.connect (() => {
			var list = new Gst.TagList.empty();
			list.add (Gst.TagMergeMode.APPEND, "title", video.title);
			if (video.artist != null)
				list.add (Gst.TagMergeMode.APPEND, "artist", video.artist);
			var sample = new Gst.Sample (new Gst.Buffer.wrapped (video.picture.data), null, null, null);
			list.add (Gst.TagMergeMode.APPEND, "image", sample);
			var msg = new Gst.Message.tag (this, list);
			post_message (msg);
		});
		notify["quality"].connect (() => {
			if (video != null) {
				video.quality = quality;
			}
		});
	}
	
	public override InputStream get_stream() {
		try {
			return File.new_for_uri (video.uri).read();
		} catch {
			return null;
		}
	}
	
	public string location { get; set; }
	public Video.Quality quality { get; set; default = Video.Quality.STANDARD; }
	
	// URIHandler section
	
	public string? get_uri() {
		return location;
	}
	
	[CCode (array_length = false, array_null_terminated = true)]
	public static string[]? get_protocols (GLib.Type gtype) {
		return new string[]{ "youtube", "http", "https" };
	}
	
	public static Gst.URIType get_type_uri (GLib.Type gtype) {
		return Gst.URIType.SRC;
	}
}
