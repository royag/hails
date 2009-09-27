/**
* ...
* @author Default
*/

package hails;

interface HailsRecord {

	public function initFromResult(dbResult : Dynamic) : Void;
	
	public function getFieldNames() : List < String > ;
	
}