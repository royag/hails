package ;

import hails.config.ConfigReader;
import hails.platform.Platform;
import haxe.ds.StringMap;
import haxe.io.Path;
import sys.io.File;
import sys.io.Process;
import sys.FileSystem;

/**
 * ...
 * @author Roy
 */
class HailsBuilder
{

	public static function build(hailsPath:String, workPath:String, args:Array<String>, unitTest:Bool = false) {
		if (unitTest && args.length == 1) {
			buildJava(hailsPath, workPath, args, unitTest);
			buildNeko(hailsPath, workPath, args, unitTest);
			buildPhp(hailsPath, workPath, args,unitTest);
		} else {
			var target = args[1];
			if (target == "java") {
				buildJava(hailsPath, workPath, args,unitTest);
			} else if (target == "php") {
				buildPhp(hailsPath, workPath, args,unitTest);
			} else if (target == "neko") {
				buildNeko(hailsPath, workPath, args,unitTest);
			//} else if (target == "cpp") {
			//	buildCpp(hailsPath, workPath, args);
			} else {
				Platform.println("Unrecognized target: " + target);
			}
		}
	}
	
	public static function createWebAppHx(hailsPath:String, workPath:String) {
		
		var webAppHx = "package controller;\n" +
			"import hails.Main;\n" +
			"import hails.HailsDispatcher;\n";

		var directory = "controller";
		var controllers:Array<String> = new Array<String>();
		if (FileSystem.exists (directory) && FileSystem.isDirectory (directory)) {
			for (file in FileSystem.readDirectory (directory)) {
				var i = file.indexOf(".hx");
				if (i > 0) {
					var className = file.substring(0, i);
					webAppHx += "import controller." + className + ";\n";
					controllers.push(className);
				}
			}
		}
		
		var controllerLoading = "\tstatic var tmp = HailsDispatcher.initControllers([";
		var first = true;
		for (className in controllers) {
			if (className != "WebApp") {
				controllerLoading += (first ? "" : ",") + className;
				first = false;
			}
		}
		controllerLoading += "]);";
		
		webAppHx +=
			"class WebApp extends Main\n" +
			"{\n\n" +
			controllerLoading + "\n\n" +
			"	static function main(){\n"+
			"		hails.Main.main();\n"+
			"	}	\n"+
			"}";
		
		File.saveContent("controller/WebApp.hx", webAppHx);
	}

	/*public static function buildCpp(hailsPath:String, workPath:String, args:Array<String>) {
		createWebAppHx(hailsPath, workPath);
		RunScript.mkdir("cppout");
		var haxeArgs = ["-cpp", "./cppout", "-main", "controller.WebApp", "-cp", ".", "-lib", "hails"];
		haxeArgs.push("-resource");
		haxeArgs.push("config/dbconfig@dbconfig"); // !NB!: .pl(perl)-extension so it (usually) won't be able to load directly from webroot
		RunScript.runCommand(workPath, "haxe", haxeArgs);
	}*/
	
	
	public static function buildNeko(hailsPath:String, workPath:String, args:Array<String>, unitTest:Bool=false) {
		createWebAppHx(hailsPath, workPath);
		RunScript.mkdir("nekoout");
		var dest = "./nekoout/index.n";
		var main = "controller.WebApp";
		if (unitTest) {
			dest = "./nekoout/unittest.n";
			main = "test.unit.TestSuite";
		}
		var haxeArgs = ["-neko", dest, "-main", main, "-cp", ".", "-lib", "hails"].concat(getHaxeLibArgs());
		
		haxeArgs.push("-resource");
		haxeArgs.push("config/dbconfig@dbconfig");
		
		RunScript.runCommand(workPath, "haxe", haxeArgs);
		
		if (unitTest) {
			Platform.println("[[[[ Unit Testing NEKO target ]]]]");
			RunScript.runCommand(workPath, "neko", [dest]);
		} else {
			var nekoArgs = ["server", "-p", "2000", "-h", "localhost", "-d", "nekoout", "-rewrite"];
			if (args.length > 2 && args[2] == "run") {
				RunScript.runCommand(workPath, "nekotools", nekoArgs);
			} else if (args.length > 2 && args[2] == "livetest") {
				HailsLiveTester.runThenTest(workPath, "nekotools", nekoArgs, "http://localhost:2000/");
			}
		}
	}
	
