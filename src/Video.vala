namespace Video {
	public errordomain VideoError {
		NULL,
		INVALID,
		NOT_FOUND
	}
	
	public enum Quality {
		NONE,
		LOW,
		STANDARD,
		HIGH,
		HD,
		HD2
	}
	
	public struct Item {
		public string url;
		public Quality quality;
	}
	
	public static bool init (Gst.Plugin plugin) {
		if (!Gst.Element.register (plugin, "youtubesrc", 1024, youtube_src_real_type()))
			return false;
		if (!Gst.Element.register (plugin, "uptoboxsrc", 1024, uptobox_src_real_type()))
			return false;
		return true;
	}
}

static extern Type youtube_src_real_type();
static extern Type uptobox_src_real_type();
