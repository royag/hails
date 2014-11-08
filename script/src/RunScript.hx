package;

import hails.config.DatabaseConfig;
import hails.script.DbMigrator;
import haxe.io.Path;
import sys.io.File;
import sys.io.Process;
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
		//trace(args);
		
		if (FileSystem.exists (lastArgument) && FileSystem.isDirectory (lastArgument)) {
			
			Sys.setCwd (lastArgument);
			args.pop ();
		}
		var workDir = lastArgument;
		Platform.println("HAILS 0.0.2");
		Platform.println(lastArgument);
		Platform.println(hailsDir);
		
		
		if (args[0] == "migrate") {
			if (javaDbOnly(DatabaseConfig.getType())) {
				#if java
				DbMigrator.main();
				#else
				var mysqlJar = hailsDir + "jar/mysql-connector-java-5.1.31-bin.jar";
				var sqlserverJar = hailsDir + "jar/sqljdbc4.jar";
				var sqlJar = mysqlJar + ";" + sqlserverJar;

				var args = ["-cp", hailsDir + "jrunner/DbMigrator.jar;config" + ";" + sqlJar, "hails.script.DbMigrator"];
				//trace(args);
				runCommand(null, "java", args);
				#end
			} else {
				DbMigrator.main();
			}
		} else if (args[0] == "build") {
			HailsBuilder.build(hailsDir, workDir, args);
		} else if (args[0] == "run") {
			// alias for "build neko run"
			HailsBuilder.build(hailsDir, workDir, ["build", "neko", "run"]);
		} else if (args[0] == "create") {
			HailsCreator.create(hailsDir, workDir, args);
		}
	}
	
	static function javaDbOnly(dbtype:String) {
		return dbtype == "sqlserver";
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
		trace("done");
		return result;
	}
	
    public static function recursiveCopy (source:String, destination:String, ignore:Array <String> = null, addExtention:String = null, flatFrom:String=null) {
		
		if (ignore == null) {
			
			ignore = [];
			
		}
		
		mkdir (destination);
		
		var files = FileSystem.readDirectory (source);
		
		for (file in files) {
			
			var ignoreFile = false;
			
			for (ignoreName in ignore) {
				
				if (StringTools.endsWith (ignoreName, "/")) {
					
					if (FileSystem.isDirectory (source + "/" + file) && file == ignoreName.substr (0, file.length - 1)) {
						
						ignoreFile = true;
						
					}
					
				} else if (file == ignoreName || StringTools.endsWith (source + "/" + file, "/" + ignoreName)) {
					
					ignoreFile = true;
					
				}
				
			}
			
			if (!ignoreFile) {
				
				var itemDestination:String = destination + "/" + file;

				
				var itemSource:String = source + "/" + file;
				
				if (FileSystem.isDirectory (itemSource)) {
					recursiveCopy (itemSource, itemDestination, ignore, addExtention, flatFrom);
					
				} else {
					
					if (addExtention != null) {
						itemDestination = itemDestination + addExtention;
					}
				if (flatFrom != null) {
					itemDestination = itemDestination.substring(0, flatFrom.length) + 
						StringTools.replace(itemDestination.substring(flatFrom.length), "/", "_");
					//trace(destination);
					//itemDestination = destination + "/" + StringTools.replace(file, "/", "_");
				}					
					Sys.println ("Copying " + itemSource + " to " + itemDestination);
					File.copy (itemSource, itemDestination);
					
				}
				
			}
			
		}
		
	}
	
	public static function mkdir (directory:String):Void {
		
		directory = StringTools.replace (directory, "\\", "/");
		var total = "";
		
		if (directory.substr (0, 1) == "/") {
			
			total = "/";
			
		}
		
		var parts = directory.split("/");
		var oldPath = "";
		
		if (parts.length > 0 && parts[0].indexOf (":") > -1) {
			
			oldPath = Sys.getCwd ();
			Sys.setCwd (parts[0] + "\\");
			parts.shift ();
			
		}
		
		for (part in parts) {
			
			if (part != "." && part != "") {
				
				if (total != "") {
					
					total += "/";
					
				}
				
				total += part;
				
				if (!FileSystem.exists (total)) {
					
					//print("mkdir " + total);
					
					FileSystem.createDirectory (total);
					
				}
				
			}
			
		}
		
		if (oldPath != "") {
			
			Sys.setCwd (oldPath);
			
		}
	}	
	
	public static function removeDirectory (directory:String):Void {
		
		if (FileSystem.exists (directory) && FileSystem.isDirectory (directory)) {
			
			for (file in FileSystem.readDirectory (directory)) {
				
				var path = directory + "/" + file;
				
				if (FileSystem.isDirectory (path)) {
					
					removeDirectory (path);
					
				} else {
					
					FileSystem.deleteFile (path);
					
				}
				
			}
			
			FileSystem.deleteDirectory (directory);
			
		}
		
	}	
		
}
