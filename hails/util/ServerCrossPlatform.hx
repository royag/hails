/**
 * ...
 * @author ...
 */

package hails.util;
import php.Session;
import php.Web;

class ServerCrossPlatform 
{

	public static function setSession(key:String, val:Dynamic) {
		Session.set(key, val);
	}
	
	public static function getSession(key:String):Dynamic {
		return Session.get(key);
	}
	
	public static function getParams() : Hash < String > {
		return Web.getParams();
	}
	
	public static function getParam(param : String) : String {
		return getParams().get(param);
	}
	
}