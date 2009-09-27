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
}