	public static function buildPhp(hailsPath:String, workPath:String, args:Array<String>, unitTest:Bool=false) {
		createWebAppHx(hailsPath, workPath);
		var dest = "phpout";
		var main = "controller.WebApp";
		if (unitTest) {
			dest = "phptest";
			main = "test.unit.TestSuite";
		}		
		var haxeArgs = ["-php", dest, "-main", main, "-cp", ".", "-lib", "hails"].concat(getHaxeLibArgs());
		
		haxeArgs.push("-resource");
		haxeArgs.push("config/dbconfig@dbconfig.pl"); // !NB!: .pl(perl)-extension so it (usually) won't be able to load directly from webroot
		
		RunScript.removeDirectory(dest + "/res");
		RunScript.runCommand(workPath, "haxe", haxeArgs);
		
		RunScript.recursiveCopy("view", dest + "/res/view", null, ".pl", dest + "/res/"); // !NB!: .pl(perl)-extension so it (usually) won't be able to load directly from webroot
		addResourceDirsPhp(dest);
		
		if (unitTest) {
			Platform.println("[[[[ Unit Testing PHP target ]]]]");
			RunScript.runCommand(workPath, "php", [dest + "/index.php"]);
		} else {
			if (args.length > 2 && args[2] == "livetest") {
				HailsLiveTester.justTest(workPath, "http://localhost/index.php/");
			}		
		}
	}
	
	private static var _haxeConfig : StringMap<String> = null;
	public static function getHaxeConfig() {
		if (_haxeConfig == null) {
			_haxeConfig = ConfigReader.getConfigFromFile("config/haxeconfig");
		}
		return _haxeConfig;
	}
	public static function getNeededLibs() : Array<String> {
		var conf = getHaxeConfig();
		if (conf == null) {
			return new Array<String>();
		}
		var libList = conf.get("libs");
		if ((libList == null) || (libList.length == 0)) {
			return new Array<String>();
		}
		return libList.split(",");
	}
	public static function getHaxeLibArgs() {
		var ret = new Array<String>();
		for (lib in getNeededLibs()) {
			ret.push("-lib");
			ret.push(lib);
		}
		return ret;
	}
	public static function getResourceDirs() : Array<String> {
		var conf = getHaxeConfig();
		if (conf == null) {
			return new Array<String>();
		}
		var libList = conf.get("resourcedirs");
		trace(libList);
		if ((libList == null) || (libList.length == 0)) {
			return new Array<String>();
		}
		return libList.split(";");
	}
	
