/**
 * ...
 * @author ...
 */

package hails.ext.text;
//import haxe.io.StringInput;

class StringReader //extends StringInput
{

	var data:String;
	var len:Int;
	var pos:Int;
	public function new(s : String) 
	{
		data = s;
		len = s.length;
		pos = 0;
	}

	public function current() : String {
		return data.charAt(pos);
	}
	
	public function currentIs(s:String) : Bool {
		return current() == s;
	}
	
	public function hasMore() : Bool {
		return pos < len;
	}
	
	static function charIsAnyOf(s:String, ss:Array < String > ) : Bool {
		var it:Iterator<String> = ss.iterator();
		while (it.hasNext()) {
			if (it.next() == s) {
				return true;
			}
		}
		return false;
	}
	
	public function currentIsAnyOf(ss:Array < String > ) : Bool {
		return charIsAnyOf(current(), ss);
	}

	public function nextIsAnyOf(ss:Array < String > ) : Bool {
		return charIsAnyOf(lookahead(), ss);
	}
	
	public function skip(?num:Int) : Bool {
		if (num == null) {
			num = 1;
		}
		pos += num;
		return true;
	}
	
	public function skipBlanks() {
		while (currentIsAnyOf([' ', '\t', '\n', '\r'])) {
			skip();
		}
	}
	
	public function skipLineFeeds() {
		while (currentIsAnyOf(['\n', '\r'])) {
			skip();
		}
	}
	
	public function skipOneBlank() {
		skipLineFeeds();
		if (currentIs(' ')) {
			skip();
		}
	}
	
	public function pop() : String {
		var c = current();
		skip();
		return c;
	}
	
	public function lookahead() : String {
		return data.charAt(pos + 1);
	}
	
	public function lookaheadIs(c : String) {
		return lookahead() == c;
	}
	
	public function lookaheadStartsWith(s : String) {
		return data.substr(pos + 1, s.length) == s;
	}
	
	public function currentStartsWith(s : String) {
		//trace('lookingfor: ' + s + '<br>');
		//trace('current: ' + data.substr(pos, s.length) + '<br>');
		return data.substr(pos, s.length) == s;
	}
	
	public function lookbackEndsWith(s : String) {
		return data.substr(pos - s.length, s.length) == s;
	}
	
	public function readUntilAnyOf(ss:Array < String > ) : String {
		var buf:StringBuf = new StringBuf();
		while (hasMore() && !currentIsAnyOf(ss)) {
			buf.add(pop());
		}
		return buf.toString();
	}
	
	public function readUntil(s:String) : String {
		return readUntilAnyOf([s]);
	}
	
}