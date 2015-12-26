public static extern Gst.FlowReturn web_src_rcreate (Gst.WebSrc src, uint64 offset, uint size, out Gst.Buffer buf_return);
public static extern Type gst_web_video_src_real_type();
public static extern Type gst_vimeo_src_real_type();

namespace Gst {
	public abstract class WebSrc : Gst.Base.Src {
		public static bool init (Gst.Plugin plugin) {
			if (!Gst.Element.register (plugin, "vimeosrc", 1024, gst_vimeo_src_real_type()))
				return false;
			return Gst.Element.register (plugin, "youtubesrc", 1024, gst_web_video_src_real_type());
		}
		
		public Gst.Buffer cache;
		public Cancellable cancel;
		public uint64 position;
		public InputStream stream;
		
		construct {
			cancel = new Cancellable();
			position = 0;
		}
		
		public abstract InputStream get_stream();
		
		public signal void started();
		
		public override bool start() {
			stream = get_stream();
			started();
			if (stream == null || stream.is_closed())
				return false;
			if (stream is Seekable)
				position = (uint64)((Seekable)stream).tell();
			return true;
		}
		
		public override bool stop() {
			try {
				bool success = stream.close (cancel);
				if (!success) {
					var e = new IOError.FAILED ("close stream failed");
					post_message (new Gst.Message.warning (this, e, "close stream failed"));
				}
			} catch (IOError e) {
				post_message (new Gst.Message.warning (this, e, "close stream failed : %s".printf (e.message)));
			}
			return true;
		}
		
		public override bool get_size (out uint64 size) {
			if (stream is FileInputStream) {
				var info = (stream as FileInputStream).query_info (FileAttribute.STANDARD_SIZE, cancel);
				size = (uint64)info.get_size();
				return true;
			}
			if (stream is Seekable) {
				var seekable = stream as Seekable;
				int64 pos = seekable.tell();
				seekable.seek (0, GLib.SeekType.END, cancel);
				size = (uint64)seekable.tell();
				seekable.seek (pos, GLib.SeekType.SET, cancel);
				return true;
			}
			return false;
		}

		public override bool is_seekable() {
			return stream is Seekable;
		}
		
		public override bool unlock() {
			cancel.cancel();
			return true;
		}
		
		public override bool unlock_stop() {
			cancel = new Cancellable();
			return true;
		}
		
		public override Gst.FlowReturn create (uint64 offset, uint size, out Gst.Buffer buffer) {
			return web_src_rcreate (this, offset, size, out buffer);
		}
		
		public override bool query (Gst.Query qry) {
			bool ret = false;
			switch (qry.type) {
				case Gst.QueryType.URI:
					if (this is Gst.URIHandler) {
						string uri = (this as Gst.URIHandler).get_uri();
						qry.set_uri (uri);
						ret = true;
					}
				break;
			}
			if (!ret)
				ret = base.query (qry);
			return ret;
		}
	}
}
