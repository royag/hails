package test.unit.dispatcher;
import controller.MainController;
import controller.TestController1;
import hails.HailsController;
import hails.HailsDispatcher;
import haxe.rtti.Meta;
import haxe.unit.TestCase;
import test.unit.dispatcher.InitControllerTest;

class MatchPathControllerTest extends TestCase
{
	public function testPathMetaSimple() {
		WebAppDummy.load();
		var exp:Class<HailsController> = TestController1;
		assertEquals(exp, HailsDispatcher.findControllerFromPath("onetest/"));
	}
	
	public function testMissingPathMatch() {
		WebAppDummy.load();
		var exp:Class<HailsController> = MainController;
		// The test is only valid if Controller has no path annotation:
		assertTrue(Meta.getType(MainController).path == null);
		assertEquals(exp, HailsDispatcher.findControllerFromPath("main/"));
	}
	
}