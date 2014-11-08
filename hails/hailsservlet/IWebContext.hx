package hails.hailsservlet ;
import haxe.ds.StringMap;
import haxe.io.Bytes;
import hails.HailsDbRecord;
/**
 * ...
 * @author test
 */
interface IWebContext
{
	public function getParams() : StringMap<String>;
	public function getParamsString() : String;
	public function getParamValues(param:String) : Array<String>;
	public function sendRedirect(url:String) : Void;
	public function getMethod() : String;
	public function setReturnCode(code:Int) : Void;
	public function setHeader(key:String, value:String) : Void;
	public function addHeader(key:String, value:String) : Void;
	public function setContentType(ct:String) : Void;
	public function isContentTypeSet() : Bool;
	public function flush() : Void;
	public function printBinary(s:Blob) : Void;
	public function print(s:String) : Void;
	public function println(s:String) : Void;
	public function getURI() : String;
	public function getRelativeURI() : String;
	public function parseMultipart( onPart : String -> String -> Void, onData : Bytes -> Int -> Int -> Void ) : Void;
	public function setSession(key:String, value:Dynamic) : Void;
	public function getSession(key:String) : Dynamic;
	public function getClientHeader(key:String) : String;
}