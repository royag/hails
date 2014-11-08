package hails.hailsdb.java.drivers ;

class Sqlite
{
	public static function open ( file:String ) : sys.db.Connection {
		try
		{
			untyped __java__("java.lang.Class.forName(\"org.sqlite.JDBC\");");
			var cnxString = 'jdbc:sqlite:' + file;
			var cnx = java.sql.DriverManager.getConnection(cnxString);
			return hails.hailsdb.java.Jdbc.create(cnx);
			return null;
		} catch(e:Dynamic) throw e;
	}
}