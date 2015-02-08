package hails.client;

import haxe.ds.StringMap;

class ModuleMaster
{

	public var pendingInjections = new Array<HtmlModule>();
	public var cacheInLocalStorageAsDefault = false;
	
	public var baseHtmlFolder = "";
	
	public var loadedModules = new Array<HtmlModule>();
	
	var goToPageHandler:String->String->Void = null;
	
	public function new() 
	{
		
	}
	
	public function setGoToPageHandler(handler:String->String->Void) {
		goToPageHandler = handler;
	}
	
	public function goToPage(pageId:String, pageContent:String = null) {
		if (goToPageHandler != null) {
			goToPageHandler(pageId, pageContent);
		} else {
			trace("Missing goToPageHandler");
		}
	}
	
	public function setBaseHtmlFolder(folder:String) {
		var f = folder;
		if (StringTools.startsWith(f, "/")) {
			f = f.substr(1);
		}
		if (!StringTools.endsWith(f, "/")) {
			f = f + "/";
		}
		baseHtmlFolder = f;
	}	
	
	// Room for some optimization here ?
	public function module < T : HtmlModule > (moduleClass:Class<T>) : T {
		var wantedName = Type.getClassName(moduleClass);
		for (mod in loadedModules) {
			var modClass = Type.getClass(mod);
			var modClassName = Type.getClassName(modClass);
			if (modClassName == wantedName) {
				return cast mod;
			}
			//if (Type.getClass(mod) == moduleClass) {
				//return mod;
			//}
		}
		return null;
	}
	
	public function handleHashChanged(hash:String) {
		var commandParams = hash.split("?");
		var command = commandParams[0];
		while (StringTools.startsWith(command, "#")) {
			command = command.substr(1);
		}
		while (StringTools.startsWith(command, "!")) {
			command = command.substr(1);
		}
		var paramMap = new StringMap<String>();
		if (commandParams.length > 1) {
			var params = commandParams[1];
			var paramPairs = params.split("&");
			for (pair in paramPairs) {
				var keyVal = pair.split("=");
				paramMap.set(keyVal[0], keyVal[1]);
			}
		}
		trace("command=" + command);
		trace("params=" + Std.string(paramMap));
		trace("loadedModules.length=" + loadedModules.length);
		for (mod in loadedModules) {
			mod.handleNavigation(command, paramMap);
		}
	}	
	
}