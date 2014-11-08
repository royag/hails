package test.integration;
import haxe.Http;
import haxe.io.BytesOutput;
import haxe.remoting.HttpConnection;
import haxe.unit.TestCase;

/**
 * ...
 * @author Roy
 */
class Test1 extends TestCase
{

	function baseUrl() : String {
		//return "http://localhost:8080/hailsdemo/";
		return "http://localhost:2000/";
	}
	function onData(s:String) {
		trace("ON DATA CALLED");
		trace(s);
	}
	public function test1() {
		var out = new BytesOutput();
		var conn:SimpleHttpClient = new SimpleHttpClient(baseUrl());
		conn.doGet("main/some_test");
		
		//conn.onData = onData;
		//conn.customRequest(false, out, null, "POST");
		trace(conn.http.responseHeaders);
		trace(conn.output.getBytes().toString());
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