package test.unit.dispatcher;
import controller.MainController;
import controller.TestController1;
import controller.WebApp;
import hails.HailsDispatcher;
import hails.HailsController;
import haxe.unit.TestCase;

class WebAppDummy extends WebApp {
	public static var init = false;
	public static function load() {
		init = true;
	}
}

class InitControllerTest extends TestCase
{
	public function testInitControllersCalled() {
		WebAppDummy.load();
		var controllers:Array<Class<HailsController>> = HailsDispatcher._getControllerArrayCopy();
		assertFalse(controllers == null);
		assertEquals(2, controllers.length);
		assertTrue(controllers.indexOf(MainController) > -1);
		assertTrue(controllers.indexOf(TestController1) > -1);
	}
	
}