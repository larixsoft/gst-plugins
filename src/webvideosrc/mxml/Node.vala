namespace Mxml {
	public enum NodeType {
		NULL,
		ELEMENT_NODE,
		ATTRIBUTE_NODE,
		TEXT_NODE,
		CDATA_SECTION_NODE,
		ENTITY_REF_NODE,
		ENTITY_NODE,
		PI_NODE,
		COMMENT_NODE,
		DOCUMENT_NODE,
		DOCUMENT_TYPE_NODE,
		DOCUMENT_FRAG_NODE,
		NOTATION_NODE,
		HTML_DOCUMENT_NODE,
		DTD_NODE,
		ELEMENT_DECL,
		ATTRIBUTE_DECL,
		ENTITY_DECL,
		NAMESPACE_DECL,
		XINCLUDE_START,
		XINCLUDE_END,
		DOCB_DOCUMENT_NODE
	}
	
	public class Node : GLib.Object {
		Xml.Node* ptr;
		
		internal Node (Xml.Node* ptr) {
			this.ptr = ptr;
		}
		
		public Gee.List<Mxml.Node> get_elements_by_class_name (string klass) {
			return select ("//*[contains(concat(' ', @class, ' '), ' %s ')]".printf (klass));
		}
		
		public Mxml.Node? get_element_by_id (string id) {
			foreach (var child in children) {
				var node = child.get_element_by_id (id);
				if (node != null)
					return node;
				if (child.attributes["id"] == id)
					return child;
			}
			return null;
		}
		
		public string get_attribute (string name) {
			return ptr->get_prop (name);
		}
		
		public Gee.List<Mxml.Node> get_elements_by_tag_name (string tag_name) {
			var list = new Gee.ArrayList<Mxml.Node>();
			foreach (var child in children) {
				if (child.name == tag_name)
					list.add (child);
				list.add_all (child.get_elements_by_tag_name (tag_name));
			}
			return list;
		}
		
		public Gee.List<Mxml.Node> select (string path) {
			var list = new Gee.ArrayList<Mxml.Node>();
			var ctx = new Xml.ParserCtxt();
			var docptr = ctx.read_memory (to_string().data, "");
			var context = new Xml.XPath.Context (docptr);
			var obj = context.eval (path);
			if (obj == null)
				return list;
			for (var i = 0; i < obj->nodesetval->length(); i++)
				list.add (new Mxml.Node (obj->nodesetval->item (i)));
			return list;
		}
		
		public string to_string() {
			var buffer = new Xml.Buffer();
			buffer.node_dump (ptr->doc, ptr, 0, 1);
			return buffer.content();
		}
		
		public Attributes attributes {
			owned get {
				return new Attributes (ptr);
			}
		}
		
		public Gee.List<Mxml.Node> children {
			owned get {
				var list = new Gee.ArrayList<Mxml.Node>();
				for (Xml.Node* node = ptr->children; node != null; node = node->next)
					list.add (new Mxml.Node (node));
				return list;
			}
		}
		
		public string content {
			owned get {
				return ptr->get_content();
			}
		}
		
		public Document document {
			owned get {
				if (ptr->doc->type == Xml.ElementType.HTML_DOCUMENT_NODE)
					return new HtmlDocument.internal (ptr->doc);
				return new Document.internal (ptr->doc);
			}
		}
		
		public string name {
			owned get {
				return ptr->name;
			}
		}
		
		public NodeType node_type {
			get {
				return (NodeType)ptr->type;
			}
		}
	}
}
