package hails.ext.net.java;

import hails.ext.net.SimpleHttpRequestor;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.lang.Exception;
import java.lang.RuntimeException;
import java.net.URL;


class JavaSimpleHttpRequestor extends SimpleHttpRequestor
{
	
	public override function get(urlToRead:String) : String {
        var line:String;
        var result = "";
		var conn:HttpURLConnection;
        try {
            var url = new URL(urlToRead);
            conn = cast(url.openConnection());
            conn.setRequestMethod("GET");
            var rd = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            while ((line = rd.readLine()) != null) {
                result += line;
            }
            rd.close();
        } catch (e:IOException) {
            throw new RuntimeException(e);//e.printStackTrace();
        } catch (e:Exception) {
			throw new RuntimeException(e);
            //e.printStackTrace();
        }
        return result;
	}
	
}