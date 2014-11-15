package hails.js;

/**
 * ...
 * @author Roy
 */
class JSContext
{

	public function new() 
	{
		
	}
	
	public static function getRootUrl() {
		#if phpweb
		return "/index.php/";
		#end
		#if javaweb
		return "/app/";
		#end
		#if nekoweb
		return "/";
		#end
		return "/";
	}
	
}