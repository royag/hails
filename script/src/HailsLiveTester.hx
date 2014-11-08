package ;

import hails.platform.Platform;
import sys.io.Process;

/**
 * ...
 * @author Roy
 */
class HailsLiveTester
{

	public static function runThenTest (path:String, command:String, args:Array<String>, baseUrl:String):Int {
		Platform.println("building live-tests");
		var ret = buildLiveTests(path);
		if (ret != 0) {
			Platform.println("Building tests failed.");
		}
		var oldPath:String = "";
		if (path != null && path != "") {
			//trace ("cd " + path);
			oldPath = Sys.getCwd ();
			try {
				Sys.setCwd (path);
			} catch (e:Dynamic) {
				Platform.println ("Cannot set current working directory to \"" + path + "\"");
			}
		}
		Platform.println("Starting server...");
		var p:Process = new Process(command, args);
		if (oldPath != "") {
			Sys.setCwd (oldPath);
		}
		Platform.println("Waiting a little for server to start...");
		Sys.sleep(3);
		Platform.println("Running live-tests");
		runLiveTests(path);
		Platform.println("Killing server...");
		p.kill();
		return 0;
	}
	
	static function buildLiveTests(workPath:String) : Int {
		var haxeArgs = ["-neko", "livetest.n", "-main", "test.integration.TestSuite", "-cp", ".", "-lib", "hails"];
		return RunScript.runCommand(workPath, "haxe", haxeArgs);
	}
	static function runLiveTests(workPath:String) {
		RunScript.runCommand(workPath, "neko", ["livetest.n"]);
	}
	
}