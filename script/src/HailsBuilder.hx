package ;

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
	
	public static function buildJava(hailsPath:String, workPath:String, args:Array<String>) {
		var haxeArgs = ["-java", "javaout", "-main", "controller.WebApp", "-cp", ".", "-lib", "hails"];
		//var bscript = "-java javaout -main hails.Main -cp . ";
		//bscript += " -java-lib " + hailsPath + "jar/servlet-api.jar ";
		haxeArgs.push("-java-lib");
		haxeArgs.push(hailsPath + "jar/servlet-api.jar");
		
		haxeArgs.push("-resource");
		haxeArgs.push("config/dbconfig@dbconfig");
		
		RunScript.runCommand(workPath, "haxe", haxeArgs);
		RunScript.runCommand(workPath, "mkdir", ["javaout\\www"], false);
	}	
	
}