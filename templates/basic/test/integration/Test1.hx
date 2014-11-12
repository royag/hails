package test.integration;

import hails.util.test.HailsLiveTestCase;

class Test1 extends HailsLiveTestCase
{

	public function testIndex() {
		var conn = createClient();
		conn.doGet("main/");
		assertEquals("<html>Hello world!</html>", conn.output.toString());
	}
	
	public function testAddAndShow() {
		var conn = createClient();
		conn.doGet("main/some_test");
		var a = conn.output.toString();
		conn.doGet("main/add");
		var b = conn.output.toString();
		conn.doGet("main/some_test");
		var c = conn.output.toString();
		assertTrue(c.length > a.length);
	}
	
	public function test404() {
		var conn = createClient();
		conn.doGet("main/thisDOESNTexist");
		assertEquals(404, conn.status);
	}
	
}