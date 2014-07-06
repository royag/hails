package javax.servlet.http;

import java.NativeArray;

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
	
	/*@:overload*/ public function getParameterMap() : Dynamic; // java.util.Map < String, NativeArray<String> > ;
	
	@:overload public function getParameterValues(name:String) : java.NativeArray<String>;
	
	@:overload public function getHeader(key:String) : String;
}