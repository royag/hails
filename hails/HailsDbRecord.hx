/**
* ...
* @author Default
*/

package hails;

import config.DatabaseConfig;
import controller.UserController;
import hails.util.StringUtil;
import php.db.Connection;
import php.db.Object;
import php.db.ResultSet;
import php.db.Mysql;
import Type;

class HailsDbRecord extends hails.HailsBaseRecord {
	public var id:Int;
	
	public function new() {
		
	}
	
	var _joinedFields:Hash<String>;
	
	public static function mergeConditions(conds:Array<Dynamic>, extraConditions:Array<Dynamic>) : Array<Dynamic>{
		if (conds == null) {
			conds = extraConditions;
		} else if (extraConditions != null) {
			conds[0] = conds[0] + ' and ' + extraConditions[0];
			conds = conds.concat(extraConditions.splice(1, 1));
		}
		return conds;
	}
	
	public function initFromResult(dbResult : Dynamic) : Void {
		if (dbResult == null) {
			// New record
			return;
		}
		var resFields:Array<String> = Reflect.fields(dbResult);
		var thisFields:Array<String> = Reflect.fields(this);
		this._fieldNames = new List<String>();
		var camelizedField:String;
		_joinedFields = new Hash<String>();
		for (i in 0...resFields.length) {
			camelizedField = StringUtil.camelizeWithFirstAsLower(resFields[i]);
			if (arrayContains(thisFields, camelizedField)) {
				Reflect.setField(this, camelizedField, Reflect.field(dbResult, resFields[i]));
				//trace('setting ' + camelizedField + ' to ' + Reflect.field(dbResult, resFields[i]) + '<br>');
				this._fieldNames.add(resFields[i]);
			} else {
				_joinedFields.set(resFields[i], Reflect.field(dbResult, resFields[i]));
			}
		}
	}

	public function getJoinedFields() : Hash < String > {
		return _joinedFields;		
	}

	public function getJoinedField(fieldName:String) : Dynamic {
		if (_joinedFields == null) {
			return null;
		}
		return _joinedFields.get(fieldName);
	}
	
	public function hasJoinedFields() : Bool {
		return (_joinedFields != null);
	}
	
	public function isNew() : Bool {
		return (this.id == null);
	}
	
	public function fieldValue(fname:String) : Dynamic {
		Logger.logDebug('field:' + fname);
		return Reflect.field(this, fname);
	}
	
	private function arrayContains(arr:Array < String > , s:String) : Bool {
		for (i in 0...arr.length) {
			if (arr[i] == s) {
				return true;
			}
		}
		return false;
	}

	public static function tableNameForClass < T > (c:Class < T > ) : String {
		return hails.util.StringUtil.tableize(hails.util.StringUtil.removePackageNameFromClassName(Type.getClassName(c)));
	}
	
	public function tableName() : String {
		return tableNameForClass(Type.getClass(this));
	}
	
	public static function findById < T > (c:Class < T > , id:Dynamic) : T {
		var recs:List < T > = findBy(c, "id", id);
		if (recs != null) {
			return recs.first();
		}  else {
			return null;
		}
	}
	
	public static function findBy < T > (c:Class < T > , field:String, val:Dynamic) : List < T > {
		//trace("      VAL = ");
		//trace(val.toString());
		var op:String = " = ";
		if (Type.typeof(val) == TClass(String)) {
			var s:String = val;
			if (StringTools.startsWith(s, '%') || StringTools.endsWith(s, '%')) {
				op = " LIKE ";
			}
		}
		// val.toString() works with haxe 2.01 but not with haxe 2.02
		var cond = [field + op + '?', val]; // "'" + val /*.toString()*/ + "'"; 
		return findAll(c, {conditions:cond});				
	}
	
