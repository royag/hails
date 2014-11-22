package test.unit.dispatcher;
import controller.MainController;
import controller.TestController1;
import hails.HailsController;
import hails.HailsControllerMethodFinder;
import hails.HailsDispatcher;
import hails.util.test.FakeWebContext;
import haxe.ds.StringMap;
import haxe.PosInfos;
import haxe.rtti.Meta;
import haxe.unit.TestCase;
import test.unit.dispatcher.InitControllerTest;

@path("/")
class MainTestController extends HailsController {
	@GET
	public function index() {}
	@POST
	public function store() {}
}

@path("/user/{?userid}")
class UserTestController extends HailsController {
	@GET
	public function index() {}
	@POST
	public function update() {}
	@PUT
	public function insert() {}
	@DELETE
	public function delete() {}
}

@path("car")
class CarTestController extends HailsController {
	@GET
	public function index() {}
}

@path("road/{roadNo}")
class RoadTestController extends HailsController {
	@GET
	public function index() {}
}

class PathLessTestController extends HailsController {
	@GET
	public function index() { }
	@action
	public function actionByFunctionName() { }
	@action("myactionname")
	public function actionByAnnotation() {	}
	@action("postonly")
	@POST
	public function postActionByAnnotation() {	}
}

@path("actOne/{$action}")
class PathWithActionController extends HailsController {
	@action
	public function index() {}
	@action
	public function someTest() {}
	@action("post_only")
	@POST
	public function onlyWorksWithPost() {}
}

@path("actTwo/{$action}/{?param1}/")
class PathWithActionAndOptionalParamController extends HailsController {
	@action
	public function index() {}
	@action
	public function someTest() {}
	@action("post_only")
	@POST
	public function onlyWorksWithPost() { }
	@action("not_optional/{param1}")
	public function notOptional() { };
}

class ActionAndPathLessController extends HailsController {
	public function index() {}
	@thisissomethingelse
	public function index2() {}
}

@path("actionless")
class ActionLessController extends HailsController {
	public function index() {}
	@thisissomethingelse
	public function index2() {}
}

class MatchPathControllerTest extends TestCase
{
	static var controllers:Array<Class<HailsController>> = 
		[MainTestController, UserTestController, PathLessTestController, CarTestController,
		RoadTestController, PathWithActionController, PathWithActionAndOptionalParamController,
		ActionAndPathLessController,ActionLessController];

	public function testActionAndPathLessControllerShouldNotReturnAnything() {
		doTest("/action_and_path_less/", "GET", null, null, null);
		doTest("/action_and_path_less/index", "GET", null, null, null);
	}
	
	public function testActionLessControllerShouldNotReturnAnything() {
		doTest("/actionless/", "GET", null, null, null);
		doTest("/actionless/index", "GET", null, null, null);
	}	
		
	public function testPathWithActionAndOptionalParamController() {
		doTest("/actTwo/index", "GET", PathWithActionAndOptionalParamController, "index", strmap({"param1" : null}));
		doTest("/actTwo/post_only", "GET", null,null,null);
		doTest("/actTwo/post_only", "POST", PathWithActionAndOptionalParamController, "onlyWorksWithPost", strmap({"param1" : null}));
		doTest("/actTwo/index/myvalue", "GET", PathWithActionAndOptionalParamController, "index", strmap({"param1" : "myvalue"}));
		doTest("/actTwo/post_only/myvalue", "GET", null,null,null);
		doTest("/actTwo/post_only/myvalue", "POST", PathWithActionAndOptionalParamController, "onlyWorksWithPost", strmap({"param1" : "myvalue"}));

		doTest("/actTwo/not_optional/", "GET", null,null,null);
		doTest("/actTwo/not_optional/myvalue", "GET", PathWithActionAndOptionalParamController, "notOptional", strmap({"param1" : "myvalue"}));
	}
		
		
	public function testPathWithActionController() {
		doTest("/actOne/index", "GET", PathWithActionController, "index", strmap({}));
		doTest("/actOne/post_only", "GET", null,null,null);
		doTest("/actOne/post_only", "POST", PathWithActionController, "onlyWorksWithPost", strmap({}));
	}
		
		
	public function testRootPath() {
		doTest("/", "GET", MainTestController, "index", strmap({}));
		doTest("/main_test", "GET", null, null, null);
		doTest("/", "POST", MainTestController, "store", strmap({}));
	}
	
	public function testPathWithOptionalVariable() {
		doTest("/user/", "GET", UserTestController, "index", strmap({"userid" : null}));
		doTest("/user/", "POST", UserTestController, "update", strmap({"userid" : null}));
		doTest("/user/", "PUT", UserTestController, "insert", strmap({"userid" : null}));
		doTest("/user/", "DELETE", UserTestController, "delete", strmap({"userid" : null}));
		doTest("/user/123", "GET", UserTestController, "index", strmap({"userid" : "123"}));
		doTest("/user/123", "POST", UserTestController, "update", strmap({"userid" : "123"}));
		doTest("/user/123", "PUT", UserTestController, "insert", strmap({"userid" : "123"}));
		doTest("/user/123", "DELETE", UserTestController, "delete", strmap( { "userid" : "123" } ));		
	}
		
	public function testPathWithRequiredVariable() {
		doTest("/road/", "GET", null,null,null);
		doTest("/road/123", "GET", RoadTestController, "index", strmap( { "roadNo" : "123" } ));
	}
		
	public function testPathWithoutVariable() {
		doTest("/car/", "GET", CarTestController, "index", strmap({}));
		doTest("/car/123", "GET", null, null, null);
	}
	
	public function testPathLessController() {
		doTest("/path_less_test/", "GET", PathLessTestController, "index", strmap({}));
		doTest("/path_less_test/action_by_function_name", "GET", PathLessTestController, "actionByFunctionName", strmap({}));
		doTest("/path_less_test/myactionname", "GET", PathLessTestController, "actionByAnnotation", strmap({}));
		doTest("/path_less_test/postonly", "POST", PathLessTestController, "postActionByAnnotation", strmap({}));
		doTest("/path_less_test/postonly", "GET", null,null,null);
	}
	
	function strmap(d : Dynamic) {
		var ret = new StringMap<String>();
		for (key in Reflect.fields(d)) {
			ret.set(cast(key), cast(Reflect.field(d, key)));
		}
		return ret;
	}
	
	function doTest(uri:String, method:String, expController:Class<HailsController>, expFunc:String, expVars:StringMap<String>) {
		var ctx = FakeWebContext.fromRelativeUriAndMethod(uri, method);
		var res = HailsControllerMethodFinder.findControllerMethodParams(controllers, ctx);
		if (expController == null) {
			if (res != null) {
				trace(res.variables);
			}
			assertFalse(res != null);
			return;
		}
		assertTrue(res != null);
		assertEquals(expFunc, res.controllerFunction);
		assertEquals(expController, res.controller);
		assertEquals(expVars.toString(), res.variables.toString());
	}
	
}

