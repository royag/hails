package test.integration;

import hails.util.test.HailsLiveTestCase;

class Test1 extends HailsLiveTestCase
{

	public function testIndex() {
		var conn = createClient();
		conn.doGet("main/");
		assertEquals("<html>Hello world!</html>", conn.output.toString());
	}
	
	public function test404() {
		var conn = createClient();
		conn.doGet("main/thisDOESNTexist");
		assertEquals(404, conn.status);
	}
	
}