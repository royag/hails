package hails.util.test ;
import haxe.unit.TestCase;

class HailsLiveTestCase extends TestCase
{
	function baseUrl() : String {
		for (arg in Sys.args().iterator()) {
			if (arg.indexOf("baseurl=") == 0) {
				return arg.split("=")[1];
			}
		}
		return null;
	}
	
	function createClient() : SimpleHttpClient {
		return new SimpleHttpClient(baseUrl());
	}
	
}