/**
* ...
* @author Default
*/

package hails.script;

import hails.util.StringUtil;
import sys.FileSystem;
//import php.Session;

import sys.io.File;
#if neko
import neko.Lib;
#else
#end
import hails.platform.Platform;
//import sys.Sys;

class DbMigrator {

	//static var rootDir:String = "C:/projects/hails/src/";

	static function getRootDir() {
		return FileSystem.fullPath('.') + "/";		
	}
	
	public static function main() {
		//trace(haxe.Resource.getString("dbconfig"));
		//if (Sys.args().length > 0) {
		//	if (Sys.args()[0] == "migrate") {
				migrateDatabase();
		//	} else {
		//		showHelp();
		//	}
		//} else {
		//		showHelp();
		//}
	}
	
	public static function showHelp() {
			Platform.println("Usage: hailsgen [command]\n");
			Platform.println("Commands:");
			Platform.println("     migrate       migrate database");
	}
	
	public static function migrateDatabase() {
		var cparser:CodeParser = new CodeParser(getRootDir());
		var count = 0;
		var modelDir = getRootDir() + "model";
		for (fn in FileSystem.readDirectory(modelDir)) {
			if (StringTools.endsWith(fn, ".hx")) {
				var modelName = fn.substr(0, fn.length - 3);
				Platform.println("----------------|" + modelName);
				var h:Map < String, DbFieldInfo > = cparser.findPublicProperties("model." + modelName, null);
				DbManipulator.createOrAlterTable(StringUtil.tableize(modelName), h);
				count += 1;
			}
		}
		if (count == 0) {
			Platform.println("Found no models to migrate in " + modelDir);
		}
	}
	
}