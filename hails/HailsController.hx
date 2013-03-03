/**
 * ...
 * @author ...
 */

package hails;
import hails.html.ViewTool;
import php.Session;
import php.Web;

class HailsController extends HailsBaseController
{
	static var ERROR_MESSAGE = 'ERROR_MESSAGE';
	static var INFO_MESSAGE = 'INFO_MESSAGE';
	
	public function new(initialAction:String) {
		super(initialAction);
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
	function getParams() : Hash < String > {
		return Web.getParams();
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
	
	function getParamsFor(recName : String) : Hash < String > {
		var params:Hash<String> = getParams();
		var rec:Hash<String> = new Hash<String>();
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
		return Web.getParamsString();
	}
	
	function getParamValues(param : String) : Array < String > {
		return Web.getParamValues(param);
	}
	
	function redirect(url : String) {
		Web.redirect(url);
		setAsRendered();
	}

	function isMethod(m:String) : Bool {
		return (Web.getMethod().toUpperCase() == m.toUpperCase());
	}
	
	function isPost() : Bool {
		return isMethod('POST');
	}

	function isGet() : Bool {
		return isMethod('GET');
	}
	
	function getMultipart(maxSize : Int) : Hash < String > {
		return myGetMultipart(maxSize);
	}
	
	function setSession(key:String, val:Dynamic) {
		Session.set(key, val);
	}
	function getSession(key:String):Dynamic {
		return Session.get(key);
	}
	function pathTo(controller:String, action:String, ?anyGetParams:Dynamic) : String {
		return ViewTool.pathTo(controller, action, anyGetParams);
	}
	
	public function h(s:String) : String {
		return ViewTool.h(s);
	}
	
	private static function myGetMultipart( maxSize : Int ) : Hash<String> {
		var h = new Hash();
		var buf : StringBuf = null;
		var curname = null;
		Web.parseMultipart(function(p,fn) {
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
	}
}
