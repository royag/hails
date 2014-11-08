package test.integration;
import haxe.unit.TestRunner;

/**
 * ...
 * @author Roy
 */
class TestSuite
{

	public function new() 
	{
		
	}
	
	public function runTests()  {
        var r = new TestRunner();
		
        r.add(new Test1());
		r.run();
		trace(r.result);
	}
	
	public static function main() {
		new TestSuite().runTests();
	}
	
}