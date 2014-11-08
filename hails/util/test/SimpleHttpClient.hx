package hails.util.test ;
import haxe.ds.StringMap;
import haxe.Http;
import haxe.io.Bytes;
import haxe.io.BytesOutput;

class SimpleHttpClient
{
	var baseUrl:String;
	var cookies:StringMap<String>;
	public var http:Http;
	public var output:Bytes;
	public function new(baseUrl : String) 
	{
		this.baseUrl = baseUrl;
		this.cookies = new StringMap<String>();
	}
	
	// Must be updated to support multiple Set-Cookie headers:
	function handleCookies(headers:StringMap<String>) {
		for (k in headers.keys()) {
			//trace(k);
			if (k == "Set-Cookie") {
				var c = headers.get(k);
				var kv = StringTools.trim(c.split(";")[0]).split("="); // ignore path,expiry etc for now
				cookies.set(kv[0], kv[1]);
			}
		}
	}
	function prepareCookies(http:Http) {
		for (k in cookies.keys()) {
			//trace("Adding: " + k + "=" + cookies.get(k));
			http.addHeader("Cookie", k + "=" + cookies.get(k));
		}
	}
	
	public var status:Int;
	public function onStatus( status : Int ) {
		this.status = status;
	}

	public function doGet(path:String, preparer:Http -> Void = null) {
		http = new Http(baseUrl + path);
		if (preparer != null) {
			preparer(http);
		}
		prepareCookies(http);
		http.onStatus = this.onStatus;
		var out = new BytesOutput();
		http.customRequest(false, out, null, "GET");
		output = out.getBytes();		
		handleCookies(http.responseHeaders);
	}
	
	public function doPost(path:String, postdata:String, preparer:Http -> Void = null) {
		http = new Http(baseUrl + path);
		if (preparer != null) {
			preparer(http);
		}
		prepareCookies(http);
		http.onStatus = this.onStatus;
		http.setPostData(postdata);
		var out = new BytesOutput();
		http.customRequest(true, out, null, "POST");
		output = out.getBytes();		
		handleCookies(http.responseHeaders);
	}	

	public function doDelete(path:String, preparer:Http -> Void = null) {
		http = new Http(baseUrl + path);
		if (preparer != null) {
			preparer(http);
		}
		prepareCookies(http);
		http.onStatus = this.onStatus;
		var out = new BytesOutput();
		http.customRequest(false, out, null, "DELETE");
		output = out.getBytes();		
		handleCookies(http.responseHeaders);
	}	
	
	public function doPut(path:String, preparer:Http -> Void = null) {
		http = new Http(baseUrl + path);
		if (preparer != null) {
			preparer(http);
		}
		prepareCookies(http);
		http.onStatus = this.onStatus;
		var out = new BytesOutput();
		http.customRequest(false, out, null, "PUT");
		output = out.getBytes();		
		handleCookies(http.responseHeaders);
	}		
	
}