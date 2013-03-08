/**
 * ...
 * @author ...
 */

package controller;
import hails.HailsController;

class MainController extends HailsController
{
	public function index() {
		viewData = { theMessage:"Hello world!" };
	}
	
	public function action_someTest() {
		viewData = { theMessage:"This is a test!" };
	}
}