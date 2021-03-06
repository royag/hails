﻿/**
* ...
* @author Default
*/

package hails.config;
import hails.HailsController;
import hails.Logger;

enum ApplicationControllers {
	user;
}

class HailsConfig {
	public static var URL_SEP = "/";
	
	public static function loadViewAsResource() {
		#if (neko||cpp)
		return false;
		#else
		return true;
		#end
	}
	
	public static function getViewRoot() {
		if (loadViewAsResource()) {
			return "";
		} else {
			#if cpp
			return "/personal/hails2/hailsdemo/view";
			#else
			return "view";
			#end
		}
	}
	
	public static function getLogFileName() : String {
		return "C:/projects/hails_google/hails.log";
	}
	
	// set to 0 to disable logging
	public static function getLogLevel() : Int {
		return Logger.LEVEL_DEBUG;
	}
	
	public static var defaultController = 'main';
	
	public static function getBaseUrl() : String {
		#if php
		return "/index.php/";
		#end
		#if java
		return "/hailsdemo/";
		#else
		return "/";
		#end
		//return "/hailsdemo/Test/";
		//return "/";
		
	}
	
	public static function getUriScriptnameNo() : Int {
		#if php
		return 1;
		#elseif java
		return 1;
		#elseif cpp
		return 2;
		#else
		return 0;
		#end
	}
	
	public static function getResourceBaseUrl() : String {
		return "/public/";
	}
}