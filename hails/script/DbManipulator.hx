/**
* ...
* @author Default
*/

package hails.script;

import config.DatabaseConfig;
import sys.db.Connection;
import sys.db.ResultSet;
import hails.HailsDbRecord;
//import php.Exception;
import neko.Lib;


class DbManipulator {

	public static function output(msg:String) {
		Lib.println(msg);
	}
	
	static function modifyColumn(tableName:String, colName:String, desc:DbFieldInfo) {
		runSql("ALTER TABLE " + tableName + " MODIFY COLUMN " + colName + " " + desc.toMysqlColumnDefinition());
	}
	
	static function addColumn(tableName:String, colName:String, desc:DbFieldInfo) {
		var sql = "ALTER TABLE " + tableName + " ADD COLUMN " + colName + " " + desc.toMysqlColumnDefinition();
		runSql(sql);
	}
	
	static function removeColumn(tableName:String, colName:String) {
		runSql("ALTER TABLE " + tableName + " DROP COLUMN " + colName);
	}
	
	static function createTable(tableName:String, fieldTypeHash:Map < String, DbFieldInfo > ) {
		var sql = "CREATE TABLE " + tableName + " (";
		var first = true;
		for (key in fieldTypeHash.keys()) {
			if (!first) {
				sql += ",";
			}
			sql += key + " " + fieldTypeHash.get(key).toMysqlColumnDefinition();
			first = false;
		}
		sql += ")";
		runSql(sql);
	}
	
	static var connection:Connection;
	static function runSql(sql:String) {
		return HailsDbRecord.runSql(sql, connection);
	}
	
	public static function createOrAlterTable(tableName:String, fieldTypeHash:Map < String, DbFieldInfo > ) : Void {
		connection = HailsDbRecord.createConnection();
		try {
			if (getTables().filter(function(s:String) { 
					return s.toLowerCase() == tableName.toLowerCase(); 
				} ).isEmpty()) {
				// table doesnt exist
				output("Creating table " + tableName);
				createTable(tableName, fieldTypeHash);
			} else {
				var actualFields = getFieldsFrom(tableName);
				// First find if any are removed:
				for (key in actualFields.keys()) {
					if (!fieldTypeHash.exists(key)) {
						// remove field
						output("Removing field '" + key + "' from " + tableName);
						removeColumn(tableName, key);
					}
				}
				for (key in fieldTypeHash.keys()) {
					if (!actualFields.exists(key)) {
						// new field
						output("Adding field: '" + key + "' to " + tableName);
						addColumn(tableName, key, fieldTypeHash.get(key));
					} else {
						// existing field.
						if (!actualFields.get(key).equals(fieldTypeHash.get(key))) {
							// field has changed
							output("Modifying column '" + key + "' on " + tableName);
							modifyColumn(tableName, key, fieldTypeHash.get(key));
						}
					}
				}
				//tableName exists;
			}
		} catch (err:Dynamic) {
			connection.close();
			throw err;
		}
	}
	
	static function getTables() : List<String> {
		var res:ResultSet = runSql("SHOW TABLES");
		var ret:List<String> = new List<String>();
		while (res.hasNext()) {
			var f = res.next();
			var tableName:String = Reflect.field(f, "Tables_in_" + DatabaseConfig.database);
			ret.add(tableName);
		}
		return ret;
	}
	
	static function getFieldsFrom(table:String) : Map < String, DbFieldInfo > {
		var res:ResultSet = runSql("SHOW FIELDS FROM " + table);
		var ret = new Map < String, DbFieldInfo >();
		while (res.hasNext()) {
			var f = res.next();
			//trace(f);
			var fieldName:String = Reflect.field(f, "Field");
			ret.set(fieldName, DbFieldInfo.createFromMysqlDescription(f));
			//Lib.println(fieldName + " -> " + fieldType);
		}
		return ret;
	}
	
	
}