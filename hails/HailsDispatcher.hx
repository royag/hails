package hails;

//import controller.MainController;
import hails.config.HailsConfig;
import hails.hailsservlet.IWebContext;
import hails.platform.Platform;
import hails.util.StringUtil;
import haxe.ds.StringMap;
import haxe.rtti.Meta;




class HailsDispatcher {
	
	public function new() {
		
	}
	
	private static var controllers:Array<Class<HailsController>> = null;
	
	/**
	* The generated WebApp.hx will call this once to load all controllers
	*/
	public static function initControllers(theControllers : Array<Class<HailsController>>) : Bool {
		if (controllers != null) {
			return false;
		}
		controllers = theControllers.copy();
		return true;	
	}
	public static function _getControllerArrayCopy() {
		if (controllers != null) {
			return controllers.copy();
		}
		return null;
	}
	
	/*var overriddenAction:String = null;
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
	}*/
	
	function pageNotFound(ctx:IWebContext) : Void {
		ctx.setReturnCode(404);
		try {
			ctx.setContentType("text/html");
			ctx.print(HailsBaseController.getViewContent("/404.html"));
		} catch (ex:Dynamic) {
			ctx.print("404 Page not found");
		}
	}
	
	public static function handleRequest(ctx:IWebContext) : Void {
		var h = new HailsDispatcher();
		h.doHandleRequest(ctx);
	}	
	
	function doHandleRequest(ctx:IWebContext) : Void {
		try {
			var ctrl = HailsControllerMethodFinder.findControllerMethodParams(controllers, ctx);
			if (ctrl == null) {
				pageNotFound(ctx);
				return;
			}
			
			var constructorParams:Array<Dynamic> = [ctrl.controllerFunction, ctx, ctrl.variables];
			var controller:HailsController = Type.createInstance(ctrl.controller, constructorParams);
			var actionMethod = Reflect.field(controller, ctrl.controllerFunction);
			var simpleControllerName = Type.getClassName(ctrl.controller).split(".").pop();
			var controllerId:String = null;
			if (StringTools.endsWith(simpleControllerName, "Controller")) {
				controllerId = StringUtil.tableize(simpleControllerName.substring(0, simpleControllerName.length - "Controller".length));
			} else {
				controllerId = StringUtil.tableize(simpleControllerName);
			}
			
			if (Reflect.isFunction(actionMethod)) {
				var hasError = false;
				var theError:Dynamic;
				try {
					controller.controllerId = controllerId;
					Logger.logInfo(controllerId + "." + ctrl.controllerFunction);
					controller.before(ctrl.controllerFunction);
					// the before action might have rendered a redirect, for instance
					if (!controller.hasRendered) {
						Reflect.callMethod(controller, actionMethod/*actionMethod*/, []); // []);
						//overriddenAction = controller.initialAction;
						//trace("after CALLMETHOD");
						if (!controller.hasRendered && controller.shouldRender) {
							doRender(controller,ctx);						
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
			Logger.logDebug("Unknown controller/action: " + controllerId + "/" + ctrl.controllerFunction);
			pageNotFound(ctx);
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
		if (hc.renderType == "html") {
			hc.render();
		} else {
			throw /*new Exception(*/"Unknown rendertype: " + hc.renderType; // );
		}
	}
}