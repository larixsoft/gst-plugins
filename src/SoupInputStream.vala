class SoupInputStream : GLib.InputStream, GLib.Seekable {
	Soup.Session session;
	Soup.Message message;
	int64 position;
	
	internal SoupInputStream (string location) {
		GLib.Object (location: location);
	}
	
	construct {
		session = new Soup.Session();
		session.user_agent = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.73 Safari/537.36";
		message = new Soup.Message ("HEAD", location);
		session.send_message (message);
		size = message.response_headers.get_content_length();
		message.method = "GET";
		position = 0;
	}
	
	public bool can_seek() {
		return session != null;
	}
	
	public bool can_truncate() {
		return false;
	}
	
	public bool seek (int64 offset, SeekType seek_type, Cancellable? cancel = null) throws Error {
		if (seek_type == SeekType.CUR)
			position += offset;
		else if (seek_type == SeekType.SET && offset >= 0)
			position = offset;
		else if (seek_type == SeekType.END && offset >= 0)
			position = size - offset;
		else
			return false;
		return true;
	}
	
	public int64 tell() {
		return position;
	}
	
	public bool truncate (int64 offset, Cancellable? cancellable = null) throws Error {
		return false;
	}
	
	public override bool close (Cancellable? cancel = null) throws IOError {
		if (session == null)
			return false;
		session = null;
		return true;
	}
	
	public override ssize_t read (uint8[] buffer, Cancellable? cancel = null) throws IOError {
		if (session == null)
			throw new IOError.CLOSED ("session closed.");
		int len = buffer.length;
		message.request_headers.clear();
		if (position < size) {
			message.request_headers.append ("Range", "bytes=%lld-%lld".printf (position, position + len - 1));
			session.send_message (message);
			position += len;
			for (var i = 0; i < message.response_body.data.length; i++)
				buffer[i] = message.response_body.data[i];
			return (ssize_t)message.response_headers.get_content_length();
		}
		return 0;
	}
	
	public static SoupInputStream? open (string location) {
		var stream = new SoupInputStream (location);
		if (stream.size == 0)
			return null;
		return stream;
	}
	
	public string location { get; construct; }
	
	public int64 size { get; private set; }
}

void main (string[] args) {
	var stream = SoupInputStream.open ("https://fpdl.vimeocdn.com/vimeo-prod-skyfire-std-us/01/4494/5/147472417/447252612.mp4?token=5669a8db_0x939edc17097e3d603bbe7a240a6f9696651f85f4");
	//var stream = File.new_for_uri ("https://player.vimeo.com/video/147472417/config").read();
	var output = File.new_for_path ("tmp").create (FileCreateFlags.NONE);
	uint8[] buffer = new uint8[8192];
	int i = 0;
	while (true) {
		print ("%d\n", i);
		var res = stream.read (buffer);
		if (res < 8192) {
			buffer.resize ((int)res);
			output.write (buffer);
			break;
		}
		output.write (buffer);
		i++;
	}
}
