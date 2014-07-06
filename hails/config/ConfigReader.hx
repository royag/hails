package hails.config;
import haxe.ds.StringMap;
import haxe.Resource;
import sys.io.File;

/**
 * ...
 * @author Roy
 */
class ConfigReader
{
	public static function getConfigFromFile(fn:String) : StringMap<String> {
		var c = File.getContent(fn);
		if (c == null) {
			return null;
		}
		var map = new StringMap<String>();
		var lines:Array<String> = c.split("\n");
		for (l in lines) {
			var i = l.indexOf(":");
			if (i > 0) {
				var name = l.substring(0, i);
				var val = StringTools.trim(l.substring(i + 1));
				map.set(name, val);
			}
		}
		return map;
	}

	public static function getConfig(configSet:String) : StringMap<String> {
		var c = Resource.getString(configSet);
		var map = new StringMap<String>();
		var lines:Array<String> = c.split("\n");
		for (l in lines) {
			var i = l.indexOf(":");
			if (i > 0) {
				var name = l.substring(0, i);
				var val = StringTools.trim(l.substring(i + 1));
				map.set(name, val);
			}
		}
		return map;
	}
}