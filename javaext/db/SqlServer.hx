package javaext.db;

/**
 * ...
 * @author Roy
 */
class SqlServer
{

public static function connect( params : {
	host : String,
	?port : Int,
	user : String,
	pass : String,
	?socket : String,
	database : String
} ) : sys.db.Connection {
if ( params.port == null ) params.port = 1433;

try
{//Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
	untyped __java__("java.lang.Class.forName(\"com.microsoft.sqlserver.jdbc.SQLServerDriver\");");
	//trace("connect!!!!!");
//java.lang.Class.forName("com.mysql.jdbc.Driver");
//untyped __java__("java.lang.Class.forName(\"com.mysql.jdbc.Driver\");");
//var tmp = java.lang.Class.forName("com.mysql.jdbc.Driver");
var cnxString = 'jdbc:sqlserver://' + params.host + ':' + Std.string(params.port) + ';databaseName=' + params.database; // $ { params.host } :$ { params.port } / $ { params.database } ';
var properties = new java.util.Properties();
properties.put("user", params.user);
properties.put("password", params.pass);
//trace("establish conn");
var cnx = java.sql.DriverManager.getConnection(cnxString, properties);
//trace("connection=" + cnx);
return java.db.Jdbc.create(cnx);
} catch (e:Dynamic) {
		trace(e);
	throw e;

	return null;
}
 
	
}
}