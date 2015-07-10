[CCode (cheader_filename = "gio/gstgiosrc.h")]
namespace Gst {
	public class GioBaseSrc : Gst.Base.Src {
		[CCode (has_construct_function = false)]
		protected GioBaseSrc ();
		
		public virtual GLib.InputStream get_stream();
		
		protected GLib.Cancellable cancel;
	}
	
	public class GioSrc : GioBaseSrc {
		[CCode (has_construct_function = false)]
		protected GioSrc ();
		
		public string location { get; set; }
		public GLib.File file { get; set; }
	}
}
