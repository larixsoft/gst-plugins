using Video;

public static extern Type youtube_src_real_type();

public class YoutubeSrc : Gst.Base.Src {
	
	public static bool init (Gst.Plugin plugin) {
		return Gst.Element.register (plugin, "youtubesrc", 1024, youtube_src_real_type());
	}
	
	class construct {
		Gst.StaticPadTemplate src_factory = {
			"src",
			Gst.PadDirection.SRC,
			Gst.PadPresence.ALWAYS,
			Gst.StaticCaps(){
				caps = null, 
				string = "ANY"
			}
		};
		add_pad_template (src_factory.get());
		set_static_metadata ("YoutubeSrc", "Video", "Youtube source element", "Yannick Inizan <inizan.yannick@gmail.com>");
	}
	
	Youtube youtube;
	Gst.Base.Src giosrc;
	
	construct {
		giosrc = (Gst.Base.Src)Gst.ElementFactory.make ("giosrc", "handle");
		notify["location"].connect (() => {
			try {
				if (location != null) {
					youtube = new Youtube (location);
				}
			} catch {
			
			}
		});
		notify["quality"].connect (() => {
			if (youtube != null)
				youtube.quality = quality;
		});
	}
	
	public override Gst.FlowReturn create (uint64 offset, uint size, out Gst.Buffer buffer) {
		return giosrc.create (offset, size, out buffer);
	}
	
	public override bool get_size (out uint64 size) {
		return giosrc.get_size (out size);
	}
	
	public override bool is_seekable() {
		return giosrc.is_seekable();
	}
	
	public override bool start() {
		if (youtube != null)
			giosrc["location"] = youtube.uri;
		return giosrc.start();
	}
	
	public override bool stop() {
		return giosrc.stop();
	}
	
	public override bool unlock() {
		return giosrc.unlock();
	}
	
	public override bool unlock_stop() {
		return giosrc.unlock_stop();
	}
	
	public override bool query (Gst.Query query) {
		return giosrc.query (query);
	}
	
	public string location { get; set construct; }
	public Quality quality { get; set construct; default = Quality.STANDARD; }
	
	// URIHandler section
	
	public string? get_uri() {
		return location;
	}
	
	public bool set_uri (string uri) throws GLib.Error {
		try {
			var yt = new Youtube (uri);
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
