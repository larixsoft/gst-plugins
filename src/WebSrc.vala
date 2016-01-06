public static extern Type gst_web_video_src_real_type();
public static extern Type gst_vimeo_src_real_type();

namespace Gst {
	public abstract class WebSrc : Gst.Base.PushSrc {
		public static bool init (Gst.Plugin plugin) {
			if (!Gst.Element.register (plugin, "vimeosrc", 1024, gst_vimeo_src_real_type()))
				return false;
			return Gst.Element.register (plugin, "webvideosrc", 1024, gst_web_video_src_real_type());
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
		}
		
		public Cancellable cancel;
		public uint64 position;
		public InputStream stream;
		public GLib.DateTime date;
		
		bool got_tags;
		int64 size;
		
		construct {
			cancel = new Cancellable();
			position = 0;
		}
		
		int64 get_file_size() {
			if (stream is FileInputStream) {
				var info = (stream as FileInputStream).query_info (FileAttribute.STANDARD_SIZE, cancel);
				return info.get_size();
			}
			else if (stream is Seekable) {
				var seekable = stream as Seekable;
				int64 pos = seekable.tell();
				seekable.seek (0, GLib.SeekType.END, cancel);
				var s = seekable.tell();
				seekable.seek (pos, GLib.SeekType.SET, cancel);
				return s;
			}
			return -1;
		}
		
		public abstract Gst.TagList get_tags();
		
		public abstract InputStream get_stream();
		
		public signal void started();
		
		public override bool start() {
			if (!got_tags) {
				var list = get_tags();
				if (list != null) {
					post_message (new Gst.Message.tag (this, list));
					var event = new Gst.Event.tag (list);
					srcpad.push_event (event);
				}
				got_tags = true;
			}
			stream = get_stream();
			size = get_file_size();
			date = new GLib.DateTime.now_local();
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
		
		public override bool unlock() {
			cancel.cancel();
			return true;
		}
		
		public override bool unlock_stop() {
			cancel = new Cancellable();
			return true;
		}
		
		public override bool is_seekable() {
			return stream is Seekable;
		}
		
		public override bool query (Gst.Query qry) {
			bool res;
			Gst.Format format;
			int64 val;
			switch (qry.type) {
				case Gst.QueryType.URI:
					res = false;
					if (this is Gst.URIHandler) {
						string uri = (this as Gst.URIHandler).get_uri();
						qry.set_uri (uri);
						res = true;
					}
				break;
				case Gst.QueryType.POSITION:
					qry.parse_position (out format, out val);
					if (format != Gst.Format.BYTES)
						return false;
					qry.set_position (format, (int64)position);
					res = true;
				break;
				case Gst.QueryType.DURATION:
					res = false;
					qry.parse_duration (out format, out val);
					if (format == Gst.Format.BYTES) {
						if (size == -1)
							return false;
						qry.set_duration (format, size);
						res = true;
					}
				break;
				default:
					res = base.query (qry);
				break;
			}
			return res;
		}
	
		public override bool prepare_seek_segment (Gst.Event seek, Gst.Segment segment) {
			Gst.SeekType cur_type, stop_type;
			int64 cur, _stop;
			Gst.SeekFlags flags;
			Gst.Format seek_format;
			double rate;
			seek.parse_seek (out rate, out seek_format, out flags, out cur_type, out cur, out stop_type, out _stop);
			if (seek_format != Gst.Format.BYTES)
				return false;
			if (stop_type != SeekType.NONE)
				return false;
			if (cur_type != SeekType.NONE && cur_type != SeekType.SET)
				return false;
			segment.init (seek_format);
			segment.do_seek (rate, seek_format, flags, cur_type, cur, stop_type, _stop, false);
		//	position = cur;
			return true;
		}
	
		public override bool do_seek (Gst.Segment segment) {
			if (!(stream is Seekable))
				return false;
			if (segment.format == Gst.Format.BYTES) {
				(stream as Seekable).seek ((int64)segment.start, GLib.SeekType.SET, cancel);
				position = segment.start;
				var rate = segment.rate;
				var _stop = segment.stop;
				segment.init (Gst.Format.BYTES);
				segment.do_seek (rate, Gst.Format.BYTES, SeekFlags.NONE, SeekType.SET, position, SeekType.NONE, _stop, false);
				return true;
			}
			return false;
		}
		
		public override Gst.FlowReturn create (out Gst.Buffer buffer) {
			var data = new uint8[(int)blocksize];
			var res = stream.read (data);
			if (res == 0)
				return Gst.FlowReturn.EOS;
			data.resize ((int)res);
			position += res;
			var buf = new Gst.Buffer.wrapped (data);
			buf.offset = position;
			buf.pts = 1000 * new GLib.DateTime.now_local().difference (date);
			buffer = buf;
			return Gst.FlowReturn.OK;
		}
		
		public override bool get_size (out uint64 file_size) {
			if (stream is FileInputStream) {
				var info = (stream as FileInputStream).query_info (FileAttribute.STANDARD_SIZE, cancel);
				file_size = info.get_size();
				return true;
			}
			else if (stream is Seekable) {
				var seekable = stream as Seekable;
				int64 pos = seekable.tell();
				seekable.seek (0, GLib.SeekType.END, cancel);
				file_size = (uint64)seekable.tell();
				seekable.seek (pos, GLib.SeekType.SET, cancel);
				return true;
			}
			else
				return false;
		}
	
		public override Gst.Caps get_caps (Gst.Caps? filter) {
			if (filter == null)
				return new Gst.Caps.any();
			return filter;
		}
	}
}
