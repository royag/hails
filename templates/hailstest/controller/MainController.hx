/**
 * ...
 * @author ...
 */

package controller;
import hails.HailsController;
import model.User;

@path("main")
class MainController extends HailsController
{
	public function index() {
		viewData = { theMessage:"Hello world!" };
		
	}
	
	@action
	@put
	public function action_add() {
		var u =  new User();
		u.username = 'heisann';
		var a = u.save();
		if (!a) {
			throw "couldnt save";
		}
	}
	
	public function action_someTest() {
		var s = "This is a test!";
		var users = User.findAll();
		for (u in users) {
			s += u.username + "," + Std.string(u);
		}
		viewData = { theMessage:s };
	}
}