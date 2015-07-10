using Video;

public static extern Type web_video_src_real_type();

public class WebVideoSrc : Gst.GioBaseSrc {
	
	public static bool init (Gst.Plugin plugin) {
		return Gst.Element.register (plugin, "webvideosrc", 1024, web_video_src_real_type());
	}
	
	class construct {
		set_static_metadata ("WebVideoSrc", "Video", "Web video source element", "Yannick Inizan <inizan.yannick@gmail.com>");
	}
	
	WebVideo video;
	
	construct {
		notify["location"].connect (() => {
			try {
				video = WebVideo.guess (location);
				if (video is Youtube)
					provider = "youtube";
				if (video is Dailymotion)
					provider = "dailymotion";
				started.connect (() => {
					var list = new Gst.TagList.empty();
					list.add (Gst.TagMergeMode.APPEND, "title", video.title);
					var sample = new Gst.Sample (new Gst.Buffer.wrapped (video.picture.data), null, null, null);
					list.add (Gst.TagMergeMode.APPEND, "image", sample);
					var msg = new Gst.Message.tag (this, list);
					post_message (msg);
				});
			} catch {
			
			}
		});
		notify["quality"].connect (() => {
			if (video != null) {
				video.quality = quality;
			}
		});
	}
	
	public string location { get; set; }
	public string provider { get; private set; }
	public Quality quality { get; set; default = Quality.STANDARD; }
	
	public override InputStream get_stream() {
		if (location == null || video == null)
			return null;
		var file = File.new_for_uri (video.uri);
		return file.read (cancel);
	}
	
	public signal void started();
	
	public override bool start() {
		started();
		return base.start();
	}
	
	// URIHandler section
	
	public string? get_uri() {
		return location;
	}
	
	public bool set_uri (string uri) throws GLib.Error {
		if (WebVideo.guess (uri) == null)
			return false;
		location = uri;
		return true;
	}
	
	[CCode (array_length = false, array_null_terminated = true)]
	public static string[]? get_protocols (GLib.Type gtype) {
		return new string[]{"http", "https"};
	}
	
	public static Gst.URIType get_type_uri (GLib.Type gtype) {
		return Gst.URIType.SRC;
	}
}
