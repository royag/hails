package hails.client.handler;
import hails.client.ModuleMaster;


class ServerModuleMaster extends ModuleMaster
{

	public var html(get,set):String;
	public var xml(default,null):Xml = null;
	
	public function new() 
	{
		super();
	}
	
	function set_html(html:String) : String {
		xml = Xml.parse(html);
		return html;
	}
	
	function get_html() : String {
		return xml.toString();
	}
	
	
	
}