	static function createWhere(options:Dynamic, conn:Connection) : String {
		//trace("OPTIONS:" + options + "<br>");
		if (options != null) {
			if (Reflect.hasField(options, 'conditions')) {
				var condArr:Array < Dynamic > = Reflect.field(options, 'conditions'); // e.g.: ["name = ?", 'roy'];
				if (condArr == null) {
					return '';
				}
				var condStr:String = condArr[0];
				var cnt = 1;
				// "name = ? and "
				var idx = condStr.indexOf('?');
				while (idx > -1) {
					Logger.logDebug('idx=' + idx);
					condStr = condStr.substr(0, idx) + 
						"'" + conn.escape(condArr[cnt]) + "'" +
						condStr.substr(idx + 1);
					idx = condStr.indexOf('?');
					cnt += 1;
					if (cnt > 20) {
						// We don't want no infinite loop if anything screws up here...
						throw "Too many conditions: " + cnt;
					}
				}
				return 'where ' + condStr;
			}
		}
		return '';		
	}
	
	static function createJoins(options:Dynamic) : String {
		var ret = '';
		var tmp = '';
		if (options != null) {
			if (Reflect.hasField(options, 'join')) {
				tmp = Reflect.field(options, 'join');
				if (tmp != null) {
					ret += ' ' + tmp + ' ';
				}
			}
			if (Reflect.hasField(options, 'include')) {
				tmp = Reflect.field(options, 'include');
				if (tmp != null) {
					ret += ' ' + Reflect.field(options, 'include') + ' ';
				}
			}
		}
		return ret;
	}
	
	static function createJoinsAndWhere(options:Dynamic, conn:Connection) : String {
		return createJoins(options) + createWhere(options, conn);
	}
	
	//public static function findAll < T > (c:Class < T >, ?options:Dynamic) : List < T > {
	//	return findByWhere(c, createWhere(options), options);
	//}

	//public static function countAll < T > (c:Class < T >, ?options:Dynamic) : Int {
	//	return countByWhere(c, createWhere(options), options);
	//}
	
	private static function getLimit(options:Dynamic) : String {
		if (options != null && Reflect.hasField(options, 'limit')) {
			var fieldVal = Reflect.field(options, 'limit');
			if (Type.typeof(fieldVal) == ValueType.TInt) {
				// Just limit, no start index:
				return " LIMIT " + fieldVal;
			} else {
				// start-index and limit:
				var limitArr:Array < Int > = Reflect.field(options, 'limit');
				if (limitArr != null) {
					return " LIMIT " + limitArr[0] + "," + limitArr[1];
				}
			}
		}
		return '';
	}
	
	private static function getOrderBy(options:Dynamic) : String {
		if (options != null && Reflect.hasField(options, 'order')) {
			var orderBy:String = Reflect.field(options, 'order');
			// TODO: check/escape value(?):
			if (orderBy != null) {
				return " ORDER BY " + orderBy;
			}
		}
		return '';
	}

	static function hasInclusions(options:Dynamic) {
		if (options != null && Reflect.hasField(options, 'include')) {
			if (Reflect.field(options, 'include') != null) {
				return true;
			}
		}
		return false;
	}
	
	static function createSql<T>(select:String, c:Class<T>, whereString:String, ?options:Dynamic) {
		var tableName:String = tableNameForClass(c);
		var sql = "SELECT "+select+" FROM " + tableName + " " + whereString +
			getOrderBy(options) +
			getLimit(options);
		return sql;
	}
	
	public static function countAll < T > (c:Class < T >, ?options:Dynamic, ?conn:Connection ) : Int {
		var hadConn = (conn != null);
		var error:Dynamic = null;
		if (!hadConn) {
			conn = createConnection();
		}
		var count:Int = null;
		try {
			var sql = createSql('count(*)', c, createJoinsAndWhere(options,conn), options);
			var res = runSql(sql, conn);
			count = res.getIntResult(0);
		} catch (err:Dynamic) {
			error = err;
		}
		if (!hadConn) {
			conn.close();
		}
		if (error != null) {
			throw error;
		}
		return count;
	}
	
