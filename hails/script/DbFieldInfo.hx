/**
* ...
* @author Default
*/

package hails.script;
import hails.config.DatabaseConfig;

//import php.Exception;

enum DbFieldType {
	dbInt;
	dbString;
	dbBoolean;
	dbDatetime;
	dbFloat;
	dbBlob;
	dbMediumBlob;
	dbLongBlob;
	dbText;
}

class DbFieldInfo {
	//public var indexed:Bool;
	public var nullable:Bool;
	public var length:Int;
	public var dbtype:DbFieldType;
	public var isId:Bool;
	public function new(_dbtype:DbFieldType) {
		this.dbtype = _dbtype;
		this.isId = false;
		this.length = -1;	// -1 means don't care (use db-default)
		//this.indexed = false;
		this.nullable = true;
	}
	
	public function toColumnDefinition() : String {
		if (DatabaseConfig.getType() == "sqlserver") {
			return toSqlServerColumnDefinition();
		} else if (DatabaseConfig.getType() == "sqlite") {
			return toSqliteColumnDefinition();
		} else {
			return toMysqlColumnDefinition();
		}
	}
	
	private function toSqliteColumnDefinition() : String {
		var sql = "";
		sql += switch(dbtype) {
			case dbInt : "integer";
			case dbString : "varchar";
			case dbBoolean : "boolean";
			case dbDatetime : "datetime";
			case dbFloat : "float";
			case dbBlob : "blob";
			case dbMediumBlob : "mediumblob";
			case dbLongBlob : "longblob";
			case dbText : "text";
		}
		/*if (length > -1) {
			sql += "(" + length + ")";
		} else {
			switch(dbtype) {
				case dbInt : sql += "(11)";
				case dbString : sql += "(100)";
				default : {	}
			}
		}*/
		if (this.isId) {
			sql += " PRIMARY KEY AUTOINCREMENT";
		} else {
			sql += " " + (nullable ? "" : "NOT ") + "NULL";
		}
		return sql;
	}	
	
	private function toMysqlColumnDefinition() : String {
		var sql = "";
		sql += switch(dbtype) {
			case dbInt : "int";
			case dbString : "varchar";
			case dbBoolean : "boolean";
			case dbDatetime : "datetime";
			case dbFloat : "float";
			case dbBlob : "blob";
			case dbMediumBlob : "mediumblob";
			case dbLongBlob : "longblob";
			case dbText : "text";
		}
		if (length > -1) {
			sql += "(" + length + ")";
		} else {
			switch(dbtype) {
				case dbInt : sql += "(11)";
				case dbString : sql += "(100)";
				default : {	}
			}
		}
		if (this.isId) {
			sql += " PRIMARY KEY AUTO_INCREMENT";
		} else {
			sql += " " + (nullable ? "" : "NOT ") + "NULL";
		}
		return sql;
	}
	
	private function toSqlServerColumnDefinition() : String {
		var sql = "";
		sql += switch(dbtype) {
			case dbInt : "int";
			case dbString : "varchar";
			case dbBoolean : "bit";
			case dbDatetime : "datetime";
			case dbFloat : "float";
			case dbBlob : "varbinary(MAX)";
			case dbMediumBlob : "varbinary(MAX)";
			case dbLongBlob : "varbinary(MAX)";
			case dbText : "text";
		}
		if (length > -1) {
			sql += "(" + length + ")";
		} else {
			switch(dbtype) {
				//case dbInt : sql += "(11)";
				case dbString : sql += "(100)";
				default : {	}
			}
		}
		if (this.isId) {
			sql += " IDENTITY(1,1)";
		} else {
			sql += " " + (nullable ? "" : "NOT ") + "NULL";
		}
		return sql;
	}	
	
	// varchar(10)
	public static function findLengthOfMysqlType(t:String) : Int {
		var start = t.indexOf("(");
		if (start < 0) {
			return -1;
		}
		var end = t.indexOf(")");
		var len:Int = Std.parseInt(t.substr(start + 1, end - start - 1));
		if (len <= 0) { // == null) {
			throw "Could not parse int: " + t.substr(start + 1, end - start);
			//return -1;
		}
		return len;
		
	}
	
	public static function createFromServerDescription(desc:Dynamic) : DbFieldInfo {
		if (DatabaseConfig.getType() == "sqlserver") {
			return createFromSqlServerDescription(desc);
		} else if (DatabaseConfig.getType() == "sqlite") {
			return createFromSqliteDescription(desc);
		}
		return createFromMysqlDescription(desc);
	}
	
	private static function createFromSqlServerDescription(desc:Dynamic) : DbFieldInfo {
		//var fieldName:String = Reflect.field(f, "Field");
		var mysqlType:String = Reflect.field(desc, "DATA_TYPE");
		var nullable:String = Reflect.field(desc, "IS_NULLABLE"); // "YES" or "NO"
		//var defaultVal:String = Reflect.field(desc, "Type"); // null		
		var dbtype:DbFieldType;
		if (StringTools.startsWith(mysqlType, "varchar")) {
			dbtype = dbString;
		} else if (StringTools.startsWith(mysqlType, "int")) {
			dbtype = dbInt;
		} else if (StringTools.startsWith(mysqlType, "datetime")) {
			dbtype = dbDatetime;
		} else if (StringTools.startsWith(mysqlType, "bit")) {
			dbtype = dbBoolean;
		} else if (StringTools.startsWith(mysqlType, "tinyint(1)")) {
			dbtype = dbBoolean;
		} else if (StringTools.startsWith(mysqlType, "float")) {
			dbtype = dbFloat;
		} else if (StringTools.startsWith(mysqlType, "varbinary")) {
			dbtype = dbBlob;
		} else if (StringTools.startsWith(mysqlType, "varbinary")) {
			dbtype = dbMediumBlob;
		} else if (StringTools.startsWith(mysqlType, "varbinary")) {
			dbtype = dbLongBlob;
		} else if (StringTools.startsWith(mysqlType, "text")) {
			dbtype = dbText;
		} else {
			throw "unknown databasetype: " + mysqlType;
		}
		var t = new DbFieldInfo(dbtype);
		t.length = findLengthOfMysqlType(mysqlType);
		t.nullable = nullable == "YES";
		return t;
	}
	
