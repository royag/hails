package hails.client;


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
	
}