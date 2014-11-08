package test.unit;
import haxe.unit.TestRunner;
import hails.platform.Platform;
import test.unit.dispatcher.PathComponentTest;

class TestSuite
{
	public static function main() {
        var r = new TestRunner();
        r.add(
			new PathComponentTest()
		);
		r.run();
	}
}