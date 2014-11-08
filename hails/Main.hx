package hails;

import hails.HailsDispatcher;
import hails.hailsservlet.IWebContext;
#if php
import hails.hailsservlet.PhpWebContext;
#end
#if neko
import hails.hailsservlet.PhpWebContext;
#end
#if java
import hails.hailsservlet.java.HailsServlet;
import hails.hailsservlet.java.javax.servlet.http.HttpServletRequest;
import hails.hailsservlet.java.javax.servlet.http.HttpServletResponse;
import hails.hailsservlet.JavaWebContext;
#end

//import config.DatabaseConfig;

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
		#if neko
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