	private static function createFromSqliteDescription(desc:Dynamic) : DbFieldInfo {
		//var fieldName:String = Reflect.field(f, "Field");
		var mysqlType:String = Reflect.field(desc, "type");
		//var nullable:String = Reflect.field(desc, "Null"); // "YES" or "NO"
		//var defaultVal:String = Reflect.field(desc, "Type"); // null		
		var dbtype:DbFieldType;
		if (StringTools.startsWith(mysqlType, "varchar")) {
			dbtype = dbString;
		} else if (StringTools.startsWith(mysqlType, "integer")) {
			dbtype = dbInt;
		} else if (StringTools.startsWith(mysqlType, "datetime")) {
			dbtype = dbDatetime;
		} else if (StringTools.startsWith(mysqlType, "boolean")) {
			dbtype = dbBoolean;
		} else if (StringTools.startsWith(mysqlType, "tinyint(1)")) {
			dbtype = dbBoolean;
		} else if (StringTools.startsWith(mysqlType, "float")) {
			dbtype = dbFloat;
		} else if (StringTools.startsWith(mysqlType, "blob")) {
			dbtype = dbBlob;
		} else if (StringTools.startsWith(mysqlType, "mediumblob")) {
			dbtype = dbMediumBlob;
		} else if (StringTools.startsWith(mysqlType, "longblob")) {
			dbtype = dbLongBlob;
		} else if (StringTools.startsWith(mysqlType, "text")) {
			dbtype = dbText;
		} else {
			throw "unknown databasetype: " + mysqlType;
		}
		var t = new DbFieldInfo(dbtype);
		t.length = findLengthOfMysqlType(mysqlType);
		t.nullable = true; // nullable == "YES";
		return t;
	}	
	
	private static function createFromMysqlDescription(desc:Dynamic) : DbFieldInfo {
		//var fieldName:String = Reflect.field(f, "Field");
		var mysqlType:String = Reflect.field(desc, "Type");
		var nullable:String = Reflect.field(desc, "Null"); // "YES" or "NO"
		//var defaultVal:String = Reflect.field(desc, "Type"); // null		
		var dbtype:DbFieldType;
		if (StringTools.startsWith(mysqlType, "varchar")) {
			dbtype = dbString;
		} else if (StringTools.startsWith(mysqlType, "int")) {
			dbtype = dbInt;
		} else if (StringTools.startsWith(mysqlType, "datetime")) {
			dbtype = dbDatetime;
		} else if (StringTools.startsWith(mysqlType, "boolean")) {
			dbtype = dbBoolean;
		} else if (StringTools.startsWith(mysqlType, "tinyint(1)")) {
			dbtype = dbBoolean;
		} else if (StringTools.startsWith(mysqlType, "float")) {
			dbtype = dbFloat;
		} else if (StringTools.startsWith(mysqlType, "blob")) {
			dbtype = dbBlob;
		} else if (StringTools.startsWith(mysqlType, "mediumblob")) {
			dbtype = dbMediumBlob;
		} else if (StringTools.startsWith(mysqlType, "longblob")) {
			dbtype = dbLongBlob;
		} else if (StringTools.startsWith(mysqlType, "text")) {
			dbtype = dbText;
		} else {
			throw "unknown databasetype: " + mysqlType;
		}
		var t = new DbFieldInfo(dbtype);
		t.length = findLengthOfMysqlType(mysqlType);
		t.nullable = nullable == "YES";
		return t;
	}
	
	public static function createFromHaxeTypeName(typeName:String, ?annot:String) {
		var t:DbFieldType;
		var length = -1;
		switch(typeName) {
			case "Int" : t = dbInt;
			case "String" : {
				t = dbString;
				if (annot != null) {
					if (annot.toLowerCase() == '@blob') {
						t = dbBlob;
					} else if (annot.toLowerCase() == '@mediumblob') {
						t = dbMediumBlob;
					} else if (annot.toLowerCase() == '@longblob') {
						t = dbLongBlob;
					} else if (annot.toLowerCase() == '@text') {
						t = dbText;
					} else {
						var lenStr = StringTools.trim(annot.substr(1));
						length = Std.parseInt(lenStr);
					}
				} 
			}
			case "Bool" : t = dbBoolean;
			case "Float" : t = dbFloat;
			case "Date" : t = dbDatetime;
			default : throw "Unknown typeName: " + typeName;
		}
		var ret = new DbFieldInfo(t);
		if (length > -1) {
			ret.length = length;
		}
		return ret;
	}
	
	public function isNullable() : Bool {
		if (isId) {
			return false;
		} 
		return nullable;
	}
	
	public function equals(other:DbFieldInfo) : Bool {
		return ((other.length == this.length || this.length == -1 || other.length == -1) &&
			other.dbtype == this.dbtype &&
			other.isNullable() == this.isNullable());
	}
}
