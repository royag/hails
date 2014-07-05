/**
* ...
* @author Default
*/

package hails.config;
import haxe.ds.StringMap.StringMap;

class DatabaseConfig {

	/*public static var user = 'test';
	public static var socket = '';
	public static var password = 'test';
	public static var host = 'localhost';
	public static var port = 3306;
	public static var database = 'test';*/
	//static var config:StringMap<String> = null;
	
	public static function getUser() {
		return ConfigReader.getConfig("dbconfig").get("username");
	}
	public static function getType() {
		return ConfigReader.getConfig("dbconfig").get("type");
	}
	public static function getPassword() {
		return ConfigReader.getConfig("dbconfig").get("password");
	}
	public static function getDatabase() {
		return ConfigReader.getConfig("dbconfig").get("dbname");
	}
	public static function getPort() {
		return Std.parseInt(ConfigReader.getConfig("dbconfig").get("port"));
	}
	public static function getHost() {
		return ConfigReader.getConfig("dbconfig").get("host");
	}
	
}
