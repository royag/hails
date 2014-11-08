package test.unit.dispatcher;
import hails.HailsDispatcher;
import haxe.unit.TestCase;

class PathComponentTest extends TestCase
{
	public function test_someComponents() {
		assertEquals(["main", "123", "abc"].toString(), 
			HailsDispatcher.getPathComponents("/main/123/abc?test=false").toString());
		assertEquals(["main", "123", "abc"].toString(), 
			HailsDispatcher.getPathComponents("main/123/abc?test=false").toString());
		assertEquals(["main", "123", "abc"].toString(), 
			HailsDispatcher.getPathComponents("/main/123/abc").toString());
	}
	
	public function test_oneComponent() {
		assertEquals(["main"].toString(), 
			HailsDispatcher.getPathComponents("/main?test=false").toString());
		assertEquals(["main"].toString(), 
			HailsDispatcher.getPathComponents("main").toString());
		assertEquals(["main"].toString(), 
			HailsDispatcher.getPathComponents("main/").toString());
		assertEquals(["main"].toString(), 
			HailsDispatcher.getPathComponents("main?a=b&c=d").toString());
		assertEquals(["main"].toString(), 
			HailsDispatcher.getPathComponents("/main/").toString());
		assertEquals(["main"].toString(), 
			HailsDispatcher.getPathComponents("/main").toString());
	}	

	public function test_noComponents() {
		assertEquals([].toString(), 
			HailsDispatcher.getPathComponents("/?test=false").toString());
		assertEquals([].toString(), 
			HailsDispatcher.getPathComponents("/").toString());
		assertEquals([].toString(), 
			HailsDispatcher.getPathComponents("").toString());
	}

	
}