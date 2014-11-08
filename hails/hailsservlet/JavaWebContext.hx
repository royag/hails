package hails.hailsservlet ;
import java.io.PrintWriter;
import hails.hailsservlet.java.javax.servlet.http.HttpServletRequest;
import hails.hailsservlet.java.javax.servlet.http.HttpServletResponse;
import hails.hailsservlet.java.javax.servlet.http.HttpSession;
import haxe.ds.StringMap;
import haxe.io.Bytes;
import java.util.Map;
import java.util.Set;
import java.Lib;
import java.io.IOException;
import hails.hailsservlet.java.javax.servlet.ServletOutputStream;
import java.io.PrintWriter;
import java.NativeArray;
import hails.HailsDbRecord;

/**
 * ...
 * @author test
 */
class JavaWebContext implements IWebContext
{
	var request:HttpServletRequest;
	var response:HttpServletResponse;
	//var outStream:ServletOutputStream;
	var _outStream:PrintWriter;
	var contentTypeSet:Bool = false;
	public function new(req:HttpServletRequest, resp:HttpServletResponse) 
	{
		this.request = req;
		this.response = resp;
		//this.response.setContentType("image/jpeg");
		//this.response.setCharacterEncoding("UTF-8");
		
	}
	
	public function setContentType(ct:String) : Void {
		this.response.setContentType(ct);
		contentTypeSet = true;
	}
	public function isContentTypeSet() : Bool {
		return contentTypeSet;
	}
	

	private function outStream() {
		if (this._outStream == null) {
			try {
				//this.outStream = resp.getOutputStream();
				this._outStream = response.getWriter();
				//this.outStream.
			} catch (e:IOException) {
				throw "ERR: " + e.getMessage();
			}
		}
		return this._outStream;
	}
	public function getParams() : StringMap<String> {
		var a:NativeArray<String> = null;
		var b:java.util.Map < String, NativeArray<String> > = null;
		var m = request.getParameterMap();
		// HAXE bug: java.util.Map<String,NativeArray<String>> resolves to Map<String,Object[]>
		//var map :java.util.Map<String,NativeArray<String>> = request.getParameterMap();
		var ret = new StringMap<String>();
		var keys:java.util.Set<String> = untyped __java__("((java.util.Map<String,String[]>)m).keySet()");
		//map.keySet();
		var it:java.util.Iterator<Dynamic> = cast(keys.iterator(), java.util.Iterator<Dynamic>);
		while (it.hasNext()) {
			var k = it.next();
			//ret.set(k.toString(), map.get(k)[0].toString());
			ret.set(k.toString(), untyped __java__("((java.util.Map<String,String[]>)m).get(k)[0].toString()"));
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
		response.setStatus(code);
	}
	public function setHeader(key:String, value:String) : Void {
		response.setHeader(key, value);
	}
	public function addHeader(key:String, value:String) : Void {
		response.addHeader(key, value);
	}	
	public function flush() : Void {
		//try {
		if (_outStream != null) {
			outStream().flush();
		} else {
			try {
			response.getOutputStream().flush();
			} catch (e:IOException) {
				throw "ERR: " + e.getMessage();
			}
		}
		/*} catch (e:IOException) {
			throw "ERR: " + e.getMessage();
		}*/		
	}
	public function print(s:String) : Void {
		//try {
			outStream().print(s);
		/*} catch (e:IOException) {
			throw "ERR: " + e.getMessage();
		}*/		
	}
	public function printBinary(s:Blob) : Void {
		try {
			response.getOutputStream().write(s.getData());
		} catch (e:IOException) {
			throw "ERR: " + e.getMessage();
		}
	}	
	public function println(s:String) : Void {
		//try {
			outStream().println(s);
		/*} catch (e:IOException) {
			throw "ERR: " + e.getMessage();
		}*/		
	}
	public function getURI() : String {
		return request.getRequestURI();
	}
	
	public function getRelativeURI() : String {
		var sp = request.getServletPath();
		var uri = getURI();
		if (uri.indexOf(sp) == 0) {
			return uri.substring(sp.length);
		}
		return uri; // couldnt determine
	}
	
	public function parseMultipart( onPart : String -> String -> Void, onData : Bytes -> Int -> Int -> Void ) : Void {
		
	}
	public function setSession(key:String, value:Dynamic) : Void {
		request.getSession().setAttribute(key, value);
	}
	public function getSession(key:String) : Dynamic {
		return request.getSession().getAttribute(key);
	}
	public function getClientHeader(key:String) : String {
		return request.getHeader(key);
	}	
	
}