package hails.client.handler;


class Attrs {
	public function new() {
		
	}
	public function getNamedItem(n:String) : ServerHtmlElement {
		var dummy = new ServerHtmlElement(n);
		dummy.nodeValue = "";
		return dummy;
	}
}

class ServerHtmlElement
{
	public var nodeValue:String = "";
	public var selected:Bool = false;
	public var disabled:Bool = false;
	public var src:String = "";
	public var innerHTML:String = "";
	public var attributes:Attrs = new Attrs();
	
	var tagName:String = "";
	
	public function new(tagName:String) 
	{
		this.tagName = tagName;
	}
	
	public function addEventListener(type:String, listener:Dynamic->Void) {
		
	}
	
	public function appendChild(elem:ServerHtmlElement) {
		
	}
	
	public function setAttribute(name:String, val:String) {
		
	}
	
}