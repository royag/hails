package test.unit;
import haxe.unit.TestRunner;
import hails.platform.Platform;
import test.unit.dispatcher.InitControllerTest;
import test.unit.dispatcher.MatchPathControllerTest;

class TestSuite
{
	public static function main() {
        var r = new TestRunner();
		r.add(new InitControllerTest());
		r.add(new MatchPathControllerTest());
		r.run();
	}
}