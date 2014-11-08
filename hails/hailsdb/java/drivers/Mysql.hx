package hails.hailsdb.java.drivers ;
 
class Mysql {
	public static function connect( params : {
		host : String,
		?port : Int,
		user : String,
		pass : String,
		?socket : String,
		database : String
	} ) : sys.db.Connection {
		if ( params.port == null ) params.port = 3306;
		try
		{
			untyped __java__("java.lang.Class.forName(\"com.mysql.jdbc.Driver\");");
			var cnxString = 'jdbc:mysql://' + params.host + ':' + Std.string(params.port) + '/' + params.database; // $ { params.host } :$ { params.port } / $ { params.database } ';
			var properties = new java.util.Properties();
			properties.put("user", params.user);
			properties.put("password", params.pass);
			var cnx = java.sql.DriverManager.getConnection(cnxString, properties);
			return hails.hailsdb.java.Jdbc.create(cnx);
			return null;
		} catch(e:Dynamic) throw e;
	}
}