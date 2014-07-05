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
		//Lib.println(s);
		trace(s);
	}
	
}