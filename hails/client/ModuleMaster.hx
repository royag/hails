package hails.client;


class ModuleMaster
{

	public var pendingInjections = new Array<HtmlModule>();
	public var cacheInLocalStorageAsDefault = false;
	
	public var baseHtmlFolder = "";
	
	public var loadedModules = new Array<HtmlModule>();
	
	public function new() 
	{
		
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