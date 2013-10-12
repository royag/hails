package javax.servlet.http;


/**
 * ...
 * @author test
 */
extern class HttpServletRequest
{
	
	@:overload public function getMethod() : String;

	@:overload public function getQueryString() : String;
	
	@:overload public function getSession() : HttpSession;
	
	@:overload public function getRequestURI() : String;
	
	/*@:overload*/ public function getParameterMap() : Dynamic; // String; // java.util.Map;
	
	@:overload public function getParameterValues(name:String) : java.NativeArray<String>;
	
	@:overload public function getHeader(key:String) : String;
}