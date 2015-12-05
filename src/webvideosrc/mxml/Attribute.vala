namespace Mxml {
	public class Attributes : GLib.Object {
		HashTable<string, string> attrs;
		
		internal Attributes (Xml.Node* node) {
			attrs = new HashTable<string, string>(str_hash, str_equal);
			var _keys = new string[0];
			var _values = new string[0];
			var prop = node->properties;
			while (prop != null) {
				attrs[prop->name] = prop->children->content;
				_keys += prop->name;
				_values += prop->children->content;
				prop = prop->next;
			}
			keys = _keys;
			values = _values;
		}
		
		public void foreach (HFunc<string, string> func) {
			attrs.foreach (func);
		}
		
		public new string? get (string key) {
			return attrs[key];
		}
		
		public string[] keys { get; private set; }
		public string[] values { get; private set; }
		
		public int size {
			get {
				return (int)attrs.length;
			}
		}
	}
}
