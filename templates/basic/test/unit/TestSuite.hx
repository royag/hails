package test.unit;
import haxe.unit.TestRunner;
import hails.platform.Platform;

class TestSuite
{
	public static function main() {
        var r = new TestRunner();
		r.add(new Test1());
		r.run();
	}
}