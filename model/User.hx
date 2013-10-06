package model;

import hails.HailsDbRecord;

/**
 * ...
 * @author test
 */

class User extends HailsDbRecord
{
	public var username:String; // @50

	public function new() 
	{
		super();
	}
	
	public static function findAll() {
		return HailsDbRecord.findAllType(User);
	}
	
}