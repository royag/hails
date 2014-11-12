package test.unit;
import controller.MainController;
import hails.HailsDbRecord;
import haxe.unit.TestCase;
import hails.util.test.FakeWebContext;
import model.User;

class Test1 extends TestCase
{
	public function testUserSave() 
	{
		//var ctrl = new MainController("index", FakeWebContext.fromRelativeUriAndMethod("/main", "GET"));
		var u:User = new User();
		u.username = "TestUser";
		u.save();
		assertTrue(u.id >= 0);
		var u2 = HailsDbRecord.findById(User, u.id);
		assertEquals(u.username, u2.username);
		u.destroy();
	}
}