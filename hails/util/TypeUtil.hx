/**
 * ...
 * @author ...
 */

package hails.util;

class TypeUtil 
{
	public static function listToArray < T > (list:List < T > ) : Array < T > {
		var arr = new Array<T>();
		var it = list.iterator();
		var cnt = 0;
		while (it.hasNext()) {
			arr.push(it.next());
		}
		return arr;
	}
	
	public static inline function isIntInited(i:Int) : Bool {
		#if java
		return (i != -1 && i != 0);
		#else
		return (i != null);
		#end
	}
	public static inline function intNotSet(i:Int) : Bool {
		return !isIntInited(i);
	}
	public static inline function intNull() : Int {
		#if java
		return -1;
		#else
		return null;
		#end
	}
}