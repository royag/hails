/**
* ...
* @author Default
*/

package config;
import hails.HailsController;
import hails.Logger;

enum ApplicationControllers {
	user;
}

class HailsConfig {
	public static var phpViewRoot = "/personal/google_code/hails/view";
	
	public static function getLogFileName() : String {
		return "C:/projects/hails_google/hails.log";
	}
	
	// set to 0 to disable logging
	public static function getLogLevel() : Int {
		return Logger.LEVEL_DEBUG;
	}
	
	public static var defaultController = 'main';
	
	public static function getBaseUrl() : String {
		return "/index.php/";
	}
	
	public static function getUriScriptnameNo() : Int {
		return 1;
	}
	
	public static function getResourceBaseUrl() : String {
		return "/public/";
	}
}