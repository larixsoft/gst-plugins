internal class HtmlDocument : GXml.xDocument {
		public static int default_options {
			get {
				return Html.ParserOption.NONET | Html.ParserOption.NOWARNING | Html.ParserOption.NOERROR | Html.ParserOption.NOBLANKS;
			}
		}
		public static int no_error {
			get {
				return Html.ParserOption.NOERROR;
			}
		}
		
		public HtmlDocument.from_file (File file, int options = 0, Cancellable? cancel = null) throws GLib.Error {
			uint8[] data;
			file.load_contents (null, out data, null);
			this.from_string ((string)data, options);
		}
		
		public HtmlDocument.from_path (string path, int options = 0) throws GLib.Error {
			this.from_file (File.new_for_path (path), options);
		}
		
		public HtmlDocument.from_stream (InputStream stream, int options = 0, Cancellable? cancel = null) throws GLib.Error {
			uint8[] buffer = new uint8[1024];
			string html = "";
			while (stream.read (buffer) != 0) {
				if(cancel != null && cancel.is_cancelled())
					break;
				html += (string)buffer;
			}
			this.from_string (html, options);
		}
		
		public HtmlDocument.from_string (string html, int options = 0) {
			base.from_libxml2 (Html.Doc.read_memory (html.to_utf8(), html.length, "", null, options));
		}
		
		public HtmlDocument.from_uri (string uri, int options = 0) throws GLib.Error {
			this.from_file (File.new_for_uri (uri), options);
		}
		
		Gee.List<GXml.Node> gebcn (GXml.xElement node, string klass) {
			var list = new Gee.ArrayList<GXml.Node>();
			foreach (var child in node.childs) {
				var e = child as GXml.xElement;
				if (e == null)
					continue;
				list.add_all (gebcn (e, klass));
				if (e.get_attribute ("class") != null) {
					foreach (string kls in e.get_attribute ("class").split (" "))
						if (kls == klass) {
							list.add (child);
							break;
						}
				}
			}
			return list;
		}
		
		public Gee.List<GXml.Node> get_elements_by_class_name (string klass) {
			return gebcn (root as GXml.xElement, klass);
		}
		
		public GXml.Node? get_element_by_id (string id) {
			return root.get_element_by_id (id);
		}
	}
