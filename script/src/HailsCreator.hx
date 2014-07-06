package ;
import hails.platform.Platform;

import sys.io.File;
import sys.io.Process;
import sys.FileSystem;

/**
 * ...
 * @author Roy
 */
class HailsCreator
{

	public static function create(hailsPath:String, workPath:String, args:Array<String>) {
		if (args.length < 2) {
			Platform.println("You must specify where to create project");
		}
		if (args.length == 2) {
			var dir = args[1];
			RunScript.recursiveCopy(hailsPath + "templates/basic", dir);
			FileSystem.rename(dir + "/Basic.hxproj", dir + "/" + dir + ".hxproj");
		}
	}
	
}