/**
 * ...
 * @author ...
 */

package hails.util;

class DynamicUtil 
{
	public static function copyFields(targetObj:Dynamic, sourceObj:Dynamic):Dynamic {
		if (sourceObj != null) {
			var it:Iterator<String> = Reflect.fields(sourceObj).iterator();
			var fn:String;
			while (it.hasNext()) {
				fn = it.next();
				Reflect.setField(targetObj, fn, Reflect.field(sourceObj, fn));
			}
		}
		return targetObj;
	}
	
	public static function fieldOrDefault(obj:Dynamic, fieldName:String, dflt:Dynamic) : Dynamic {
		if (obj != null && Reflect.hasField(obj, fieldName)) {
			return Reflect.field(obj, fieldName);
		}
		return dflt;		
	}
}