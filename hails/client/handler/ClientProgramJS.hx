package hails.client.handler;

import js.Browser;
import js.html.Document;
import js.html.DOMWindow;

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
	
}