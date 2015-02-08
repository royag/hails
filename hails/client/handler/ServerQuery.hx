package hails.client.handler;


class ServerQuery
{

	public var length(get, null):Int;
	
	public function new(query:Dynamic) 
	{
		
	}
	
	public function append(e:ServerHtmlElement) {
		
	}
	
	public function show() {
		
	}
	
	public function hide() {
		
	}
	
	function get_length() {
		return 0;
	}
	
	public function html(content:String = null) {
		if (content == null) {
			return ""; // get content
		}
		return ""; // set content
	}
	
	public function find(what:String) : ServerQuery {
		return new ServerQuery(null);
	}
	
	public function remove() {
		
	}
	
	public function empty() {
		
	}
	
	public function click(handler:Dynamic->Void) {
		
	}
	public function change(handler:Dynamic->Void) {
		
	}
	
	public function filter(thefilter:Int->ServerHtmlElement->Bool) {
		return new ServerQuery(null);
	}
	
	var thevalue:Dynamic = null;
	public function val(v:Dynamic = null) : Dynamic {
		if (v != null) {
			thevalue = v;
		}
		return thevalue;
	}
	
}