	static function addResourceDirsJava(workPath:String, javaHome:String, mainJar:String) {
		for (resdir in getResourceDirs()) {
			var lastSlash = resdir.lastIndexOf("/");
			if (lastSlash < 0) {
				lastSlash = resdir.lastIndexOf("\\");
			}
			var jarArgs = ["uvf", mainJar, resdir];
			if (lastSlash > 0) {
				jarArgs = ["uvf", mainJar, "-C", resdir.substr(0, lastSlash), resdir.substr(lastSlash + 1)];
			}
			//trace(jarArgs);
			RunScript.runCommand(workPath, javaHome + "/bin/jar.exe", jarArgs);
		}
	}
	static function addResourceDirsPhp(dest:String) {
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
			RunScript.recursiveCopy(resdir, dest + "/res/" + destDir, null, ".pl", dest + "/res/"); // !NB!: .pl(perl)-extension so it (usually) won't be able to load directly from webroot
		}		
	}
	
	public static function buildJava(hailsPath:String, workPath:String, args:Array<String>, unitTest:Bool=false) {
		
		var dest = "javaout";
		var main = "controller.WebApp";
		var mainJar = dest + "/WebApp.jar";
		if (unitTest) {
			main = "test.unit.TestSuite";
			mainJar = dest + "/TestSuite-Debug.jar";
		}
		
		var dbconfig = ConfigReader.getConfigFromFile("config/dbconfig");
		var dbtype = null;
		if (dbconfig != null) {
			dbtype = dbconfig.get("type");
		}
		
		var javaHome = Sys.getEnv("JAVA_HOME");
		if (javaHome == null) {
			Platform.println("You must set the JAVA_HOME environment variable");
		}
		
		createWebAppHx(hailsPath, workPath);
		
		var haxeArgs = ["-java", dest, "-main", main, "-cp", ".", "-lib", "hails"].concat(getHaxeLibArgs());
		//var bscript = "-java javaout -main hails.Main -cp . ";
		//bscript += " -java-lib " + hailsPath + "jar/servlet-api.jar ";
		haxeArgs.push("-java-lib");
		haxeArgs.push(hailsPath + "jar/servlet-api.jar");
		
		haxeArgs.push("-resource");
		haxeArgs.push("config/dbconfig@dbconfig");
		
		if (unitTest) {
			haxeArgs.push("-debug");
		}
		
		RunScript.runCommand(workPath, "haxe", haxeArgs);
		addResourceDirsJava(workPath, javaHome, mainJar);
		
		var sqlJar = null;
		var driver = null;
		if (dbtype != null) {
			driver = "mysql-connector-java-5.1.31-bin.jar";
			if (dbtype == "sqlserver") {
				driver = "sqljdbc4.jar";
			} else if (dbtype == "sqlite") {
				driver = "sqlite-jdbc-3.7.2.jar";
			}
			sqlJar = hailsPath + "jar/" + driver;
		}
		
		if (unitTest) {
			Platform.println("[[[[ Unit Testing JAVA target ]]]]");
			var cp = mainJar;
			if (sqlJar != null) {
				cp += ";" + sqlJar;
			}
			
			var testArgs = ["-cp", cp, "test.unit.TestSuite"];
			RunScript.runCommand(workPath, "java", testArgs);
			return;
		}
		
		var directory = "war";
		if (FileSystem.exists (directory) && FileSystem.isDirectory (directory)) {
			
		} else {
			RunScript.recursiveCopy(hailsPath + "templates/war", directory);
		}
		
		RunScript.removeDirectory("javaout/war");
		RunScript.recursiveCopy("war", "javaout/war");
		
		Platform.println("Adding views to WebApp.jar...");
		RunScript.runCommand(workPath, javaHome + "/bin/jar.exe", ["uvf", mainJar, "view"]);
		
		//addResourceDirsJava(workPath, javaHome, mainJar);
		
		File.copy (mainJar, "javaout/war/WEB-INF/lib/WebApp.jar");
		if (sqlJar != null) {
			File.copy (sqlJar, "javaout/war/WEB-INF/lib/" + driver);
		}
		var appName = appNameFromWorkPath(workPath);
		var warFile = "javaout/"+appName+".war";
		Platform.println("Assembling WAR-file: " + warFile);
		RunScript.runCommand(workPath, javaHome + "/bin/jar.exe", ["cvf", warFile, "-C", "javaout/war/", "."]);
		
		var jettyJar = hailsPath + "/jar/jetty-runner.jar";
		var javaArgs = ["-jar", jettyJar, warFile];
		if (args.length > 2 && args[2] == "run") {
			RunScript.runCommand(workPath, javaHome + "/bin/java.exe", javaArgs);
		} else if (args.length > 2 && args[2] == "livetest") {
			HailsLiveTester.runThenTest(workPath, javaHome + "/bin/java.exe", javaArgs, "http://localhost:8080/"); // +appName+"/");
		}
	}
	
	public static function appNameFromWorkPath(workPath:String) {
		var slashI = workPath.lastIndexOf("/");
		var backslashI = workPath.lastIndexOf("\\");
		var lastSlash = (slashI > backslashI ? slashI : backslashI);
		var appName = workPath.substring(lastSlash + 1);
		return appName;
	}
	
}