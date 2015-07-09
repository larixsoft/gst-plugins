namespace MeeGst {
	public class Uri : GLib.Object {
		public Uri (string str) {
			parameters = new HashTable<string, string>(str_hash, str_equal);
			uri = str;
			if (uri.index_of ("://") == -1) {
				path = str;
				uri = Filename.to_uri (path);
			}
			else {
				try {
					path = Filename.from_uri (uri);
				} catch {
					
				}
			}
			if ("?" in str) {
				var array = str.substring (1 + str.index_of ("?")).split ("&");
				foreach (var a in array) {
					if ("=" in a) {
						parameters[a.substring (0, a.index_of ("="))] = a.substring (1 + a.index_of ("="));
					}
				}
			}
		}
		
		public bool equals (Uri uri) {
			return str_equal (uri.to_string(), to_string());
		}
		
		public HashTable<string, string> parameters { get; private set; }
		
		public uint port { get; private set; }
		
		public string path { get; private set; }
		
		public string scheme {
			owned get {
				return uri.substring (0, uri.index_of (":"));
			}
		}
		
		public string[] segments {
			owned get {
				return path.split ("/");
			}
		}
		
		public string uri { get; private set; }
		
		public string to_string() {
			return uri;
		}
	}
}
