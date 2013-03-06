/**
 * ...
 * @author ...
 */

package hails;
import hails.util.StringUtil;
import haxe.ds.StringMap;

class HailsBaseRecord 
{
	/**
	 * Override this in model, to have default values.
	 * e.g.: { is_active : true }
	 * @return
	 */
	public function defaults() : Dynamic {
		return { };
	}
	
	//public var error:String;
	
	/**
	 * override this
	 */
	public function beforeSave() : Void {
		
	}
	
	var _errorFields:StringMap<String>;
	
	function addFieldError(fieldName:String, errorDescription:String) {
		if (_errorFields == null) {
			_errorFields = new StringMap<String>();
		}
		_errorFields.set(fieldName, errorDescription);
	}
	
	public function fieldHasError(fieldName:String) : Bool {
		return _errorFields != null && _errorFields.exists(fieldName);
	}
	
	public function getErrorMsgForField(fieldName:String) : String {
		return _errorFields.get(fieldName);
	}
	
	function clearErrors() {
		_error = null;
		_errorFields = null;
	}
	
	function getErrorFieldsAsHtml() : String {
		var it:Iterator<String> = _errorFields.keys();
		var fn:String;
		var ret:String = "<ul>";
		while (it.hasNext()) {
			fn = it.next();
			ret += "<li>" + getErrorMsgForField(fn) + "</li>";
		}
		ret += "</ul>";
		return ret;
	}
	
	var _error:String;
	
	function validationError(msg:String) : Bool {
		this._error = msg;
		return false;
	}
	
	public function getError() : String {
		if (_error != null) {
			return _error;
		}
		if (_errorFields != null) {
			return getErrorFieldsAsHtml();
		}
		return "";
	}
	
	function validationOk() : Bool {
		return true;
	}
	
	/**
	 * Override to add validation to model
	 * @return use validationOk() for ok, and validationError(msg) for failure
	 */
	public function validate() : Bool {
		return validationOk();
	}
	
	/**
	 * To be used by insert-method
	 */
	public function fillInDefaults() : Void {
		var def = defaults();
		if (def == null) {
			return;
		}
		var it:Iterator<String> = Reflect.fields(def).iterator();
		var fieldName:String;
		var propName:String;
		var propVal:Dynamic;
		while (it.hasNext()) {
			fieldName = it.next();
			propName = StringUtil.camelizeWithFirstAsLower(fieldName);
			if (Reflect.hasField(this, propName)) {
				propVal = Reflect.field(this, propName);
				if (propVal == null) {
					// value is not set (or set to null...? TODO ?)
					Reflect.setField(this, propName, Reflect.field(def, fieldName));
				}
			}
		}
	}
	
	var _fieldNames:List<String>;
	
	public function getFieldNames() : List < String > {
		//if (this._fieldNames == null) {
			var thisFields:Array<String> = Reflect.fields(this);
			this._fieldNames = new List<String>();
			for (fn in thisFields) {
				if (fn.charAt(0) != '_') {
					var field:Dynamic = Reflect.field(this, fn);
					if (!Reflect.isFunction(field)) {
						// It's not a field starting with "_" and it's not a function, so assume db-field:
						this._fieldNames.add(fn); // StringUtil.tableize(fn));
					}
				}
			}
		//}
		return this._fieldNames;
	}
	
	public function toString() {
		var it:Iterator<String> = getFieldNames().iterator();
		var fn:String;
		var ret = '{';
		var first = true;
		var val:Dynamic;
		while (it.hasNext()) {
			if (!first) {
				ret += ', ';
			}
			fn = it.next();
			val = Reflect.field(this, StringUtil.camelizeWithFirstAsLower(fn));
			ret += fn + ' : ' + val;
			first = false;
		}
		ret += '}';
		return ret;
	}
	
}