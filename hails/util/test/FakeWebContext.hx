package hails.util.test;
import hails.hailsservlet.IWebContext;
import haxe.ds.StringMap;
import haxe.io.Bytes;

import hails.HailsDbRecord;

class FakeWebContext implements IWebContext
{
	var contentTypeSet:Bool = false;
	public function new() 
	{
		
	}
	public static function fromRelativeUriAndMethod(relativeURI:String, method:String) : FakeWebContext {
		var f = new FakeWebContext();
		f.method = method;
		f.relativeURI = relativeURI;
		return f;
	}
	public var params:StringMap<String> ;
	public function getParams() : StringMap<String> {
		return params;
	}
	public var paramsString:String ;
	public function getParamsString() : String {
		return paramsString;
	}
	public var paramValues:Array<String>;
	public function getParamValues(param:String) : Array<String> {
		return paramValues;
	}
	
	public function sendRedirect(url:String) : Void {
	}
	public var method:String;
	public function getMethod() : String {
		return method;
	}
	public function setReturnCode(code:Int) : Void {
	}
	public function setHeader(key:String, value:String) : Void {
	}
	public function addHeader(key:String, value:String) : Void {
	}	
	public function setContentType(ct:String) : Void {
		setHeader("Content-Type", ct);
		contentTypeSet = true;
	}
	public function isContentTypeSet() : Bool {
		return contentTypeSet;
	}
	public function flush() : Void {
	}
	public function printBinary(s:Blob) : Void {
	}
	public function print(s:String) : Void {
	}
	public function println(s:String) : Void {
	}
	public var URI:String;
	public function getURI() : String {
		return URI;
	}
	public var relativeURI:String;
	public function getRelativeURI() : String {
		return relativeURI;
	}
	public function parseMultipart( onPart : String -> String -> Void, onData : Bytes -> Int -> Int -> Void ) : Void {
	}
	public function setSession(key:String, value:Dynamic) : Void {
	}
	public function getSession(key:String) : Dynamic {
		return { };
	}
	public var clientHeaders:StringMap<String> = new StringMap<String>();
	public function getClientHeader(key:String) : String {
		return this.clientHeaders.get(key);
	}
}