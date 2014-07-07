package javaext.db;

/**
 * ...
 * @author Roy
 */
class Sqlite
{
//static var init = false;
 
/**
Opens a new MySQL connection on the specified path.
Note that you will need a MySQL JDBC driver.
"socket" option currently not supported
 
If port is null, 3306 is assumed.
**/
public static function open ( file:String ) : sys.db.Connection {
/*if (!init)
{
try java.lang.Class.forName("org.sqlite.JDBC") catch(e:Dynamic) throw e;
init = true;
}*/
try
{
//java.lang.Class.forName("com.mysql.jdbc.Driver");
untyped __java__("java.lang.Class.forName(\"org.sqlite.JDBC\");");
//var tmp = java.lang.Class.forName("com.mysql.jdbc.Driver");
var cnxString = 'jdbc:sqlite:' + file;
/*var properties = new java.util.Properties();
properties.put("user", params.user);
properties.put("password", params.pass);*/
var cnx = java.sql.DriverManager.getConnection(cnxString);
return java.db.Jdbc.create(cnx);
return null;
} catch(e:Dynamic) throw e;
}
 
}