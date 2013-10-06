package javaext.db;
 
class Mysql {
 
//static var init = false;
 
/**
Opens a new MySQL connection on the specified path.
Note that you will need a MySQL JDBC driver.
"socket" option currently not supported
 
If port is null, 3306 is assumed.
**/
public static function connect( params : {
	host : String,
	?port : Int,
	user : String,
	pass : String,
	?socket : String,
	database : String
} ) : sys.db.Connection {
if ( params.port == null ) params.port = 3306;
/*if (!init)
{
try java.lang.Class.forName("org.sqlite.JDBC") catch(e:Dynamic) throw e;
init = true;
}*/
try
{
//java.lang.Class.forName("com.mysql.jdbc.Driver");
untyped __java__("java.lang.Class.forName(\"com.mysql.jdbc.Driver\");");
//var tmp = java.lang.Class.forName("com.mysql.jdbc.Driver");
var cnxString = 'jdbc:mysql://' + params.host + ':' + Std.string(params.port) + '/' + params.database; // $ { params.host } :$ { params.port } / $ { params.database } ';
var properties = new java.util.Properties();
properties.put("user", params.user);
properties.put("password", params.pass);
var cnx = java.sql.DriverManager.getConnection(cnxString, properties);
return java.db.Jdbc.create(cnx);
return null;
} catch(e:Dynamic) throw e;
}
 
}