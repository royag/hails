package hails.hailsdb.java.drivers ;

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

		try {
			untyped __java__("java.lang.Class.forName(\"com.microsoft.sqlserver.jdbc.SQLServerDriver\");");
			var cnxString = 'jdbc:sqlserver://' + params.host + ':' + Std.string(params.port) + ';databaseName=' + params.database; // $ { params.host } :$ { params.port } / $ { params.database } ';
			var properties = new java.util.Properties();
			properties.put("user", params.user);
			properties.put("password", params.pass);
			var cnx = java.sql.DriverManager.getConnection(cnxString, properties);
			return hails.hailsdb.java.Jdbc.create(cnx);
		} catch (e:Dynamic) {
				trace(e);
			throw e;

			return null;
		}
	}
}