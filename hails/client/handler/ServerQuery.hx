package hails.client.handler;

import Xml;

class ServerQuery
{

	public var length(get, null):Int;
	
	var master:ServerModuleMaster;
	var nodes:Array<Xml> = new Array<Xml>();
	
	public function new(query:Dynamic, master:ServerModuleMaster) 
	{
		this.master = master;
		if (query == null) {
			return;
		}
		trace("ServerQuery=" + query);
		if (Type.getClass(query) == String) {
			queryString(query);
		} else {
			throw "unsupported query class: " + query;
		}
	}
	
	function queryString(q:String) {
		//trace("queryString");
		if (StringTools.startsWith(q, "#")) {
			queryId(master.xml, q.substr(1));
		} else if (StringTools.startsWith(q, ".")) {
			queryClass(master.xml, q.substr(1));
		} else {
			throw "unsupported query: " + q;
		}
	}
	
	function queryClass(root:Xml, cl:String) {
		//trace("queryClass");
		for (node in root) {
			if (node.nodeType == Xml.Element) {
				for (attr in node.attributes()) {
					if (attr.toLowerCase() == "class") {
						var thisClass = node.get(attr);
						for (c in thisClass.split(" ")) {
							if (c == cl) {
								//trace("found:" + node);
								nodes.push(node);
							}
						}
					}
				}
				if (node.nodeType == Xml.Element) {
					queryClass(node, cl);
				}
			}
		}
	}	
	
	function queryId(root:Xml, id:String) {
		//trace("queryId");
		for (node in root) {
			//trace("Starting at " + node);
			if (node.nodeType == Xml.Element) {
				for (attr in node.attributes()) {
					if (attr.toLowerCase() == "id") {
						var thisId = node.get(attr);
						if (thisId == id) {
							//trace("found:" + node);
							nodes.push(node);
							return;
						}
					}
				}
				if (node.nodeType == Xml.Element) {
					queryId(node, id);
				}
			}
		}
	}
	
	public function append(e:ServerHtmlElement) {
		
	}
	
	public function show() {
		
	}
	
	public function hide() {
		
	}
	
	function get_length() {
		return nodes.length;
	}
	
	public function html(content:String = null) {
		if (content == null) {
			return ""; // get content
		}
		return ""; // set content
	}
	
	public function find(what:String) : ServerQuery {
		return new ServerQuery(null, master);
	}
	
	public function on(eventName:String, handler:Dynamic->Void) {
		
	}
	
	public function focus() {
		
	}
	
	public function remove() {
		
	}
	
	public function empty() {
		
	}
	
	public function click(handler:Dynamic->Void) {
		
	}
	public function change(handler:Dynamic->Void) {
		
	}
	public function removeClass(c:String) {
		
	}
	
	public function addClass(c:String) {
		
	}
	
	public function iterator() {
		return new Array<ServerHtmlElement>().iterator();
	}
	
	public function filter(thefilter:Int->ServerHtmlElement->Bool) {
		return new ServerQuery(null, master);
	}
	
	var thevalue:Dynamic = null;
	public function val(v:Dynamic = null) : Dynamic {
		if (v != null) {
			thevalue = v;
		}
		return thevalue;
	}
	
}