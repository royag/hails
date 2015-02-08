package hails.client.handler;

import hails.client.ModuleMaster;

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

class ClientProgramServer
{

	public function new() 
	{
		
	}
	
	public function createModuleMaster() {
		return new ModuleMaster();
	}	
	
}