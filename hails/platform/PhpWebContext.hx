package hails.platform;
import php.Lib;
import php.Session;
import php.Web;
import haxe.ds.StringMap;
import haxe.io.Bytes;
/**
 * ...
 * @author test
 */
class PhpWebContext implements IWebContext
{
	var contentTypeSet:Bool = false;

	
	public function new() 
	{
		
	}
	
	public function getParams() : StringMap<String> {
		return Web.getParams();
	}
	public function getParamsString() : String {
		return Web.getParamsString();
	}
	public function getParamValues(param:String) : Array<String> {
		return Web.getParamValues(param);
	}
	
	public function sendRedirect(url:String) : Void {
		Web.redirect(url);
	}
	
	public function getMethod() : String {
		return Web.getMethod();
	}
	public function setReturnCode(code:Int) : Void {
		Web.setReturnCode(code);
	}
	public function setHeader(key:String, value:String) : Void {
		Web.setHeader(key,value);
	}
	
	public function setContentType(ct:String) : Void {
		setHeader("Content-Type", ct);
		contentTypeSet = true;
	}
	public function isContentTypeSet() : Bool {
		return contentTypeSet;
	}
	
	
	public function flush() : Void {
		Web.flush();
	}
	public function printBinary(s:Blob) : Void {
		print(s);
	}

	public function print(s:String) : Void {
		Lib.print(s);
	}
	public function println(s:String) : Void {
		Lib.println(s);
	}
	public function getURI() : String {
		return Web.getURI();
	}
	public function parseMultipart( onPart : String -> String -> Void, onData : Bytes -> Int -> Int -> Void ) : Void {
		Web.parseMultipart(onPart, onData);
	}
	public function setSession(key:String, value:Dynamic) : Void {
		Session.set(key, value);
	}
	public function getSession(key:String) : Dynamic {
		return Session.get(key);
	}
	public function getClientHeader(key:String) : String {
		return Web.getClientHeader(key);
	}

	
}