package ;

import haxe.ds.StringMap;
import haxe.io.Path;
import sys.io.File;
import sys.io.Process;
import sys.FileSystem;
import hails.platform.Platform;

class NekoBuilder extends HailsBuilder
{

	public function build(hailsPath:String, workPath:String, args:Array<String>, unitTest:Bool=false) {
		createWebAppHx(hailsPath, workPath);
		RunScript.removeDirectory("nekoout");
		RunScript.mkdir("nekoout");
		var dest = "./nekoout";
		var destNekoFile = "./nekoout/index.n";
		var main = "controller.WebApp";
		if (unitTest) {
			dest = "./nekoout/unittest.n";
			main = "test.unit.TestSuite";
		}
		var haxeArgs = ["-neko", destNekoFile, "-main", main, "-cp", ".", "-lib", "hails"].concat(getHaxeLibArgs());
		
		haxeArgs.push("-resource");
		haxeArgs.push("config/dbconfig@dbconfig");
		
		RunScript.runCommand(workPath, "haxe", haxeArgs);
		
		if (FileSystem.exists (WEB_FOLDER) && FileSystem.isDirectory (WEB_FOLDER)) {
		} else {
			RunScript.recursiveCopy(hailsPath + "templates/war", WEB_FOLDER);
		}
		
		Sys.println("Copying from " + WEB_FOLDER + "...");
		RunScript.recursiveCopy(WEB_FOLDER, dest, ["META-INF", "WEB-INF"], null, null, !RunScript.verbose);		
		
		buildJs(hailsPath, workPath, dest, "nekoweb");		
		
		if (unitTest) {
			Platform.println("[[[[ Unit Testing NEKO target ]]]]");
			RunScript.runCommand(workPath, "neko", [destNekoFile]);
		} else {
			var nekoArgs = ["server", "-p", "2000", "-h", "localhost", "-d", "nekoout", "-rewrite"];
			if (args.length > 2 && args[2] == "run") {
				RunScript.runCommand(workPath, "nekotools", nekoArgs);
			} else if (args.length > 2 && args[2] == "livetest") {
				HailsLiveTester.runThenTest(workPath, "nekotools", nekoArgs, "http://localhost:2000/");
			}
		}
	}	
	
}