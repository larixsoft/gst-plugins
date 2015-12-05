namespace Mxml {
	public class HtmlDocument : Document {
		public static int default_options {
			get {
				return Html.ParserOption.NONET | Html.ParserOption.NOWARNING | Html.ParserOption.NOERROR | Html.ParserOption.NOBLANKS;
			}
		}
		
		internal HtmlDocument.internal (Xml.Doc* ptr) {
			base.internal (ptr);
		}
		
		public HtmlDocument.from_path (string path, int options = 0) throws GLib.Error {
			var stream = File.new_for_path (path).read();
			var pointer = Html.Doc.read_io ((context, buffer) => {
				try {
					var res = (context as InputStream).read (buffer);
					return (int)res;
				} catch {
					return -1;
				}
			},
			context => {
				return 0;
			}, stream, "", null, options);
			this.internal (pointer);
		}
		
		public HtmlDocument.from_string (string html, int options = 0) {
			base.internal (Html.Doc.read_memory (html.data, "", null, 0));
		}
		
		public HtmlDocument.from_uri (string uri, int options = 0) throws GLib.Error {
			var stream = File.new_for_uri (uri).read();
			var pointer = Html.Doc.read_io ((context, buffer) => {
				try {
					var res = (context as InputStream).read (buffer);
					return (int)res;
				} catch {
					return -1;
				}
			},
			context => {
				return 0;
			}, stream, "", null, options);
			this.internal (pointer);
		}
	
		public Gee.List<Mxml.Node> get_elements_by_class_name (string klass) {
			return root.get_elements_by_class_name (klass);
		}
	
		public Mxml.Node? get_element_by_id (string id) {
			return root.get_element_by_id (id);
		}
		
		public Gee.List<Mxml.Node> get_elements_by_tag_name (string tag_name) {
			return root.get_elements_by_tag_name (tag_name);
		}
	}
	
	public class Document : GLib.Object {
		Xml.Doc* ptr;
		
		construct {
			ptr = new Xml.Doc();
		}
		
		internal Document.internal (Xml.Doc* ptr) {
			this.ptr = ptr;
		}
		
		public Document.from_path (string path, int options = 0) {
			var ctx = new Xml.ParserCtxt();
			var stream = File.new_for_path (path).read();
			ptr = ctx.read_io ((context, buffer) => {
				try {
					var res = (context as InputStream).read (buffer);
					return (int)res;
				} catch {
					return -1;
				}
			},
			context => {
				return 0;
			}, stream, "", null, options);
		}
		
		public Document.from_uri (string uri, int options = 0) throws GLib.Error {
			var ctx = new Xml.ParserCtxt();
			var stream = File.new_for_uri (uri).read();
			ptr = ctx.read_io ((context, buffer) => {
				try {
					var res = (context as InputStream).read (buffer);
					return (int)res;
				} catch {
					return -1;
				}
			},
			context => {
				return 0;
			}, stream, "", null, options);
		}
	
		public Mxml.Node root {
			owned get {
				return new Mxml.Node (ptr->get_root_element());
			}
		}
	}
}
