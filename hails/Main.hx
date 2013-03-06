package hails;

import hails.HailsDispatcher;
import sys.db.Connection;
import sys.db.Mysql;
import sys.db.ResultSet;
import sys.io.File;
import php.Lib;
import php.Session;
import php.Web;


import config.DatabaseConfig;

class Main extends HailsDispatcher
{
	public function new() {
	}
	
	var conn:Connection;
	
	static function main()
	{
		/*if (php.db.Manager.cnx == null) {
			trace("INIT DB");
			initDb();
		} else {
			trace("DB ALREADY INITED");
		}*/
		HailsDispatcher.handleRequest();
		//cleanupDb();
	}
	
	static function initDb() {
		var cnx : Connection;
		cnx = Mysql.connect( {
		    user : DatabaseConfig.user,
			socket : DatabaseConfig.socket,
			pass : DatabaseConfig.password,
			host : DatabaseConfig.host,
			port : DatabaseConfig.port,
		    database : DatabaseConfig.database
		});
		sys.db.Manager.cnx = cnx;
		sys.db.Manager.initialize();
	}
	
	static function cleanupDb() {
		sys.db.Manager.cleanup();
		sys.db.Manager.cnx.close();
	}
	
	function doubleThis(i:Int) : Int {
		return i * 2;
	}
	
/*	function outputImage() : Void {
		
		Web.setHeader("Content-Type", "image/png");
		
		var im:GDImage = new GDImage(200, 200, 255,255,255);
		var red = im.allocColor(200, 0, 0);
		im.writeString(10, 10, "HEISANN", red);
		im.drawLine(0, 0, 100, 100, im.allocColor(0, 0, 100));
		
		var icon = [
			[1, 0, 0, 0, 0, 0, 0, 1, 1],
			[1, 1, 0, 0, 0, 0, 1, 0, 1],
			[1, 0, 1, 0, 0, 1, 0, 0, 1],
			[1, 0, 0, 1, 1, 0, 0, 0, 1],
			[1, 0, 0, 1, 1, 0, 0, 0, 1],
			[1, 0, 1, 0, 0, 1, 0, 0, 1],
			[1, 1, 0, 0, 0, 0, 1, 0, 1],
			[1, 0, 0, 0, 0, 0, 0, 1, 1]
		];
		
		im.drawPixelRows(icon, 50,150, red);
		im.outputPNG();
		im.destroy();
	}*/
	
}