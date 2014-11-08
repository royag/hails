package hails.hailsservlet.java.javax.servlet.http ;

/**
 * ...
 * @author test
 */
@:native('javax.servlet.http.HttpServlet')
extern class HttpServlet
{
	@:overload private function doGet(req:HttpServletRequest,resp:HttpServletResponse) : Void;
	@:overload private function doPost(req:HttpServletRequest,resp:HttpServletResponse) : Void;
	@:overload private function doPut(req:HttpServletRequest,resp:HttpServletResponse) : Void;
	@:overload private function doDelete(req:HttpServletRequest,resp:HttpServletResponse) : Void;
}