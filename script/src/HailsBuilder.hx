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
			
		}
	}
	
	public static function createWebAppHx(hailsPath:String, workPath:String) {
		// go through controller-dir to find all controllers
		// create "controller/WebApp.hx" :
		/*
		 * package controller;
import hails.Main;
import controller.MainController; .... etc....

class WebApp extends Main
{
	static function main(){
		hails.Main.main();
	}	
}
		 */
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
		
		// TODO : Add views to WebApp.jar
		RunScript.runCommand(workPath, javaHome + "/bin/jar.exe", ["uvf", "javaout/WebApp.jar", "view"]);
		
		File.copy ("javaout/WebApp.jar", "javaout/war/WEB-INF/lib/WebApp.jar");
		if (dbtype != null) {
			var driver = "mysql-connector-java-5.1.31-bin.jar";
			if (dbtype == "sqlserver") {
				driver = "sqljdbc4.jar";
			}
			File.copy (hailsPath + "jar/" + driver, "javaout/war/WEB-INF/lib/" + driver);
		}
		
		RunScript.runCommand(workPath, javaHome + "/bin/jar.exe", ["cvf", "javaout/webapp.war", "-C", "javaout/war/", "."]);
		
	}	
	
}