using Video;

public static extern Type web_video_src_real_type();
public static extern Gst.FlowReturn web_video_src_rcreate (WebVideoSrc src, uint64 offset, uint size, out Gst.Buffer buffer);

public class WebVideoSrc : Gst.Base.Src {
	
	public static bool init (Gst.Plugin plugin) {
		Gst.StaticCaps caps = { null, "text/html" };
		if (!Gst.TypeFind.register (plugin, "text/html", Gst.Rank.PRIMARY, find => {
			var data = (string)find.peek (0, 100);
			if ("ytcfg" in data || "ytcsi" in data)
				find.suggest (Gst.TypeFindProbability.MAXIMUM, caps.get());
		}, "html,htm", caps.get()))
			return false;
		return Gst.Element.register (plugin, "webvideosrc", 1024, web_video_src_real_type());
	}
	
	class construct {
		Gst.StaticCaps caps = { null, "text/html" };
		Gst.StaticPadTemplate src_template = {
			"src",
			Gst.PadDirection.SRC,
			Gst.PadPresence.ALWAYS,
			caps
		};
		add_pad_template (src_template.get());
		set_static_metadata ("WebVideoSrc", "Video", "Web video source element", "Yannick Inizan <inizan.yannick@gmail.com>");
	}
	
	WebVideo video;
	public FileInputStream stream;
	public Cancellable cancel;
	public Gst.Buffer cache;
	public uint64 position;
	
	construct {
		cancel = new Cancellable();
		notify["location"].connect (() => {
			video = WebVideo.guess (location);
			if (video == null)
				return;
			video.quality = quality;
			if (video is Youtube)
				provider = "youtube";
			if (video is Dailymotion)
				provider = "dailymotion";
			if (video is Uptobox)
				provider = "uptobox";
			started.connect (() => {
				var list = new Gst.TagList.empty();
				list.add (Gst.TagMergeMode.APPEND, "title", video.title);
				var sample = new Gst.Sample (new Gst.Buffer.wrapped (video.picture.data), null, null, null);
				list.add (Gst.TagMergeMode.APPEND, "image", sample);
				var msg = new Gst.Message.tag (this, list);
				post_message (msg);
			});
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
	
	public signal void started();
	
	public override bool start() {
		position = 0;
		stream = File.new_for_uri (video.uri).read();
		started();
		return true;
	}
	
	public override bool stop() {
		stream.close();
		return true;
	}
	
	public override bool get_size (out uint64 size) {
		size = (uint64)stream.query_info ("standard::*").get_size();
		return true;
	}
	
	public override bool is_seekable() {
		return true;
	}
	
	public override bool unlock() {
		cancel.cancel();
		return true;
	}
	
	public override bool unlock_stop() {
		cancel.reset();
		return true;
	}
	
	public override Gst.FlowReturn create (uint64 offset, uint size, out Gst.Buffer buffer) {
		return web_video_src_rcreate (this, offset, size, out buffer);
	}
	
	// URIHandler section
	
	public string? get_uri() {
		return location;
	}
	
	/*
	public bool set_uri (string uri) throws GLib.Error {
		if (!WebVideo.uri_is_valid (uri))
			return false;
		if (WebVideo.guess (uri) == null)
			throw new Gst.URIError.BAD_URI ("invalid URI");
		location = uri;
		return true;
	}
	*/
	
	[CCode (array_length = false, array_null_terminated = true)]
	public static string[]? get_protocols (GLib.Type gtype) {
		return new string[]{"http", "https", "youtube", "dailymotion"};
	}
	
	public static Gst.URIType get_type_uri (GLib.Type gtype) {
		return Gst.URIType.SRC;
	}
}