	public static function findAll < T > (c:Class < T >, ?options:Dynamic, ?conn:Connection ) : List < T > {
		var hadConn = (conn != null);
		var error:Dynamic = null;
		var ret:List<T> = new List<T>();
		if (!hadConn) {
			conn = createConnection();
		}
		try {
			var tableName = tableNameForClass(c);
			var select = tableName + '.*';
			if (options != null && Reflect.hasField(options, 'select') && Reflect.field(options, 'select') != null) {
				select = Reflect.field(options, 'select');
			} else if (hasInclusions(options)) {
				select = '*'; // should include fields+values from joined tables....
			}
			var sql = createSql(select, c, createJoinsAndWhere(options,conn), options);
			var res:ResultSet = runSql(sql, conn);
			while (res.hasNext()) {
				var rec = Type.createInstance(c, []);
				var initFunc:Dynamic<T> = Reflect.field(rec, 'initFromResult');
				//ret.add(Type.createInstance(c, [res.next()]));
				Reflect.callMethod(rec, initFunc, [res.next()]);
				ret.add(rec);
			}
		} catch (err:Dynamic) {
			error = err;
		}
		if (!hadConn) {
			conn.close();
		}
		if (error != null) {
			throw error;
		}
		return ret;
	}
	
	public static function findAssociated < T , U > (rec:T, hasMany:Class < U > ) : List<U> {
		var foreignKey:String = tableNameForClass(Type.getClass(rec)) + "_id";
		return findBy(hasMany, foreignKey, Reflect.field(rec, "id"));
	}
	
	public function findAssociatedRecords<U>(hasMany:Class < U > ) : List < U > {
		return findAssociated(this, hasMany);
	}
	
	public static function findParent < T, U > (rec:T, parentClass:Class < U > ) : U {
		var foreignKey:String = tableNameForClass(parentClass).toLowerCase() + "_id";
		var parentId:Int = Reflect.field(rec, foreignKey);
		return findById(parentClass, parentId);
	}
	
	public function findOwnerRecord<U>(ownerClass:Class < U > ) : U {
		return findParent(this, ownerClass);
	}
	
	private static var connection:Connection;
	
	public static function createConnection() : Connection {
		/*if (connection == null) {
			trace("CONNECTION IS NULL");
			trace(connection);*/
		  var connection = Mysql.connect( 
			{ user : DatabaseConfig.user,
				socket : DatabaseConfig.socket,
				pass : DatabaseConfig.password,
				host : DatabaseConfig.host,
				port : DatabaseConfig.port,
			database : DatabaseConfig.database } );
		/*}
			trace("CONNECTION IS NOT NULL");
			trace(connection);*/
		return connection;
	}
	
	public static function closeConnection() {
		if (connection != null) {
			connection.close();
		}
	}
	
	/*private static function escapeValue(val:Dynamic, conn:Connection) : Dynamic {
		// ! TODO !
		//trace("<" + val + ">");
		//return val;
		if (conn == null) {
			conn = createConnection();
		}
		return conn.escape(val);
	}*/
	
	public static function runSql(sql:String, conn:Connection) : ResultSet {
		//var conn:Connection = createConnection();
		Logger.logInfo(sql);
		var res = conn.request(sql);
		//conn.close();
		return res;
	}
	
	public static function runSqlAndReturnId(sql:String, conn:Connection) : Int {
		//var conn:Connection = createConnection();
		Logger.logInfo(sql);
		var res = conn.request(sql);
		var lastId:Int = conn.lastInsertId();
		//conn.close();
		return lastId;
	}
	
	function updateCreatedAt() {
		if (Reflect.hasField(this, 'createdAt')) {
			Reflect.setField(this, 'createdAt', Date.now());
		}
	}
	
	function updateUpdatedAt() {
		if (Reflect.hasField(this, 'updatedAt')) {
			Reflect.setField(this, 'updatedAt', Date.now());
		}
	}
	
	public function fillInDefaultsAndCreatedAt() {
		fillInDefaults();
		updateCreatedAt();
		updateUpdatedAt();
	}
	
