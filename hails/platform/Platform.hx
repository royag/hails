package hails.platform;

/**
 * ...
 * @author Roy
 */

 #if neko
 import neko.Lib;
 #end
 
class Platform
{

	public function new() 
	{
		
	}
	
	public static function println(s:String) {
		#if neko
		Lib.println(s);
		#elseif java
		java.lang.System.out.println(s);
		#else
		trace(s);
		#end
	}
	
}