package;

import hails.config.DatabaseConfig;
import hails.script.DbMigrator;
import haxe.io.Path;
import sys.io.File;
import sys.FileSystem;
import hails.platform.Platform;

class RunScript {
	
	private static var isLinux:Bool;
	private static var isMac:Bool;
	private static var isWindows:Bool;
	private static var hailsDir:String;
	
	public static function main () {
		
		var isJava = false;
		#if java
		isJava = true;
		#end
		
		if (new EReg ("window", "i").match (Sys.systemName ())) {
			
			isLinux = false;
			isMac = false;
			isWindows = true;
			
		} else if (new EReg ("linux", "i").match (Sys.systemName ())) {
			
			isLinux = true;
			isMac = false;
			isWindows = false;
			
		} else if (new EReg ("mac", "i").match (Sys.systemName ())) {
			
			isLinux = false;
			isMac = true;
			isWindows = false;
			
		}
		
		var args = Sys.args ();
		var command = args[0];
		
		// When the command-line tools are called from haxelib, 
		// the last argument is the project directory and the
		// path to NME is the current working directory 
		
		var lastArgument = new Path (args[args.length - 1]).toString ();
		
		if (((StringTools.endsWith (lastArgument, "/") && lastArgument != "/") || StringTools.endsWith (lastArgument, "\\")) && !StringTools.endsWith (lastArgument, ":\\")) {
			
			lastArgument = lastArgument.substr (0, lastArgument.length - 1);
			
		}
		hailsDir = Sys.getCwd();
		trace(args);
		
		if (FileSystem.exists (lastArgument) && FileSystem.isDirectory (lastArgument)) {
			
			Sys.setCwd (lastArgument);
			args.pop ();
		}
		
		Platform.println("HAILS 0.0.2");
		Platform.println(lastArgument);
		Platform.println(hailsDir);
		
		
		if (args[0] == "migrate") {
			DbMigrator.main();
		} else if (args[0] == "jmigrate") {
			#if java
			DbMigrator.main();
			#else
			var mysqlJar = hailsDir + "jar/mysql-connector-java-5.1.31-bin.jar";
			var sqlserverJar = hailsDir + "jar/sqljdbc4.jar";
			var sqlJar = mysqlJar + ";" + sqlserverJar;

			var args = ["-cp", hailsDir + "jrunner/DbMigrator.jar;config" + ";" + sqlJar, "hails.script.DbMigrator"];
			trace(args);
			runCommand(null, "java", args);
			#end
		}
	}
	
	public static function runCommand (path:String, command:String, args:Array<String>, throwErrors:Bool = true):Int {
		
		var oldPath:String = "";
		
		if (path != null && path != "") {
			
			//trace ("cd " + path);
			
			oldPath = Sys.getCwd ();
			
			try {
				
				Sys.setCwd (path);
				
			} catch (e:Dynamic) {
				
				trace ("Cannot set current working directory to \"" + path + "\"");
				
			}
			
		}
		
		//trace (command + (args==null ? "": " " + args.join(" ")) );
		
		var result:Dynamic = Sys.command (command, args);
		
		//if (result == 0)
		//	trace("Ok.");
			
		
		if (oldPath != "") {
			
			Sys.setCwd (oldPath);
			
		}
		
		if (throwErrors && result != 0) {
			
			Sys.exit (1);
			//throw ("Error running: " + command + " " + args.join (" ") + " [" + path + "]");
			
		}
		
		return result;
		
	}	
	

}