	public function insert(?conn:Connection) : Void {
		var hadConn = (conn != null);
		var error:Dynamic = null;
		if (!hadConn) {
			conn = createConnection();
		}
		try {
			updateCreatedAt();
			updateUpdatedAt();
			var sql:String = "INSERT INTO " + tableName();
			var fnString:String = "";
			var valString:String = "";
			var first:Bool = true;
			for (fn in getFieldNames()) {
				if (fn != "id") {
					var val:Dynamic = fieldValue(fn);
					if (val == false) {
						val = '0';
					}
					if (!first) {
						fnString += ",";
						valString += ",";
					}
					fnString += StringUtil.tableize(fn);
					if (val != null) {
						valString += "'" + conn.escape(val) + "'";
					} else {
						valString += "NULL";
					}
					first = false;
				}
			}
			sql += " (" + fnString + ") VALUES (" + valString + ")";
			this.id = runSqlAndReturnId(sql, conn);
		} catch (err:Dynamic) {
			error = err;
		}
		if (!hadConn) {
			conn.close();
		}
		if (error != null) {
			throw error;
		}
	}
	
	public function destroy(?conn:Connection) : Bool {
		var hadConn = (conn != null);
		var error:Dynamic = null;
		if (!hadConn) {
			conn = createConnection();
		}
		try {
			var sql:String = "DELETE FROM " + tableName() + " WHERE ID = " + conn.escape(Std.string(id));
			runSql(sql, conn);
		} catch (err:Dynamic) {
			error = err;
		}
		if (!hadConn) {
			conn.close();
		}
		if (error != null) {
			_error = error;
			Logger.logError('during deletion of ' + this + ': ' + error);
			return false;
		}
		return true;
	}
	
	/*function makeMysqlDate(d:Date) : String {
		trace(DateTools.format(d, '%Y-%m-%d'));
		return DateTools.format(d, '%Y-%m-%d');
	}*/
	
	public function update(?conn:Connection) : Void {
		var hadConn = (conn != null);
		var error:Dynamic = null;
		if (!hadConn) {
			conn = createConnection();
		}
		try {
			updateUpdatedAt();
			var sql:String = "UPDATE " + tableName() + " SET ";
			var updateString:String = "";
			var first:Bool = true;
			var fname:String;
			for (fn in getFieldNames()) {
				fname = StringUtil.tableize(fn);
				if (fn != "id") {
					var val:Dynamic = fieldValue(fn); // StringUtil.camelizeWithFirstAsLower(fn));
					/*if (Type.getClass(val) == Date) {
						val = makeMysqlDate(val);
					}*/
					//trace(fn + "=" + val);
					if (val == false) {
						val = '0';
					}
					if (!first) {
						updateString += ",";
					}
					if (val != null) {
						updateString += fname + " = '" + conn.escape(val) + "' ";
					} else {
						updateString += fname + " = NULL ";
					}
					first = false;
				}
			}
			sql += updateString + " WHERE id = '" + this.id + "'";
			runSql(sql, conn);
		} catch (err:Dynamic) {
			error = err;
		}
		if (!hadConn) {
			conn.close();
		}
		if (error != null) {
			throw error;
		}
	}
	
	public function updateFromHash(data:Hash < Dynamic > , fields:Array < String > ) {
		var it:Iterator<String> = fields.iterator();
		var fn:String;
		while (it.hasNext()) {
			fn = it.next();
			var val = data.get(fn);
			if (val != null && (Std.string(val).length > 0)) {
				Reflect.setField(this, fn, val);
			} else {
				Reflect.setField(this, fn, null);
			}
		}
	}
	
	public function save() : Bool {
		try {
			beforeSave();
			//this._error = null;
			clearErrors();
			if (isNew()) {
				fillInDefaults();
				// We validate AFTER defaults are filled in...
				if (!validate()) {
					return false;
				}
				insert();
				return true;
			} else {
				if (!validate()) {
					return false;
				}
				update();
				return true;
			}
		} catch (err:Dynamic) {
			this._error = 'System error';
			Logger.logError('during saving of ' + this + ': ' + err);
			return false;
		}
	}
}