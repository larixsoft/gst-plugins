namespace Html {
	public class Document : GXml.xDocument {
		public static int default_options {
			get {
				return Html.ParserOption.NONET | Html.ParserOption.NOWARNING | Html.ParserOption.NOERROR | Html.ParserOption.NOBLANKS;
			}
		}
		
		public Document.from_path (string path, int options = 0) throws GLib.Error {
			this.from_file (File.new_for_path (path), options);
		}
		
		public Document.from_uri (string uri, int options = 0) throws GLib.Error {
			this.from_file (File.new_for_uri (uri), options);
		}
		
		public Document.from_file (File file, int options = 0, Cancellable? cancel = null) throws GLib.Error {
			uint8[] data;
			file.load_contents (cancel, out data, null);
			this.from_string ((string)data, options);
		}
		
		public Document.from_string (string html, int options = 0) {
			base.from_libxml2 (Html.Doc.read_memory (html.to_utf8(), html.length, "", null, options));
		}
		
		public Gee.List<GXml.Node> get_elements_by_class_name (string klass) {
			return root.get_elements_by_class_name (klass);
		}
		
		public GXml.Node? get_element_by_id (string id) {
			return root.get_element_by_id (id);
		}
	}
}
