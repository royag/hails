package javax.servlet.http;

/**
 * ...
 * @author test
 */
extern interface HttpSession
{
	@:overload public function getAttribute(name:String) : Dynamic;
	@:overload public function setAttribute(name:String, value:Dynamic) : Void; 
}