/**
* ...
* @author Default
*/

package hails;

import config.HailsConfig;
import hails.platform.IWebContext;
import hails.util.StringUtil;
import haxe.ds.StringMap;
#if neko
import neko.Lib;
#end

// ControllerConfig should import all controllers, just to make them compile...
// (Because if there are no references (as they are loaded dynamically) they're not compiled.
import config.ControllerConfig;

//
class HailsDispatcher {

	public function new() {
		
	}
	
	/*function log(s:String):Void {
		//Lib.println(s);
	}*/
	
	static var controllerClassPrefix:String = "controller.";
	
	function getUriPart(n:Int, ctx:IWebContext) : String {
		var uri:String = ctx.getURI();
		//log("URI=["+uri+"]");
		if (uri.charAt(uri.length - 1) == "/") {
			uri = uri.substr(0, uri.length - 1);
		}
		var s:Array < String > = uri.split(HailsConfig.URL_SEP);
		if (s != null && s.length > n) {
			return s[n];
		}
		return null;
	}
	
	//static var uriScriptnameNo = 1;
	function getUriScriptnameNo() {
		return HailsConfig.getUriScriptnameNo();
	}
	
	function getScriptName(ctx:IWebContext) : String {
		return getUriPart(getUriScriptnameNo(),ctx);
	}
	
	function getUriAfterControllerPart(n:Int,ctx:IWebContext) : String {
		return getUriPart(getUriScriptnameNo()+1+n,ctx);
	}
	
	 function getControllerUri(ctx:IWebContext) : String {
		return getUriPart(getUriScriptnameNo() + 1,ctx);
	}
	
	function getActionUri(ctx:IWebContext) : String {
		return getUriAfterControllerPart(1,ctx);
	}
	
	function getControllerName(ctx:IWebContext) {
		var s = getControllerUri(ctx);
		if (s == null) {
			s = HailsConfig.defaultController;
		}
		if (s != null) {
			s = StringUtil.camelize(s) + "Controller";
		}
		return s;
	}
	
	var overriddenAction:String = null;
	function getActionName(ctx:IWebContext) {
		if (overriddenAction != null) {
			return overriddenAction;
		}
		var s = getActionUri(ctx);
		if (s != null && s != "") {
			s = StringUtil.camelizeWithFirstAsLower(s);
		} else {
			return "index";
		}
		return s;
	}
	
	function pageNotFound(ctx:IWebContext) : Void {
		ctx.setReturnCode(404);
		ctx.print("404 Page don't exist");		
	}
	
	//static var urlParam = null;
	//static var urlParam2 = null;
	
	function figureRoute(ctx:IWebContext) : Route {
		var method:String = ctx.getMethod().toUpperCase();
		//trace(ctx);
		var params:StringMap<String> = ctx.getParams();
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
		var part1 = getUriAfterControllerPart(1,ctx);
		var part2 = getUriAfterControllerPart(2,ctx);
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
	public static function handleRequest(ctx:IWebContext) : Void {
		var h = new HailsDispatcher();
		h.doHandleRequest(ctx);
	}
	
	function doHandleRequest(ctx:IWebContext) : Void {
		try {
			//trace(ctx);
		var params:StringMap<String> = ctx.getParams();
		var actionName:String = getActionName(ctx);
				//log(actionName);

		//trace(actionName);
		if (actionName == null) {
			actionName = "";
		}
		if (StringTools.startsWith(actionName, "_")) {
			Logger.logDebug("ERR: Tried underscore-action: " + actionName);
			pageNotFound(ctx);
			return;
		}
		var controllerId = getControllerUri(ctx);
		//log(controllerId);
		//trace(controllerId);
		if (controllerId == null) {
			// default index
			controllerId = HailsConfig.defaultController;
		}
		var fullControllerName = controllerClassPrefix + getControllerName(ctx);
		
		//log("fullControllerName=" + fullControllerName);
		
		var controllerClass:Class<Dynamic> = Type.resolveClass(fullControllerName);
		
		//log("controllerClass=" + Std.string(controllerClass));
		
		if (controllerClass != null) {
			var constructorParams:Array<Dynamic> = [actionName, ctx];
			var controller:HailsController = Type.createInstance(controllerClass, constructorParams);
			//if (Reflect.hasField(controller, 'actions')) {
			//	var actions:Dynamic = Reflect.field(controller, 'actions');
			//	
			//}
			var part1 = getUriAfterControllerPart(1,ctx);
			var part2 = getUriAfterControllerPart(2,ctx);
			controller.urlParam = part1;
			controller.urlParam2 = part2;
		
			var actionFound = false;
			var actionMethodName = "action_" + actionName;
			//log("looking for field [" + actionMethodName + "]");
			var fields = Type.getInstanceFields(controllerClass);
			//ArrayTools.
			actionFound = exists(fields, actionMethodName);
			if (actionFound) { //Reflect.hasField(controller, actionMethodName)) {
				//actionFound = true;
				//log("found field");
			} else {
				//log("dit NOT find field .. try figure route");
				
				
				var actionMethod = Reflect.field(controller, actionMethodName);
				//log("actionMethod=" + actionMethod);
				
				var route = figureRoute(ctx);
				//trace(route);
				if (route != null) {
					actionMethodName = controller.route(route);
					//trace(actionMethodName);
					if (actionMethodName != null) {
						if (exists(fields, actionMethodName)) { //Reflect.hasField(controller, actionMethodName)) {
							controller.initialAction = actionMethodName;
							actionFound = true;
							actionName = actionMethodName;
						}
					}
				}
			}
			if (actionFound) {
				var actionMethod = Reflect.field(controller, actionMethodName);
				//Reflect.callMethod(
				//log("WE SHALL CALL: " + actionMethodName);
				//log("METHOD: " + actionMethod);
				if (Reflect.isFunction(actionMethod)) {
					var hasError = false;
					var theError:Dynamic;
					try {
						//trace("before CALLMETHOD");
						var hc:HailsController = controller;
						actionMethod = Reflect.field(hc, actionMethodName);
						//log("METHOD: " + actionMethod);
						hc.controllerId = controllerId;
						Logger.logInfo(controllerId + "." + actionMethodName);
						controller.before(actionName);
						// the before action might have rendered a redirect, for instance
						if (!controller.hasRendered) {
							Reflect.callMethod(hc, actionMethod/*actionMethod*/, []); // []);
							overriddenAction = hc.initialAction;
							//trace("after CALLMETHOD");
							if (!hc.hasRendered && hc.shouldRender) {
								doRender(hc,ctx);						
							}
						}
						ctx.flush();
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
		//log("Unknown controller/action: " + controllerId + "/" + actionName);
		Logger.logDebug("Unknown controller/action: " + controllerId + "/" + actionName);
		pageNotFound(ctx);
		//trace("PAGE NOT FOUND");
		} catch (anyError:Dynamic) {
			//log(Std.string(anyError));
			Logger.logError("HailsDispatcher.handleRequest():" + anyError);
			throw anyError;
		}
	}
	
	function exists(arr:Array<String>, s:String) : Bool {
		for (ss in arr) {
			if (s == ss) {
				return true;
			}
		}
		return false;
	}
	
	function doRender(hc:HailsController, ctx:IWebContext) {
		#if php
		if (hc.renderType == "php") {
			new HailsViewPhp(hc, getControllerUri(ctx), getActionName(ctx)).render();
		} else 
		#end
		if (hc.renderType == "html") {
			hc.render();
		} else {
			throw /*new Exception(*/"Unknown rendertype: " + hc.renderType; // );
		}
	}
}