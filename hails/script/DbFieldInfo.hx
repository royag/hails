/**
* ...
* @author Default
*/

package hails.script;

import php.Exception;

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
	
	public function toMysqlColumnDefinition() : String {
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
	
	// varchar(10)
	public static function findLengthOfMysqlType(t:String) : Int {
		var start = t.indexOf("(");
		if (start < 0) {
			return -1;
		}
		var end = t.indexOf(")");
		var len:Int = Std.parseInt(t.substr(start + 1, end - start - 1));
		if (len == null) {
			throw new Exception("Could not parse int: " + t.substr(start + 1, end - start));
			//return -1;
		}
		return len;
		
	}
	public static function createFromMysqlDescription(desc:Dynamic) : DbFieldInfo {
		//var fieldName:String = Reflect.field(f, "Field");
		var mysqlType:String = Reflect.field(desc, "Type");
		var nullable:String = Reflect.field(desc, "Null"); // "YES" or "NO"
		var defaultVal:String = Reflect.field(desc, "Type"); // null		
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
			throw new Exception("unknown databasetype: " + mysqlType);
		}
		var t = new DbFieldInfo(dbtype);
		t.length = findLengthOfMysqlType(mysqlType);
		t.nullable = nullable == "YES";
		return t;
	}
	
	public static function createFromHaxeTypeName(typeName:String, ?annot:String) {
		var t:DbFieldType;
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
					}
				} 
			}
			case "Bool" : t = dbBoolean;
			case "Float" : t = dbFloat;
			case "Date" : t = dbDatetime;
			default : throw new Exception("Unknown typeName: " + typeName);
		}
		return new DbFieldInfo(t);
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
