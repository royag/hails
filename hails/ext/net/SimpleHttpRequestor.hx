package hails.ext.net;

#if java
import hails.ext.net.java.JavaSimpleHttpRequestor;
#end

import haxe.io.BytesOutput;
import haxe.Http;
import haxe.io.Bytes;

class SimpleHttpRequestor
{

	function new() 
	{
		
	}
	
	public static function createInstance() : SimpleHttpRequestor {
		#if java
		return new JavaSimpleHttpRequestor();
		#else
		return new SimpleHttpRequestor();
		#end
	}
	
	public function get(url:String) : String {
		var out = new BytesOutput();
		var http = new Http(url);
		//http.onStatus = function(status:Int) { trace(status);  };
		//http.onError = function(err:Dynamic) { assertEquals("NO ERROR", err);  };
		http.customRequest(false, out, null, "GET");
		var output = out.getBytes();
		return output.toString();
	}
	
}