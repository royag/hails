package javax.servlet;

/**
 * ...
 * @author test
 */
extern class ServletOutputStream
{
	@:overload public function print(s:String) : Void;
	@:overload public function println(s:String) : Void;
	@:overload public function flush() : Void;
}