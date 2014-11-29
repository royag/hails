package ;

import haxe.ds.StringMap;
import haxe.io.Path;
import sys.io.File;
import sys.io.Process;
import sys.FileSystem;
import hails.platform.Platform;

class PhpBuilder extends HailsBuilder
{
	
	function addResourceDirsPhp(dest:String) {
		for (resdir in getResourceDirs()) {
			var lastSlash = resdir.lastIndexOf("/");
			if (lastSlash < 0) {
				lastSlash = resdir.lastIndexOf("\\");
			}
			
			var destDir = resdir;
			if (lastSlash > 0) {
				destDir = resdir.substr(lastSlash + 1);
			}
			//RunScript.recursiveCopy("view", dest + "/res/view", null, ".pl", dest + "/res/"); // !NB!: .pl(perl)-extension so it (usually) won't be able to load directly from webroot
			RunScript.recursiveCopy(resdir, dest + "/res/" + destDir, null, ".pl", dest + "/res/", !RunScript.verbose); // !NB!: .pl(perl)-extension so it (usually) won't be able to load directly from webroot
		}		
	}
	
	public function build(hailsPath:String, workPath:String, args:Array<String>, unitTest:Bool=false) {
		createWebAppHx(hailsPath, workPath);
		var dest = "phpout";
		RunScript.removeDirectory(dest + "/res");
		RunScript.removeDirectory(dest + "/lib");
		RunScript.removeDirectory(dest);
		var main = "controller.WebApp";
		if (unitTest) {
			dest = "phptest";
			main = "test.unit.TestSuite";
		}		
		var haxeArgs = ["-php", dest, "-main", main, "-cp", ".", "-lib", "hails"].concat(getHaxeLibArgs());
		
		haxeArgs.push("-resource");
		haxeArgs.push("config/dbconfig@dbconfig.pl"); // !NB!: .pl(perl)-extension so it (usually) won't be able to load directly from webroot
		
		RunScript.removeDirectory(dest + "/res");
		var code = RunScript.runCommand(workPath, "haxe", haxeArgs);
		if (code != 0) {
			throw "build failed: " + code;
		}
		
		Sys.println("Copying resources...");
		RunScript.recursiveCopy("view", dest + "/res/view", null, ".pl", dest + "/res/", !RunScript.verbose); // !NB!: .pl(perl)-extension so it (usually) won't be able to load directly from webroot
		addResourceDirsPhp(dest);
		
		Sys.println("Copying nbproject...");
		RunScript.recursiveCopy(hailsPath + "templates/phpnbproject", dest + "/nbproject", null, null, null, !RunScript.verbose);
		
		var webFolder = WEB_FOLDER;
		
		if (FileSystem.exists (webFolder) && FileSystem.isDirectory (webFolder)) {
		} else {
			RunScript.recursiveCopy(hailsPath + "templates/war", webFolder);
		}
		//RunScript.removeDirectory("javaout/war");
		
		Sys.println("Copying from " + webFolder + "...");
		RunScript.recursiveCopy(WEB_FOLDER, dest, ["META-INF", "WEB-INF"], null, null, !RunScript.verbose);		
		
		buildJs(hailsPath, workPath, dest, "phpweb");
		
		if (unitTest) {
			Platform.println("[[[[ Unit Testing PHP target ]]]]");
			RunScript.runCommand(workPath, "php", [dest + "/index.php"]);
		} else {
			if (args.length > 2 && args[2] == "livetest") {
				HailsLiveTester.justTest(workPath, "http://localhost/index.php/");
			}		
		}
	}	
	
}