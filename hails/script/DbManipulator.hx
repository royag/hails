/**
* ...
* @author Default
*/

package hails.script;

import hails.config.DatabaseConfig;
import sys.db.Connection;
import sys.db.ResultSet;
import hails.HailsDbRecord;
//import php.Exception;
#if neko
import neko.Lib;
#end
import hails.platform.Platform;


class DbManipulator {

	static function tName(name:String) : String {
		if (DatabaseConfig.getType() == "sqlserver") {
			return "[" + name + "]";
		}
		return name;
	}
	
	static function isMysql() {
		return DatabaseConfig.getType() == "mysql";
	}
	
	static function isSqlServer() {
		return DatabaseConfig.getType() == "sqlserver";
	}
	
	public static function output(msg:String) {
		Platform.println(msg);
	}
	
	static function modifyColumnStmt() {
		if (isSqlServer()) {
			return "ALTER COLUMN";
		}
		return "MODIFY COLUMN";
	}	
	
	static function modifyColumn(tableName:String, colName:String, desc:DbFieldInfo) {
		runSql("ALTER TABLE " + tName(tableName) + " "+modifyColumnStmt()+" " + colName + " " + desc.toColumnDefinition());
	}
	
	static function addColumnStmt() {
		if (isSqlServer()) {
			return "ADD";
		}
		return "ADD COLUMN";
	}
	
	static function addColumn(tableName:String, colName:String, desc:DbFieldInfo) {
		var sql = "ALTER TABLE " + tName(tableName) + " "+addColumnStmt()+" " + colName + " " + desc.toColumnDefinition();
		runSql(sql);
	}
	
	static function removeColumn(tableName:String, colName:String) {
		runSql("ALTER TABLE " + tName(tableName) + " DROP COLUMN " + colName);
	}
	
	static function createTable(tableName:String, fieldTypeHash:Map < String, DbFieldInfo > ) {
		var sql = "CREATE TABLE " + tName(tableName) + " (";
		var first = true;
		for (key in fieldTypeHash.keys()) {
			if (!first) {
				sql += ",";
			}
			sql += key + " " + fieldTypeHash.get(key).toColumnDefinition();
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
		var sql = "SHOW TABLES";
		var field = "Tables_in_" + DatabaseConfig.getDatabase();
		if (isSqlServer()) {
			sql = "SELECT * FROM information_schema.tables where table_catalog = '" + DatabaseConfig.getDatabase() + "'";
			field = "TABLE_NAME";
		}
		var res:ResultSet = runSql(sql);
		var ret:List<String> = new List<String>();
		while (res.hasNext()) {
			var f = res.next();
			var tableName:String = Reflect.field(f, field);
			ret.add(tableName);
		}
		return ret;
	}
	
	static function getFieldsFrom(table:String) : Map < String, DbFieldInfo > {
		var sql = "SHOW FIELDS FROM " + table;
		var field = "Field";
		if (isSqlServer()) {
			sql = "SELECT * FROM information_schema.columns where table_catalog = '" + DatabaseConfig.getDatabase() + 
			"' and table_name = '" + table + "'";
			field = "COLUMN_NAME";
		}		
		var res:ResultSet = runSql(sql);
		var ret = new Map < String, DbFieldInfo >();
		while (res.hasNext()) {
			var f = res.next();
			//trace(f);
			var fieldName:String = Reflect.field(f, field);
			ret.set(fieldName, DbFieldInfo.createFromServerDescription(f));
			//Lib.println(fieldName + " -> " + fieldType);
		}
		return ret;
	}
	
	
}