public static extern Type hls_src_real_type();

public class HlsSrc : Gst.Base.PushSrc {
	public static bool init (Gst.Plugin plugin) {
		return Gst.Element.register (plugin, "hlssrc", 1024, hls_src_real_type());
	}
	
	class construct {
		Gst.StaticCaps caps = { null, "ANY" };
		Gst.StaticPadTemplate src_template = {
			"src",
			Gst.PadDirection.SRC,
			Gst.PadPresence.ALWAYS,
			caps
		};
		add_pad_template (src_template.get());
		set_static_metadata ("HlsSrc", "Codec/Source/Adaptive", "HTTP Live Streaming source element", "Yannick Inizan <inizan.yannick@gmail.com>");
	}
	
	PlayList m3u8;
	int list_index;
	
	static void download_data (string uri, out uint8[] data) {
		var session = new Soup.Session();
		session.user_agent = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.132 Safari/537.36";
		var message = new Soup.Message ("GET", uri);
		session.send_message (message);
		data = message.response_body.data;
	}
	
	public override Gst.FlowReturn create (out Gst.Buffer buffer) {
		if (list_index >= m3u8.size)
			return Gst.FlowReturn.EOS;
		uint8[] data;
		download_data (m3u8[list_index].uri, out data);
		uint64 pos;
		if (!srcpad.query_position (Gst.Format.TIME, out pos)) {
			pos = 0;
			for (var i = 0; i < list_index; i++)
				pos += m3u8[i].duration;
		}
		var buf = new Gst.Buffer.wrapped (data);
		buf.duration = m3u8[list_index].duration;
		buf.pts = (Gst.ClockTime)pos;
		buffer = buf;
		list_index++;
		return Gst.FlowReturn.OK;
	}
	
	public override bool do_seek (Gst.Segment segment) {
		uint64 duration = 0;
		if (segment.duration >= m3u8.duration)
			return false;
		for (var i = 0; i < m3u8.size; i++) {
			duration += m3u8[i].duration;
			if (duration > segment.duration) {
				list_index = i - 1;
				segment.start = m3u8[list_index].duration;
				break;
			}
		}
		return true;
	}
	
	public override bool event (Gst.Event evt) {
		if (evt.type == Gst.EventType.SEEK) {
			seek_event (evt);
			return true;
		}
		return base.event (evt);
	}
	
	void seek_event (Gst.Event evt) {
		double rate; Gst.Format format; Gst.SeekFlags flags; Gst.SeekType start_type, stop_type; int64 start, stop;
		evt.parse_seek (out rate, out format, out flags, out start_type, out start, out stop_type, out stop);
		
		if (format == Gst.Format.TIME) {
			uint64 duration = 0;
			if (start >= m3u8.duration)
				return;
			for (var i = 0; i < m3u8.size; i++) {
				duration += m3u8[i].duration;
				if (duration > start) {
					list_index = i - 1;
					break;
				}
			}
		}
		
		if (format == Gst.Format.PERCENT) {
			if (start > 1000000)
				start = 1000000;
			var pos = m3u8.duration * start / 1000000;
			uint64 duration = 0;
			for (var i = 0; i < m3u8.size; i++) {
				duration += m3u8[i].duration;
				if (duration > pos) {
					list_index = i - 1;
					break;
				}
			}
		}
		
		if (format == Gst.Format.BYTES) {
			uint64 dur = m3u8[0].duration;
			uint64 size = m3u8[0].size;
			uint64 pos = start * dur / size;
			uint64 duration = 0;
			for (var i = 0; i < m3u8.size; i++) {
				duration += m3u8[i].duration;
				if (duration > pos) {
					list_index = i - 1;
					break;
				}
			}
		}
	}
	
	public override bool is_seekable() {
		return true;
	}
	
	public override bool query (Gst.Query qry) {
		if (qry.type == Gst.QueryType.DURATION) {
			Gst.Format format;
			qry.parse_duration (out format, null);
			uint64 duration = 0;
			if (format == Gst.Format.TIME)
				duration = m3u8.duration;
			if (format == Gst.Format.BYTES)
				duration = m3u8[0].size * m3u8.duration / m3u8[0].duration;
			qry.set_duration (format, (int64)duration);
			return true;
		}
		if (qry.type == Gst.QueryType.POSITION) {
			Gst.Format format;
			qry.parse_position (out format, null);
			uint64 duration = 0;
			for (var i = 0; i < list_index; i++) {
				duration += m3u8[i].duration;
			}
			if (format == Gst.Format.TIME)
				qry.set_position (format, (int64)duration);
			if (format == Gst.Format.PERCENT)
				qry.set_position (format, (int64)(duration * 1000000 / m3u8.duration));
			if (format == Gst.Format.BYTES)
				qry.set_position (format, (int64)(m3u8[0].size * duration / m3u8[0].duration));
			return true;
		}
		return base.query (qry);
	}
	
	public override bool start() {
		try {
			m3u8 = new PlayList.from_uri (location);
			list_index = 0;
			return true;
		} catch {
			return false;
		}
	}
	
	public string location { get; set; }
	
	// URIHandler section
	
	public string? get_uri() {
		return location;
	}
	
	public bool set_uri (string uri) throws GLib.Error {
		if (current_state == Gst.State.PLAYING || current_state == Gst.State.PAUSED)
			return false;
		try {
			var m3u = new PlayList.from_uri (uri);
			location = uri;
			return true;
		} catch {
			return false;
		}
	}
	
	[CCode (array_length = false, array_null_terminated = true)]
	public static string[]? get_protocols (GLib.Type gtype) {
		return new string[]{"http", "https"};
	}
	
	public static Gst.URIType get_type_uri (GLib.Type gtype) {
		return Gst.URIType.SRC;
	}
}
