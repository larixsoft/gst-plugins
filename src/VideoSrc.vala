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
	
	internal Gst.Base.Src giosrc;
	
	construct {
		giosrc = (Gst.Base.Src)Gst.ElementFactory.make ("giosrc", "handle");
	}
	
	public string location { get; set; }
	public Video.Quality quality { get; set; default = Video.Quality.STANDARD; }
	
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
