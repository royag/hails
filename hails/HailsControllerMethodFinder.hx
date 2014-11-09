package hails;
import hails.hailsservlet.IWebContext;
import hails.platform.Platform;
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
	
	private static inline var ALLOW_MISSING_CONTROLLER_PATH = true;
	
	public function new() 
	{
		
	}
	
	public static function findControllerMethodParams(controllers: Array<Class<HailsController>>, ctx : IWebContext) : ControllerMethodParams {
		var path = ctx.getRelativeURI();
		//Platform.println(path);
		//Platform.println(Std.string(controllers));
		var ret = new ControllerMethodParams();
		for (c in controllers) {
			var meta = Meta.getType(c);
			if (meta.path != null) {
				if (meta.path.length == 1) {
					var vars:StringMap<String> = matchPathAndReturnVariables(meta.path[0], path);
					if (vars != null) {
						var mustBeAction:String = null;
						if (vars.exists("$action")) {
							mustBeAction = vars.get("$action");
							vars.remove("$action");
						}
						var funcName = findProperFunction(c, mustBeAction, ctx);
						if (funcName != null) {
							ret.controller = c;
							ret.controllerFunction = funcName;
							ret.variables = vars;
							return ret;
						}
					}
				}
			} else {
				if (ALLOW_MISSING_CONTROLLER_PATH) {
					var comp = getPathComponents(path);
					if (comp.length == 1 || comp.length == 2) {
						var className = Type.getClassName(c).split(".").pop();
						if (className == StringUtil.camelize(comp[0]) + "Controller") {
							var mustBeAction:String = (comp.length == 2 ? comp[1] : null);
							var funcName = findProperFunction(c, mustBeAction, ctx);
							if (funcName != null) {
								ret.controller = c;
								ret.controllerFunction = funcName;
								ret.variables = new StringMap<String>();
								return ret;
							}
						}
					}
				}
			}
		}
		return null;
	}
	
	static function functionMetaMatchesHttpMethod(funcMeta : Dynamic, method:String) : Bool {
		var isExplicitAction = Reflect.hasField(funcMeta, "action");
		method = method.toUpperCase();
		var allowGET = Reflect.hasField(funcMeta, "GET");
		var allowPOST = Reflect.hasField(funcMeta, "POST");
		var allowDELETE = Reflect.hasField(funcMeta, "DELETE");
		var allowPUT = Reflect.hasField(funcMeta, "PUT");
		var allowAny = isExplicitAction && (!allowGET) && (!allowPOST) && (!allowDELETE) && (!allowPUT);
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
					} else if (actionVal[0] == mustBeAction) {
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
		var decl = getPathComponents(declared, false);
		var act = getPathComponents(actual);
		while (decl.length > act.length) {
			act.push(null);
		}
		if (decl.length != act.length) {
			return null;
		}		
		for (i in 0...decl.length) {
			var d = decl[i];
			var a = act[i];
			if (!(d == a)) {
				if (StringTools.startsWith(d, "{") && StringTools.endsWith(d, "}")) {
					var varName = d.substr(1, d.length - 2);
					var optional = false;
					if (StringTools.endsWith(varName, "?")) {
						optional = true;
						varName = varName.substring(0, varName.length - 1);
					}
					if ((!optional) && (a == null)) {
						return null;
					}
					variables.set(varName, a);
				} else {
					return null;
				}
			}
		}
		return variables;
	}
	
	public static function getPathComponents(path:String, removeParams=true) : Array<String> {
		if (path == null) {
			return null;
		}
		if (removeParams) {
			path = path.split("?")[0];
		}
		var comps = path.split("/");
		while (comps.remove("")) {};
		return comps;
	}
}