package ;

import hails.config.ConfigReader;
import haxe.ds.StringMap;
import haxe.io.Path;
import sys.io.File;
import sys.io.Process;
import sys.FileSystem;
import hails.platform.Platform;

class JavaBuilder extends HailsBuilder
{

	
	function addResourceDirsJava(workPath:String, javaHome:String, mainJar:String) {
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

	
	public function build(hailsPath:String, workPath:String, args:Array<String>, unitTest:Bool=false) {
		
		var dest = "javaout";
		RunScript.removeDirectory(dest + "/src");
		var main = "controller.WebApp";
		var mainJar = dest + "/WebApp.jar";
		if (unitTest) {
			main = "test.unit.TestSuite";
			mainJar = dest + "/TestSuite-Debug.jar";
		}
		
		var dbconfig = getDbConfig();
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
		
		var directory = WEB_FOLDER;
		if (FileSystem.exists (directory) && FileSystem.isDirectory (directory)) {
			
		} else {
			RunScript.recursiveCopy(hailsPath + "templates/war", directory);
		}
		
		RunScript.removeDirectory("javaout/war");

		Sys.println("Copying from " + WEB_FOLDER + "...");
		RunScript.recursiveCopy(WEB_FOLDER, "javaout/war", null, null, null, !RunScript.verbose);

		RunScript.recursiveCopy(hailsPath + "templates/javanbproject", "javaout/nbproject");
		
		
		Platform.println("Adding views to WebApp.jar...");
		RunScript.runCommand(workPath, javaHome + "/bin/jar.exe", ["uvf", mainJar, "view"]);
		
		//addResourceDirsJava(workPath, javaHome, mainJar);
		
		File.copy (mainJar, "javaout/war/WEB-INF/lib/WebApp.jar");
		if (sqlJar != null) {
			File.copy (sqlJar, "javaout/war/WEB-INF/lib/" + driver);
		}
		
		buildJs(hailsPath, workPath, "javaout/war", "javaweb");
		
		var appName = appNameFromWorkPath(workPath);
		var warFile = "javaout/"+appName+".war";
		Platform.println("Assembling WAR-file: " + warFile);
		RunScript.runCommand(workPath, javaHome + "/bin/jar.exe", ["cvf", warFile, "-C", "javaout/war/", "."]);
		
		var jettyJar = hailsPath + "/jar/jetty-runner.jar";
		var javaArgs = ["-jar", jettyJar, warFile];
		if (args.length > 2 && args[2] == "run") {
			RunScript.runCommand(workPath, javaHome + "/bin/java.exe", javaArgs);
		} else if (args.length > 2 && args[2] == "livetest") {
			HailsLiveTester.runThenTest(workPath, javaHome + "/bin/java.exe", javaArgs, "http://localhost:8080/app/"); // +appName+"/");
		}
	}	
	
}