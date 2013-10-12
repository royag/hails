/**
 * ...
 * @author ...
 */

package hails;
import hails.html.ViewTool;
import hails.platform.IWebContext;
import haxe.ds.StringMap;
import haxe.io.Bytes;
import hails.HailsDbRecord;

class HailsController extends HailsBaseController
{
	static var ERROR_MESSAGE = 'ERROR_MESSAGE';
	static var INFO_MESSAGE = 'INFO_MESSAGE';
	
	public function new(initialAction:String, ctx:IWebContext) {
		super(initialAction, ctx);
		errorMessage = getSession(ERROR_MESSAGE);
		infoMessage = getSession(INFO_MESSAGE);
		setSession(INFO_MESSAGE, null);
		setSession(ERROR_MESSAGE, null);
	}
	
	/**
	 * Override in controller to do before-checks...
	 * @param	action that is to be run is passed in by dispatcher
	 */
	public function before(action:String) : Void {
		
	}
	
	public function setError(errMsg:String) {
		errorMessage = errMsg;
		setSession(ERROR_MESSAGE, errMsg);
	}
	
	public function setInfo(infoMsg:String) {
		infoMessage = infoMsg;
		setSession(INFO_MESSAGE, infoMsg);
	}
	
	/**
	 * @return the GET and POST parameters
	 */
	function getParams() : StringMap<String> {
		return WebCtx.getParams();
	}
	
	/**
	 * 
	 * @param	param
	 * @return  the first value of parameter (may be more)
	 */
	function getParam(param : String) : String {
		return getParams().get(param);
		/*trace(getParams().get(param));
		var p:Array<String> = getParamValues(param);
		trace(p);
		if (p != null && p.length > 0) {
			return p[0];
		}
		return null;*/
	}
	
	function getParamOr(param:String, _default:String) : String {
		var val = getParam(param);
		if (val == null) {
			return _default;
		}
		return val;
	}
	
	function getParamsFor(recName : String) : StringMap<String> {
		var params:StringMap<String> = getParams();
		var rec:StringMap<String> = new StringMap<String>();
		var it:Iterator<String> = params.keys();
		var fn:String;  //'user[name]';
		while (it.hasNext()) {
			fn = it.next();
			if (StringTools.startsWith(fn, recName + ViewTool.PARAM_ARRAY_START)) {
				rec.set(fn.substr(recName.length + 1, fn.length - recName.length - 2),
					params.get(fn));
			}
		}
		return rec;
	}

	/**
	 * @return all the GET parameters String
	 */
	function getParamsString() : String {
		return WebCtx.getParamsString();
	}
	
	function getParamValues(param : String) : Array < String > {
		return WebCtx.getParamValues(param);
	}
	
	function redirect(url : String) {
		WebCtx.sendRedirect(url);
		setAsRendered();
	}

	function isMethod(m:String) : Bool {
		return (WebCtx.getMethod().toUpperCase() == m.toUpperCase());
	}
	
	function isPost() : Bool {
		return isMethod('POST');
	}

	function isGet() : Bool {
		return isMethod('GET');
	}
	
	function getMultipart(maxSize : Int) : StringMap<Blob> {
		return myGetMultipart(maxSize);
	}
	
	function setSession(key:String, val:Dynamic) {
		WebCtx.setSession(key, val);
	}
	function getSession(key:String):Dynamic {
		return WebCtx.getSession(key);
	}
	function getURI() : String {
		return WebCtx.getURI();
	}
	function pathTo(controller:String, action:String, ?anyGetParams:Dynamic) : String {
		return ViewTool.pathTo(controller, action, anyGetParams);
	}
	
	public function h(s:String) : String {
		return ViewTool.h(s);
	}
	
	
	private function myGetMultipart( maxSize : Int ) : StringMap<Blob> {
		#if java
		return null;
		#else
		var h = new StringMap<Blob>();
		var buf : StringBuf = null;
		var curname = null;
		WebCtx.parseMultipart(function(p,fn) {
			if( curname != null )
				h.set(curname,buf.toString());
			curname = p;
			if (fn != null) {
				h.set('input_file_name', fn);  // Added this....
			}
			buf = new StringBuf();
			maxSize -= p.length;
			if( maxSize < 0 )
				throw "Maximum size reached";
		}, function(str,pos,len) {
			maxSize -= len;
			if( maxSize < 0 )
				throw "Maximum size reached";
			buf.addSub(str.toString(),pos,len);
		});
		if( curname != null )
			h.set(curname,buf.toString());
		return h;
		#end
		
	}
}
