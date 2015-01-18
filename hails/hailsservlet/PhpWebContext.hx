package hails.hailsservlet ;
#if neko
import neko.Lib;
import neko.Web;
import hails.hailsservlet.neko.Session;
#end
#if php
import php.Lib;
import php.Web;
import php.Session;
#end

import haxe.ds.StringMap;
import haxe.io.Bytes;

import hails.HailsDbRecord;

/**
 * ...
 * @author test
 */
class PhpWebContext implements IWebContext
{
	var contentTypeSet:Bool = false;
	
	public function new() 
	{
		
	}
	
	public function getParams() : StringMap<String> {
		return Web.getParams();
	}
	public function getParamsString() : String {
		return Web.getParamsString();
	}
	public function getParamValues(param:String) : Array<String> {
		return Web.getParamValues(param);
	}
	
	public function sendRedirect(url:String) : Void {
		Web.redirect(url);
	}
	
	public function getMethod() : String {
		return Web.getMethod();
	}
	public function setReturnCode(code:Int) : Void {
		Web.setReturnCode(code);
	}
	public function setHeader(key:String, value:String) : Void {
		Web.setHeader(key,value);
	}
	public function addHeader(key:String, value:String) : Void {
		Web.setHeader(key,value);
	}	
	
	public function setContentType(ct:String) : Void {
		setHeader("Content-Type", ct);
		contentTypeSet = true;
	}
	public function isContentTypeSet() : Bool {
		return contentTypeSet;
	}
	
	
	public function flush() : Void {
		Web.flush();
	}
	public function printBinary(s:Blob) : Void {
		print(s);
	}

	public function print(s:String) : Void {
		Lib.print(s);
	}
	public function println(s:String) : Void {
		Lib.println(s);
	}
	public function getURI() : String {
		return Web.getURI();
	}
	public function getRelativeURI() : String {
		var u = getURI();
		#if php
		var basepath = "/index.php";
		if (u.indexOf(basepath) == 0) {
			return u.substring(basepath.length);
		} else {
			return u;
		}
		#else
		return u;
		#end
	}
	public function parseMultipart( onPart : String -> String -> Void, onData : Bytes -> Int -> Int -> Void ) : Void {
		Web.parseMultipart(onPart, onData);
	}
	public function setSession(key:String, value:Dynamic) : Void {
		Session.set(key, value);
	}
	public function getSession(key:String) : Dynamic {
		return Session.get(key);
	}
	public function getClientHeader(key:String) : String {
		return Web.getClientHeader(key);
	}
	
	public function sessionRegenerateId() : Void {
		#if php
		untyped __call__("session_regenerate_id", true);
		#end
	}
	
}
