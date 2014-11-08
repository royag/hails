package ;

import hails.config.ConfigReader;
import hails.platform.Platform;
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

	public static function build(hailsPath:String, workPath:String, args:Array<String>) {
		var target = args[1];
		if (target == "java") {
			buildJava(hailsPath, workPath, args);
		} else if (target == "php") {
			buildPhp(hailsPath, workPath, args);
		} else if (target == "neko") {
			buildNeko(hailsPath, workPath, args);
		//} else if (target == "cpp") {
		//	buildCpp(hailsPath, workPath, args);
		} else {
			Platform.println("Unrecognized target: " + target);
		}
	}
	
	public static function createWebAppHx(hailsPath:String, workPath:String) {
		
		var webAppHx = "package controller;\n" +
			"import hails.Main;\n";

		var directory = "controller";
		if (FileSystem.exists (directory) && FileSystem.isDirectory (directory)) {
			for (file in FileSystem.readDirectory (directory)) {
				var i = file.indexOf(".hx");
				if (i > 0) {
					var className = file.substring(0, i);
					webAppHx += "import controller." + className + ";\n";
				}
			}
		}
		
		webAppHx +=
			"class WebApp extends Main\n" +
			"{\n"+
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
	
	
	public static function buildNeko(hailsPath:String, workPath:String, args:Array<String>) {
		createWebAppHx(hailsPath, workPath);
		RunScript.mkdir("nekoout");
		var haxeArgs = ["-neko", "./nekoout/index.n", "-main", "controller.WebApp", "-cp", ".", "-lib", "hails"];
		
		haxeArgs.push("-resource");
		haxeArgs.push("config/dbconfig@dbconfig"); // !NB!: .pl(perl)-extension so it (usually) won't be able to load directly from webroot
		
		RunScript.runCommand(workPath, "haxe", haxeArgs);
		
		var nekoArgs = ["server", "-p", "2000", "-h", "localhost", "-d", "nekoout", "-rewrite"];
		if (args.length > 2 && args[2] == "run") {
			RunScript.runCommand(workPath, "nekotools", nekoArgs);
		} else if (args.length > 2 && args[2] == "livetest") {
			HailsLiveTester.runThenTest(workPath, "nekotools", nekoArgs, "http://localhost:2000/");
		}
	}
	
	public static function buildPhp(hailsPath:String, workPath:String, args:Array<String>) {
		createWebAppHx(hailsPath, workPath);
		var haxeArgs = ["-php", "phpout", "-main", "controller.WebApp", "-cp", ".", "-lib", "hails"];
		
		haxeArgs.push("-resource");
		haxeArgs.push("config/dbconfig@dbconfig.pl"); // !NB!: .pl(perl)-extension so it (usually) won't be able to load directly from webroot
		
		RunScript.removeDirectory("phpout/res");
		RunScript.runCommand(workPath, "haxe", haxeArgs);
		
		RunScript.recursiveCopy("view", "phpout/res/view", null, ".pl", "phpout/res/"); // !NB!: .pl(perl)-extension so it (usually) won't be able to load directly from webroot
		if (args.length > 2 && args[2] == "livetest") {
			HailsLiveTester.justTest(workPath, "http://localhost/index.php/");
		}		
	}
	
	
	public static function buildJava(hailsPath:String, workPath:String, args:Array<String>) {
		
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
		
		var haxeArgs = ["-java", "javaout", "-main", "controller.WebApp", "-cp", ".", "-lib", "hails"];
		//var bscript = "-java javaout -main hails.Main -cp . ";
		//bscript += " -java-lib " + hailsPath + "jar/servlet-api.jar ";
		haxeArgs.push("-java-lib");
		haxeArgs.push(hailsPath + "jar/servlet-api.jar");
		
		haxeArgs.push("-resource");
		haxeArgs.push("config/dbconfig@dbconfig");
		
		RunScript.runCommand(workPath, "haxe", haxeArgs);
		
		var directory = "war";
		if (FileSystem.exists (directory) && FileSystem.isDirectory (directory)) {
			
		} else {
			RunScript.recursiveCopy(hailsPath + "templates/war", directory);
		}
		
		RunScript.removeDirectory("javaout/war");
		RunScript.recursiveCopy("war", "javaout/war");
		
		Platform.println("Adding views to WebApp.jar...");
		RunScript.runCommand(workPath, javaHome + "/bin/jar.exe", ["uvf", "javaout/WebApp.jar", "view"]);
		
		File.copy ("javaout/WebApp.jar", "javaout/war/WEB-INF/lib/WebApp.jar");
		if (dbtype != null) {
			var driver = "mysql-connector-java-5.1.31-bin.jar";
			if (dbtype == "sqlserver") {
				driver = "sqljdbc4.jar";
			} else if (dbtype == "sqlite") {
				driver = "sqlite-jdbc-3.7.2.jar";
			}
			Platform.println("Adding SQL driver to WEB-INF/lib: " + driver);
			File.copy (hailsPath + "jar/" + driver, "javaout/war/WEB-INF/lib/" + driver);
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
			HailsLiveTester.runThenTest(workPath, javaHome + "/bin/java.exe", javaArgs, "http://localhost:8080/"+appName+"/");
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