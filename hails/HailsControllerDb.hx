/**
* ...
* @author Default
*/

package hails;

class HailsControllerDb extends HailsController {

	public function findById < T > (c:Class < T > , id:Dynamic) : T {
		return HailsDbRecord.findById(c, id);
	}
	
	public function findBy < T > (c:Class < T > , field:String, val:Dynamic) : List < T > {
		return HailsDbRecord.findByType(c, field, val);
	}
	
	public function findAll < T > (c:Class < T > ) : List < T > {
		return HailsDbRecord.findAllType(c);
	}
}