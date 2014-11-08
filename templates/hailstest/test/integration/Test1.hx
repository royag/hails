package test.integration;
import haxe.Http;
import haxe.io.BytesOutput;
import haxe.remoting.HttpConnection;
import haxe.unit.TestCase;
import hails.util.test.HailsLiveTestCase;

/**
 * ...
 * @author Roy
 */
class Test1 extends HailsLiveTestCase
{

	public function test1() {
		var conn = createClient();
		conn.doGet("main/some_test");
		trace(conn.output.toString());
		trace(conn.http.responseHeaders);
		trace("COOKIES:");
		trace(conn.http.responseHeaders.get("Set-Cookie"));
		conn.doGet("main/some_test");
		trace("COOKIES:");
		trace(conn.http.responseHeaders.get("Set-Cookie"));
		conn.doDelete("main/some_test");
		trace("COOKIES:");
		trace(conn.http.responseHeaders.get("Set-Cookie"));
		trace(conn.status);
		assertTrue(true);
		
	}
	
}