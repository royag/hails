/**
* ...
* @author Default
*/

package hails;

import php.HException;
import php.Lib;
import php.Web;

class HailsPhpRenderer {
	public static inline function includePhp(fn:String) {
		untyped __call__("include", fn);	
	}
}