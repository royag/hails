package controller;
import hails.Main;
import hails.HailsDispatcher;
import controller.MainController;
import controller.TestController1;
import controller.WebApp;
class WebApp extends Main
{

	static var tmp = HailsDispatcher.initControllers([MainController,TestController1]);

	static function main(){
		hails.Main.main();
	}	
}