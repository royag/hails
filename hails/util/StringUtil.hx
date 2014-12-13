
package hails.util;

class StringUtil {

	public static function isLowerCase(s:String) : Bool {
		return (s == s.toLowerCase());
	}
	
	public static function isUpperCase(s:String) : Bool {
		return (s == s.toUpperCase());
	}
	
	public static function camelize(s:String) : String {
		return _camelizeWithFirstAsLower(s, false);
	}

	public static function camelizeWithFirstAsLower(s:String) : String {
		return _camelizeWithFirstAsLower(s, true);
	}
	
	public static function removePackageNameFromClassName(cname:String) : String {
		var ret = "";
		for (i in 0...cname.length) {
			if (cname.charAt(i) == '.') {
				ret = "";
			} else {
				ret += cname.charAt(i);
			}
		}
		return ret;
	}
	
	public static function tableize(s:String) {
		var lastwaslower = false;
		var ret = "";
		for (i in 0...s.length) {
			if (lastwaslower && isUpperCase(s.charAt(i))) {
				ret += "_";
				ret += s.charAt(i).toLowerCase();
				lastwaslower = false;
			} else {
				if (isUpperCase(s.charAt(i))) {
					lastwaslower = false;
				} else {
					lastwaslower = true;
				}
				ret += s.charAt(i).toLowerCase();
			}
		}
		return ret;
	}
	
	public static function _camelizeWithFirstAsLower(s:String, firstAsLower:Bool) : String {
		var ret:String = "";
		var newWord:Bool = true;
		for (i in 0...s.length) {
			if (s.charAt(i) == "_") {
				newWord = true;
			} else {
				if (newWord) {
					if (i == 0 && firstAsLower) {
						ret += s.charAt(i).toLowerCase();
					} else {
						ret += s.charAt(i).toUpperCase();
					}
					newWord = false;
				} else {
					ret += s.charAt(i).toLowerCase();
				}
			}
		}
		return ret;
	}
	
	public static function endsWithAnyOf(s:String, ends:Array < String > ) : Bool {
		var it:Iterator<String> = ends.iterator();
		while (it.hasNext()) {
			if (StringTools.endsWith(s, it.next())) {
				return true;
			}
		}
		return false;
	}
}