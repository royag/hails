package ;

import hails.config.ConfigReader;
import hails.platform.Platform;
import haxe.ds.StringMap;
import haxe.io.Path;
import sys.io.File;
import sys.io.Process;
import sys.FileSystem;
import PhpBuilder;

class HailsBuilder
{

	public var WEB_FOLDER = "war";
	
	public static function build(hailsPath:String, workPath:String, args:Array<String>, unitTest:Bool = false) {
		if (unitTest && args.length == 1) {
			new JavaBuilder().build(hailsPath, workPath, args, unitTest);
			new NekoBuilder().build(hailsPath, workPath, args, unitTest);
			new PhpBuilder().build(hailsPath, workPath, args,unitTest);
		} else {
			var target = args[1];
			if (target == "java") {
				new JavaBuilder().build(hailsPath, workPath, args,unitTest);
			} else if (target == "php") {
				new PhpBuilder().build(hailsPath, workPath, args,unitTest);
			} else if (target == "neko") {
				new NekoBuilder().build(hailsPath, workPath, args,unitTest);
			//} else if (target == "cpp") {
			//	buildCpp(hailsPath, workPath, args);
			} else {
				Platform.println("Unrecognized target: " + target);
			}
		}
	}
	
	function getArgs_Only(args:Array<String>) : Array<String> {
		for (arg in args) {
			if (StringTools.startsWith(arg, "-only:")) {
				var onlyList = arg.substr("-only:".length);
				return onlyList.split(":");
			}
		}
		return null;
	}
	
	public function createWebAppHx(hailsPath:String, workPath:String) {
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
	
	function buildJs(hailsPath:String, workPath:String, dest:String, jsDefine:String) {
		new JavascriptBuilder().build(hailsPath, workPath, dest, jsDefine);	
	}

	
	private static var _haxeConfig : StringMap<String> = null;
	public function getHaxeConfig() {
		if (_haxeConfig == null) {
			_haxeConfig = ConfigReader.getConfigFromFile("config/haxeconfig");
		}
		return _haxeConfig;
	}
	public function getDbConfig() {
		return ConfigReader.getConfigFromFile("config/dbconfig");
	}
	public function getNeededLibs() : Array<String> {
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
	public function getHaxeLibArgs() {
		var ret = new Array<String>();
		for (lib in getNeededLibs()) {
			ret.push("-lib");
			ret.push(lib);
		}
		return ret;
	}
	public function getResourceDirs() : Array<String> {
		var conf = getHaxeConfig();
		if (conf == null) {
			return new Array<String>();
		}
		var libList = conf.get("resourcedirs");
		//trace(libList);
		if ((libList == null) || (libList.length == 0)) {
			return new Array<String>();
		}
		return libList.split(";");
	}
	
	
	
	public function appNameFromWorkPath(workPath:String) {
		var slashI = workPath.lastIndexOf("/");
		var backslashI = workPath.lastIndexOf("\\");
		var lastSlash = (slashI > backslashI ? slashI : backslashI);
		var appName = workPath.substring(lastSlash + 1);
		return appName;
	}
	
}