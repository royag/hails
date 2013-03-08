package hails;

import hails.HailsDispatcher;
import hails.platform.IWebContext;
#if php
import hails.platform.PhpWebContext;
#end
#if java
import hails.platform.HailsServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import hails.platform.JavaWebContext;
#end

import config.DatabaseConfig;

class Main 
#if java
extends HailsServlet
#end
{
	public function new() {
	}
	
	static function handleRequest(ctx:IWebContext) : Void {
		HailsDispatcher.handleRequest(ctx);
	}
	
	static function main()
	{
		var ctx:IWebContext = null; // new PhpWebContext();
		#if php
		ctx = new PhpWebContext();
		#end
		handleRequest(ctx);
	}
	
	#if java
	@:overload private function doGet(req:HttpServletRequest, resp:HttpServletResponse) : Void {
		var ctx = new JavaWebContext(req, resp);
		handleRequest(ctx);
	}
	@:overload private function doPost(req:HttpServletRequest, resp:HttpServletResponse) : Void {
		var ctx = new JavaWebContext(req, resp);
		handleRequest(ctx);
	}	
	#end
}