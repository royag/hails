package hails.client.handler;

import hails.client.ModuleMaster;
import hails.client.handler.ServerModuleMaster;

/*typedef JqXHR = Dynamic; // jQuery.JqXHR;
typedef JQueryStatic = ServerQueryStatic;
typedef JQuery = ServerQuery;
typedef Event = Dynamic; // jQuery.Event;

typedef CanvasElement = ServerHtmlElement;
typedef CanvasRenderingContext2D =  ServerCanvasRenderingContext;
typedef Document =  ServerHtmlElement;
typedef Element =  ServerHtmlElement;
typedef HeadElement =  ServerHtmlElement;
typedef ImageElement =  ServerHtmlElement;
typedef Node =  ServerHtmlElement;
typedef NodeList =  ServerHtmlElement;
typedef OptionElement =  ServerHtmlElement;
typedef ParagraphElement =  ServerHtmlElement;
typedef SpanElement =  ServerHtmlElement;
typedef TableCellElement = ServerHtmlElement;
typedef TableColElement =  ServerHtmlElement;
typedef TableElement =  ServerHtmlElement;
typedef TableRowElement =  ServerHtmlElement;*/

class ServerDocument {
	public function new() {
		
	}
	public function createElement(tagName:String) {
		return new ServerHtmlElement(tagName);
	}
	public function getElementById(id:String) : ServerHtmlElement {
		return null;
	}
	public function getElementsByClassName(cname:String) : Array<ServerHtmlElement> {
		return [];
	}
}

class ClientProgramServer
{
	
	public var document(get, null):ServerDocument;
	public var window(get, null):Dynamic;
	
	var master:ModuleMaster;
	
	public function new(master:ModuleMaster = null) 
	{
		if (master == null) {
			this.master = createModuleMaster();
		} else {
			this.master = master;
		}
	}
	
	function get_document() {
		//return Browser.document;
		return new ServerDocument();
	}
	
	function get_window() {
		//return Browser.window;
		return { };
	}	
	
	public function createModuleMaster() {
		return new ServerModuleMaster();
	}
	
	public function getServerModuleMaster() : ServerModuleMaster {
		return cast(master);
	}
	
	public inline function get(url:String, data:Dynamic, callback:Dynamic->String->Dynamic->Void) : Dynamic {
		//return JQueryStatic.get(url, data, callback);
		trace("GET: " + url);
		callback( ["dummy","dummy", "data"], "200", { } );
		return { };
	}
	
	public inline function post(url:String, data:Dynamic, callback:Dynamic->String->Dynamic->Void) : Dynamic {
		//return JQueryStatic.post(url, data, callback);
		trace("POST: " + url);
		callback( ["dummy","dummy", "data"], "200", {});
		return { };
	}
	public inline function jqueryOnReady(runner:Void->Void) {
		runner();
	}
	public inline function jquery(query:Dynamic) : ServerQuery {
		//return new JQuery(query);
		return new ServerQuery(query, getServerModuleMaster());
	}
	
}