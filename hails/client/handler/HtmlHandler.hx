package hails.client.handler;

#if js

import jQuery.JQuery;
import jQuery.JqXHR;
import jQuery.Event;
import jQuery.JQueryStatic;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.Document;
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

typedef JQueryStatic = jQuery.JQueryStatic;
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
typedef TableRowElement =  js.html.TableRowElement;
typedef Browser = js.Browser;

#else
// Server side definitions:

typedef JqXHR = Dynamic; // jQuery.JqXHR;
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
typedef TableRowElement =  ServerHtmlElement;
typedef Browser = ServerBrowser;

#end

class HtmlHandler {
	function new() {
		
	}
}