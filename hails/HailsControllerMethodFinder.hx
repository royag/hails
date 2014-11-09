package hails;
import hails.hailsservlet.IWebContext;
import hails.util.StringUtil;
import haxe.ds.StringMap;
import haxe.rtti.Meta;

class ControllerMethodParams {
	public function new() {}
	public var controller : Class<HailsController>;
	public var controllerFunction : String;
	public var variables : StringMap<String>;
}

class HailsControllerMethodFinder
{

	public function new() 
	{
		
	}
	
	public static function findControllerMethodParams(controllers: Array<Class<HailsController>>, ctx : IWebContext) : ControllerMethodParams {
		var path = ctx.getRelativeURI();
		var ret = new ControllerMethodParams();
		for (c in controllers) {
			var meta = Meta.getType(c);
			if (meta.path != null) {
				if (meta.path.length == 1) {
					var vars:StringMap<String> = matchPathAndReturnVariables(meta.path[0], path);
					if (vars != null) {
						var funcName = findProperFunction(c, null, ctx);
						if (funcName != null) {
							ret.controller = c;
							ret.controllerFunction = funcName;
							ret.variables = vars;
							return ret;
						}
					}
				}
			}
		}
		if (ALLOW_MISSING_CONTROLLER_PATH) {
			for (c in controllers) {
				var comp = getPathComponents(path);
				if (comp.length == 1 || comp.length == 2) {
					var className = Type.getClassName(c).split(".").pop();
					if (className == StringUtil.camelize(comp[0]) + "Controller") {
						var mustBeAction:String = (comp.length == 2 ? comp[1] : null);
						var funcName = findProperFunction(c, mustBeAction, ctx);
						if (funcName != null) {
							ret.controller = c;
							ret.controllerFunction = funcName;
							ret.variables = null;
							return ret;
						}
					}
				}
			}
		}
		return null;
	}
	
	static function functionMetaMatchesHttpMethod(funcMeta : Dynamic, method:String) : Bool {
		method = method.toUpperCase();
		var allowGET = Reflect.hasField(funcMeta, "GET");
		var allowPOST = Reflect.hasField(funcMeta, "POST");
		var allowDELETE = Reflect.hasField(funcMeta, "DELETE");
		var allowPUT = Reflect.hasField(funcMeta, "PUT");
		var allowAny = (!allowGET) && (!allowPOST) && (!allowDELETE) && (!allowPUT);
		if (allowAny) {
			return true;
		}
		return (allowGET && (method == "GET")) ||
			(allowPOST && (method == "POST")) ||
			(allowDELETE && (method == "DELETE")) ||
			(allowPUT && (method == "PUT"));
	}
	
	static function functionMetaMatches(funcMeta : Dynamic, ctx : IWebContext) : Bool{
		return functionMetaMatchesHttpMethod(funcMeta, ctx.getMethod());
	}
	
	static function findProperFunction(c: Class<HailsController>, mustBeAction:String, ctx : IWebContext) : String {
		var meta = Meta.getFields(c);
		for (funcName in Reflect.fields(meta)) {
			var funcMeta = Reflect.field(meta,funcName);
			var isCandidate = false;
			if (mustBeAction != null) {
				if (Reflect.hasField(funcMeta, "action")) {
					var actionVal = Reflect.field(funcMeta, "action");
					if (actionVal == null) {
						if (StringUtil.camelizeWithFirstAsLower(mustBeAction) == funcName) {
							isCandidate = true;
						}
					} else if (actionVal == mustBeAction) {
						isCandidate = true;
					}
				}
			} else {
				if (!Reflect.hasField(funcMeta, "action")) {
					isCandidate = true;
				}
			}
			if (isCandidate && functionMetaMatches(funcMeta, ctx)) {
				return funcName;
			}
		}
		return null;
	}
	
	
	static function matchPathAndReturnVariables(declared:String, actual:String) : StringMap<String> {
		var variables = new StringMap<String>();
		var decl = getPathComponents(declared);
		var act = getPathComponents(actual);
		if (decl.length != act.length) {
			return null;
		}
		for (i in 0...decl.length) {
			var d = decl[i];
			var a = act[i];
			if (!(d == a)) {
				if (StringTools.startsWith(d, "{") && StringTools.endsWith(d, "}")) {
					variables.set(d.substr(1, d.length - 2), a);
				} else {
					return null;
				}
			}
		}
		return variables;
	}
	
	private static inline var ALLOW_MISSING_CONTROLLER_PATH = true;
	/*public static function findControllerFromPath(controllers: Array<Class<HailsController>>, path:String) : Class<HailsController> {
		for (c in controllers) {
			var meta = Meta.getType(c);
			if (meta.path != null) {
				if (meta.path.length == 1) {
					if (matchPath(meta.path[0], path)) {
						return c;
					}
				}
			}
		}
		if (ALLOW_MISSING_CONTROLLER_PATH) {
			for (c in controllers) {
				var comp = getPathComponents(path);
				if (comp.length >= 1) {
					var className = Type.getClassName(c).split(".").pop();
					if (className == StringUtil.camelize(comp[0]) + "Controller") {
						//Type.get
						return c;
					}
				}
			}
		}
		return null;
	}*/
	
	
	static function getPathComponents(path:String) : Array<String> {
		return HailsDispatcher.getPathComponents(path);
	}	
	
}