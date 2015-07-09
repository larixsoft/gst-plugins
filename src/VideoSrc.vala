public class VideoSrc : Gst.Base.Src {
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
	}
	
	internal Video.WebVideo video;
	internal Gst.Base.Src giosrc;
	
	construct {
		giosrc = (Gst.Base.Src)Gst.ElementFactory.make ("giosrc", "handle");
		notify["video"].connect (() => {
			title = video.title;
			picture = video.picture;
		});
		notify["quality"].connect (() => {
			if (video != null)
				video.quality = quality;
		});
	}
	
	public string location { get; set; }
	public Video.Quality quality { get; set; default = Video.Quality.STANDARD; }
	public string title { get; private set; }
	public ByteArray picture { get; private set; }
	
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
		if (video == null)
			return false;
		giosrc["location"] = video.uri;
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
}
