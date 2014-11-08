package hails.hailsservlet.java.javax.servlet.http ;

/**
 * ...
 * @author test
 */
@:native('javax.servlet.http.HttpSession')
extern interface HttpSession
{
	@:overload public function getAttribute(name:String) : Dynamic;
	@:overload public function setAttribute(name:String, value:Dynamic) : Void; 
}