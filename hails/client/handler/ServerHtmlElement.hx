package hails.client.handler;


class ServerHtmlElement
{

	public var selected:Bool = false;
	public var disabled:Bool = false;
	public var src:String = "";
	public var innerHTML:String = "";
	
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