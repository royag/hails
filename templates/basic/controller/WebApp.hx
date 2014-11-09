package controller;
import hails.Main;
import hails.HailsDispatcher;
import controller.MainController;
import controller.WebApp;
class WebApp extends Main
{

	static var tmp = new ControllerLoader([MainController]);

	static function main(){
		hails.Main.main();
	}	
}