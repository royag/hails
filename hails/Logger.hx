/**
 * ...
 * @author ...
 */

package hails;
import hails.config.HailsConfig;
import haxe.io.Output;
import sys.io.File;

class Logger 
{
	static var logLevel = HailsConfig.getLogLevel();
	static var logFileName = HailsConfig.getLogFileName();
	
	public static var LEVEL_FATAL = 1;
	public static var LEVEL_ERROR = 3;
	public static var LEVEL_INFO = 5;
	public static var LEVEL_DEBUG = 7;
	
	static function logToFile(msg:String) {
		var fo:Output = null;
		try {
			fo = File.append(logFileName, false);
			fo.writeString('[' + Date.now().toString() + '] ' + msg + "\n");
			fo.close();
		} catch ( e : Dynamic ) {
			// oops.. some problems writing to log... ignore...
			if (fo != null) {
				try {
					fo.close();
				} catch ( e2 : Dynamic ) {
					// ignore
				}
			}
		}
	}
	
	public static function logAtLevel(level:Int, msg:String) {
		if (logLevel >= level) {
			logToFile(level + ": " + msg);
		}
	}
	
	// Levels 1
	public static function logFatal(msg:String) {
		logAtLevel(1, "FATAL: " + msg);
	}
	
	// Levels 3
	public static function logError(msg:String) {
		logAtLevel(3, "ERROR: " + msg);
	}
	
	// Level 5
	public static function logInfo(msg:String) {
		logAtLevel(5, "INFO: " + msg);
	}
	
	// Level 7
	public static function logDebug(msg:String) {
		logAtLevel(7, "DEBUG: " + msg);
	}
}