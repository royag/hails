/**
 * ...
 * @author ...
 */

package hails.ext.text;

import hails.ext.text.RtfElem;
import hails.Logger;

class RtfParser extends StringReader
{
	static var BLOCK_START = 1;
	static var BLOCK_END = 2;
	static var TAG = 3;
	static var TEXT = 4;
	static var EOF = 5;
	
	var parsed:Bool;
	var parsedElem:RtfElem;
	public function new(s:String) 
	{
		super(s);
		parsed = false;
	}

	public static var SPECIAL_CHAR_START = '\'';	
	
	function readUntilNext() : String {
		return readUntilAnyOf(['{','}','\\',' ','\n','\r']);
	}

	function readUntilNextExceptBlank() : String {
		return readUntilAnyOf(['{', '}', '\\', '\n', '\r']);
	}
	
	
	function getNextType() {
		if (!hasMore()) {
			return EOF;
		}
		switch(current()) {
			case '{' : return BLOCK_START;
			case '}' : return BLOCK_END;
			case '\\' : return TAG;
			/*case '\n' : {
				skip();
				return getNextType();
			}*/
			default : return TEXT;
		}
	}
	
	function assertAndSkip(c:String) {
		if (c.length == 1) {
			if (!currentIs(c)) {
				throw "Expected " + c + " at pos " + pos;
			}
			skip();
		} else {
			var tmp = data.substr(pos, c.length);
			if (tmp != c) {
				throw "Expected " + c + " at pos " + pos + " but found " + tmp;
			}
			skip(c.length);
		}
	}
	
	public function readPicture() : RtfElem {
		assertAndSkip('\\pict');
		var d2 = data.substr(pos);
		//Logger.logDebug(d2);
		//trace('length:[' + d2.length + ']');
		throw "RTF-dokument kan ikke innholde bilder";
		//trace(d2.length);
		pos += d2.indexOf('}'); // + 1;
		return rtf_metablock(null);		
	}
	
	public function readBlock() : RtfElem {
		//trace("IN READ BLOCK");
		var elems:List<RtfElem> = new List<RtfElem>();
		assertAndSkip('{');
		//skipBlanks();
		var isMetaBlock = false;
		if (currentIs('\\')) {
			if (lookaheadIs('*') ||
				lookaheadIs('f') ||
				lookaheadStartsWith('info') ||
				lookaheadStartsWith('stylesheet')) {
					isMetaBlock = true;
				}
			else if (lookaheadStartsWith('pict')) {
				return readPicture();
			}
				
		}
		
		var nextType:Int;
		var cnt = 0;
		var lastPos = pos;
		var _lastWasMetaBlock = false;
		var lastWasMetaBlock = false;
		var tmp:RtfElem;
		while (true) {
			lastWasMetaBlock = _lastWasMetaBlock;
			_lastWasMetaBlock = false;
			//skipBlanks();
			skipLineFeeds();
			//trace("readBlock:WHILE, cnt="+cnt+" pos="+pos+": "+current() + lookahead() +"<br>");
			cnt += 1;
			nextType = getNextType();
			//trace(nextType);
			switch (nextType) {
				case BLOCK_START : {
					//trace("BLOCKSTART<br>");
					tmp = readBlock();
					elems.add(tmp);
					switch (tmp) {
						case rtf_metablock(elems) : { _lastWasMetaBlock = true; }
						default : {}
					}
				}
				case BLOCK_END : {
					//trace("BLOCKEND<br>");
					skip();
					//skipOneBlank();
					if (isMetaBlock) {
						return rtf_metablock(elems);
					}
					return rtf_block(elems);
				}
				case TAG : {
					tmp = readTag();
					elems.add(tmp);
					switch (tmp) {
						case rtf_tag(tag) : { 
							if (tag == 'par') {
								if (lookbackEndsWith('\n\\par') ||
									lookbackEndsWith('\r\\par') ||
									currentIs('\n') || currentIs('\r')) {
										elems.add(rtf_text('\n')); // NewLine
									}
							}
						}
						default : {}
					}
					if (! StringTools.startsWith(lastReadTag, SPECIAL_CHAR_START)) {
						skipOneBlank(); // Blanks(); // OneBlank();
					}
				}
				case TEXT : {
					if (lastWasMetaBlock) {
						elems.add(readTextAfterMeta());
					} else {
						elems.add(readText());
					}
				}
				case EOF : return null; // throw "END OF FILE reached";
				default : throw "Unknown type: " + nextType + " at pos " + pos;
			}
			if (pos == lastPos) {
				throw "Parse-Error: Possible Infinite loop detected at pos " + pos + ": " + 
					data.substr(pos-10,10) + '|HERE|' + data.substr(pos,10);
			}
			lastPos = pos;
		}
		throw "true is not false";
	}
	
	public function readText() : RtfElem {
		var s = readUntilNextExceptBlank();
		//trace("text: " + s + "<br>");
		return rtf_text(s);
	}

	public function readTextAfterMeta() : RtfElem {
		var s = readUntilNextExceptBlank();
		//trace("text: " + s + "<br>");
		return rtf_text_after_meta(s);
	}

	var lastReadTag:String; // = null;
	
	public function readTag() : RtfElem {
		assertAndSkip('\\');
		if (currentIs('\\')) {
			// this is an escaped "\"
			skip();
			return rtf_text('\\');
		}
		lastReadTag = readUntilNext();
		//trace("tag: " + s + "<br>");
		return rtf_tag(lastReadTag);
	}
	
	public function parse() {
		//return "";
		parsedElem = readBlock();
		parsed = true;
	}
	
	public function getParsedElement() : RtfElem {
		return parsedElem;
	}
	
}