package hails.hailsservlet.java.javax.servlet.http ;
import java.io.PrintWriter;
import hails.hailsservlet.java.javax.servlet.ServletOutputStream;

/**
 * ...
 * @author test
 */
@:native('javax.servlet.http.HttpServletResponse')
extern class HttpServletResponse
{
	@:overload public function sendRedirect(url:String) : Void;
	
	@:overload public function setStatus(sc:Int) : Void;
	
	@:overload public function getWriter() : PrintWriter;
	@:overload public function getOutputStream() : ServletOutputStream;
	
	@:overload public function setCharacterEncoding(charset:String) : Void;
	@:overload public function setContentType(type:String) : Void;
	@:overload public function setHeader(nane:String,value:String) : Void;
	@:overload public function addHeader(nane:String,value:String) : Void;
	
}