/**
* ...
* @author Default
*/

package hails;

import config.HailsConfig;
import hails.util.StringUtil;
import php.Exception;
import php.Lib;
import php.Web;
import haxe.ds.StringMap;

// ControllerConfig should import all controllers, just to make them compile...
// (Because if there are no references (as they are loaded dynamically) they're not compiled.
import config.ControllerConfig;

//
class HailsDispatcher {

	/*public function new() {
		
	}*/
	
	static var controllerClassPrefix:String = "controller.";
	
	static function getUriPart(n:Int) : String {
		var uri:String = Web.getURI();
		if (uri.charAt(uri.length - 1) == "/") {
			uri = uri.substr(0, uri.length - 1);
		}
		var s:Array < String > = uri.split("/");
		if (s != null && s.length > n) {
			return s[n];
		}
		return null;
	}
	
	//static var uriScriptnameNo = 1;
	static function getUriScriptnameNo() {
		return HailsConfig.getUriScriptnameNo();
	}
	
	static function getScriptName() : String {
		return getUriPart(getUriScriptnameNo());
	}
	
	static function getUriAfterControllerPart(n:Int) : String {
		return getUriPart(getUriScriptnameNo()+1+n);
	}
	
	static function getControllerUri() : String {
		return getUriPart(getUriScriptnameNo() + 1);
	}
	
	static function getActionUri() : String {
		return getUriAfterControllerPart(1);
	}
	
	static function getControllerName() {
		var s = getControllerUri();
		if (s == null) {
			s = HailsConfig.defaultController;
		}
		if (s != null) {
			s = StringUtil.camelize(s) + "Controller";
		}
		return s;
	}
	
	static var overriddenAction:String = null;
	static function getActionName() {
		if (overriddenAction != null) {
			return overriddenAction;
		}
		var s = getActionUri();
		if (s != null && s != "") {
			s = StringUtil.camelizeWithFirstAsLower(s);
		} else {
			return null; // "index";
		}
		return s;
	}
	
	static function pageNotFound() : Void {
		Web.setReturnCode(404);
		Lib.print("404 Page don't exist");		
	}
	
	//static var urlParam = null;
	//static var urlParam2 = null;
	
	static function figureRoute() : Route {
		var method:String = Web.getMethod().toUpperCase();
		var params:StringMap<String> = Web.getParams();
		//trace(Web.getParamValues('_method'));
		if (method == 'POST') {
			/*var methodParam:Array < String > = Web.getParamValues('_method');
			if (methodParam != null && methodParam.length > 0) {
				method = methodParam[1].toUpperCase();
			}*/
			if (params.exists('_method')) {
				method = params.get('_method');
			}
		}
		var part1 = getUriAfterControllerPart(1);
		var part2 = getUriAfterControllerPart(2);
		//urlParam = part1;
		//urlParam2 = part2;
		//trace(part1);
		//trace(part2);
		if (method == 'POST') {
			if (part1 != null) {
				if (part2 != null)  {
					return Route.post_param2(part1, part2);
				}				
				return Route.post_param(part1);
			} else {
				return Route.post;
			}
		} else if (method == 'GET') {
			if (part1 != null) {
				if (part2 != null)  {
					return Route.get_param2(part1, part2);
				}				
				return Route.get_param(part1);
			} else {
				return Route.get;
			}
		} else if (method == 'DELETE') {
			if (part1 != null) {
				if (part2 != null)  {
					return Route.delete_param2(part1, part2);
				}				
				return Route.delete_param(part1);
			}
		}/* else if (method == 'PUT') {
			if (actionName != null) {
				return Route.get_param(actionName);
			} else {
				return Route.get;
			}
		}*/
		return null;
	}
	
	public static function handleRequest() : Void {
		try {
		var params:StringMap<String> = Web.getParams();
		var actionName:String = getActionName();
		//trace(actionName);
		if (StringTools.startsWith(actionName, "_")) {
			Logger.logDebug("ERR: Tried underscore-action: " + actionName);
			pageNotFound();
			return;
		}
		var controllerId = getControllerUri();
		//trace(controllerId);
		if (controllerId == null) {
			// default index
			controllerId = HailsConfig.defaultController;
		}
		var fullControllerName = controllerClassPrefix + getControllerName();
		var controllerClass:Class<Dynamic> = Type.resolveClass(fullControllerName);
		if (controllerClass != null) {
			var controller:HailsController = Type.createInstance(controllerClass, [actionName]);
			//if (Reflect.hasField(controller, 'actions')) {
			//	var actions:Dynamic = Reflect.field(controller, 'actions');
			//	
			//}
			var part1 = getUriAfterControllerPart(1);
			var part2 = getUriAfterControllerPart(2);
			controller.urlParam = part1;
			controller.urlParam2 = part2;
		
			var actionFound = false;
			var actionMethodName = "action_" + actionName;
			if (Reflect.hasField(controller, actionMethodName)) {
				actionFound = true;
			} else {
				var route = figureRoute();
				//trace(route);
				if (route != null) {
					actionMethodName = controller.route(route);
					//trace(actionMethodName);
					if (actionMethodName != null) {
						if (Reflect.hasField(controller, actionMethodName)) {
							controller.initialAction = actionMethodName;
							actionFound = true;
							actionName = actionMethodName;
						}
					}
				}
			}
			if (actionFound) {
				var actionMethod = Reflect.field(controller, actionMethodName);
				if (Reflect.isFunction(actionMethod)) {
					var hasError = false;
					var theError:Dynamic;
					try {
						//trace("before CALLMETHOD");
						var hc:HailsController = controller;
						hc.controllerId = controllerId;
						Logger.logInfo(controllerId + "." + actionMethodName);
						controller.before(actionName);
						// the before action might have rendered a redirect, for instance
						if (!controller.hasRendered) {
							Reflect.callMethod(hc, actionMethod, []); // []);
							overriddenAction = hc.initialAction;
							//trace("after CALLMETHOD");
							if (!hc.hasRendered && hc.shouldRender) {
								doRender(hc);						
							}
						}
						Web.flush();
						return;
					} catch (err:Dynamic) {
						hasError = true;
						theError = err;
					}
					HailsDbRecord.closeConnection(); // close sql-connection if open
					if (hasError) {
						throw theError;
					}
				}
			}
		}
		Logger.logDebug("Unknown controller/action: " + controllerId + "/" + actionName);
		pageNotFound();
		//trace("PAGE NOT FOUND");
		} catch (anyError:Dynamic) {
			Logger.logError("HailsDispatcher.handleRequest():" + anyError);
			throw anyError;
		}
	}
	
	static function doRender(hc:HailsController) {
		if (hc.renderType == "php") {
			new HailsViewPhp(hc, getControllerUri(), getActionName()).render();
		} else if (hc.renderType == "html") {
			hc.render();
		} else {
			throw new Exception("Unknown rendertype: " + hc.renderType);
		}
	}
}