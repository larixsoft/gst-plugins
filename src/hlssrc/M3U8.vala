public errordomain M3UError {
	NULL,
	INVALID,
	NOT_FOUND
}

public class ListEntry {
	uint8[] download_data (string uri) {
		var session = new Soup.Session();
		session.user_agent = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.132 Safari/537.36";
		var message = new Soup.Message ("GET", uri);
		session.send_message (message);
		return message.response_body.data;
	}
	
	public ListEntry (string uri, uint64 duration) {
		this.uri = uri;
		this.duration = duration;
	}
	
	public uint64 duration { get; private set; }
	public string uri { get; private set; }
	public int size {
		get {
			return download_data (uri).length;
		}
	}
}

public class PlayList {
	internal GenericArray<ListEntry> entries;
	
	public PlayList() {
		entries = new GenericArray<ListEntry>();
	}
	
	public PlayList.from_uri (string uri) throws GLib.Error {
		this.from_file (File.new_for_uri (uri));
	}
	
	PlayList.from_file (GLib.File file) throws GLib.Error {
		entries = new GenericArray<ListEntry>();
		uri = file.get_uri();
		var stream = new DataInputStream (file.read());
		if (stream.read_line() != "#EXTM3U")
			throw new M3UError.NOT_FOUND ("M3U identifier not found.");
		string line = "";
		uint64 dur = 0;
		while ((line = stream.read_line()) != null) {
			if (line.has_prefix ("#EXTINF:")) {
				line = line.substring (8);
				dur = (uint64)(1000000000 * double.parse (line.substring (0, line.index_of (","))));
			}
			else if (line[0] != '#') {
				bool absolute = !line.has_prefix ("http://") && !line.has_prefix ("https://");
				if (absolute)
					line = file.get_parent().get_uri() + "/" + line;
				var gfile = File.new_for_uri (line);
				if (gfile.get_basename().has_suffix (".m3u8")) {
					foreach (var entry in new PlayList.from_file (gfile))
						entries.add (entry);
				}
				else
					entries.add (new ListEntry (gfile.get_uri(), dur));
					//entries.add ((ListEntry)GLib.Object.new (typeof (ListEntry), "uri", gfile.get_uri(), "duration", dur));
				dur = 0;
			}
		}
		uint64 d = 0;
		entries.foreach (entry => {
			d += entry.duration;
		});
		duration = d / (uri.split (",").length - 2);
	}

	public ListEntry get (uint index) {
		return entries[index];
	}
	
	public uint64 duration { get; private set; }
	
	public string uri { get; private set; }
	
	public uint size {
		get {
			return entries.length;
		}
	}
}
