package hails.client.handler;

import hails.client.ModuleMaster;

import jQuery.JQuery;
import jQuery.JqXHR;
import jQuery.Event;
import jQuery.JQueryStatic;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.Document;
import js.html.DOMWindow;
import js.html.Element;
import js.html.HeadElement;
import js.html.ImageElement;
import js.html.Node;
import js.html.NodeList;
import js.html.OptionElement;
import js.html.ParagraphElement;
import js.html.SpanElement;
import js.html.TableCellElement;
import js.html.TableColElement;
import js.html.TableElement;
import js.html.TableRowElement;
import js.Browser;

/*typedef JQueryStatic = jQuery.JQueryStatic;
typedef JQuery = jQuery.JQuery;
typedef JqXHR = jQuery.JqXHR;
typedef Event = jQuery.Event;

typedef CanvasElement = js.html.CanvasElement;
typedef CanvasRenderingContext2D =  js.html.CanvasRenderingContext2D;
typedef Document =  js.html.Document;
typedef Element =  js.html.Element;
typedef HeadElement =  js.html.HeadElement;
typedef ImageElement =  js.html.ImageElement;
typedef Node =  js.html.Node;
typedef NodeList =  js.html.NodeList;
typedef OptionElement =  js.html.OptionElement;
typedef ParagraphElement =  js.html.ParagraphElement;
typedef SpanElement =  js.html.SpanElement;
typedef TableCellElement =  js.html.TableCellElement;
typedef TableColElement =  js.html.TableColElement;
typedef TableElement =  js.html.TableElement;
typedef TableRowElement =  js.html.TableRowElement;*/

class ClientProgramJS
{

	public var document(get, null):Document;
	public var window(get, null):DOMWindow;
	
	public function new() 
	{
	}
	
	inline function get_document() {
		return Browser.document;
	}
	
	inline function get_window() {
		return Browser.window;
	}
	
	inline function createModuleMaster() {
		return new ModuleMaster();
	}
	
	public inline function get(url:String, data:Dynamic, callback:Dynamic->String->JqXHR->Void) : JqXHR {
		return JQueryStatic.get(url, data, callback);
	}
	
	public inline function post(url:String, data:Dynamic, callback:Dynamic->String->JqXHR->Void) : JqXHR {
		return JQueryStatic.post(url, data, callback);
	}
	
	public inline function jquery(query:Dynamic) : JQuery {
		return new JQuery(query);
	}
	
}