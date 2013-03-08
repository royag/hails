/**
* ...
* @author Default
*/

package hails;

class HailsView {

	var controller:HailsController;
	var controllerId:String;
	var actionId:String;
	
	public function new(callingController:HailsController, controllerId:String, actionId:String) {
		this.controller = callingController;
		this.actionId = actionId;
		this.controllerId = controllerId;
	}
	
	public function render() {
		throw /*new Exception(*/"Render not implemented for " + Type.getClassName(Type.getClass(this)); // );
	}
}