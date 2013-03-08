package hails.platform;
import java.io.PrintWriter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import haxe.ds.StringMap;
import haxe.io.Bytes;
import java.util.Map;
import java.util.Set;
import java.Lib;
import java.io.IOException;
import javax.servlet.ServletOutputStream;

/**
 * ...
 * @author test
 */
class JavaWebContext implements IWebContext
{
	var request:HttpServletRequest;
	var response:HttpServletResponse;
	var outStream:ServletOutputStream;
	public function new(req:HttpServletRequest, resp:HttpServletResponse) 
	{
		this.request = req;
		this.response = resp;
		this.response.setCharacterEncoding("UTF-8");
		try {
			this.outStream = resp.getOutputStream();
		} catch (e:IOException) {
			throw "ERR: " + e.getMessage();
		}
	}
	public function getParams() : StringMap<String> {
		var map:java.util.Map<String,String> = request.getParameterMap();
		var ret = new StringMap<String>();
		var keys:java.util.Set<String> = map.keySet();
		var it:java.util.Iterator<Dynamic> = cast(keys.iterator(), java.util.Iterator<Dynamic>);
		while (it.hasNext()) {
			var k = it.next();
			ret.set(k.toString(), map.get(k).toString());
		}
		return ret;
		//return JavaWebContext.toStringMap(request.getParameterMap());
	}
	public function getParamsString() : String {
		return request.getQueryString();
	}
	public function getParamValues(param:String) : Array<String> {
		return Lib.array(request.getParameterValues(param));
	}
	public function sendRedirect(url:String) : Void {
		
	}
	public function getMethod() : String {
		return request.getMethod();
	}
	public function setReturnCode(code:Int) : Void {
		
	}
	public function setHeader(key:String, value:String) : Void {
		
	}
	public function flush() : Void {
		try {
			outStream.flush();
		} catch (e:IOException) {
			throw "ERR: " + e.getMessage();
		}		
	}
	public function print(s:String) : Void {
		try {
			outStream.print(s);
		} catch (e:IOException) {
			throw "ERR: " + e.getMessage();
		}		
	}
	public function println(s:String) : Void {
		try {
			outStream.println(s);
		} catch (e:IOException) {
			throw "ERR: " + e.getMessage();
		}		
	}
	public function getURI() : String {
		return request.getRequestURI();
	}
	public function parseMultipart( onPart : String -> String -> Void, onData : Bytes -> Int -> Int -> Void ) : Void {
		
	}
	public function setSession(key:String, value:Dynamic) : Void {
		request.getSession().setAttribute(key, value);
	}
	public function getSession(key:String) : Dynamic {
		return request.getSession().getAttribute(key);
	}
	
}