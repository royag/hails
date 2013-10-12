/**
 * ...
 * @author ...
 */

package hails.ext.text;

import hails.HailsDbRecord;

class RtfConverter 
{
	var data:RtfElem;
	var out:IDocumentWriter;
	
	public function new(elem:RtfElem, out:IDocumentWriter) 
	{
		this.data = elem;
		this.out = out;
	}
	
	public static function rtfToHtml(rawRtf:String) : String {
		var p = new RtfParser(rawRtf);
		p.parse();
		var writer = new HtmlWriter();
		var conv = new RtfConverter(p.getParsedElement(), writer);
		conv.parse();
		return writer.toString();
	}
	
	public static function rtfToHWiki(rawRtf:Blob) : String {
		var p = new RtfParser(Std.string(rawRtf));
		p.parse();
		var writer = new HWikiWriter();
		var conv = new RtfConverter(p.getParsedElement(), writer);
		conv.parse();
		return writer.toString();
	}

	public static function rtfElemToString(elem:RtfElem) : String {
		if (elem == null) {
			return "NULL";
		}
		switch (elem) {
			case rtf_block(block) : {
				var it = block.iterator();
				var s = 'rtf_block(';
				while (it.hasNext()) {
					s += rtfElemToString(it.next()) + ",";
				}
				s += ')';
				return s;
			}
			case rtf_tag(tag) : return 'rtf_tag(' + tag + ')';
			case rtf_text(txt) : return 'rtf_text(' + txt + ')';
			default : return Std.string(elem);
		}
	}	
	/*public static function fromRawRtf(data:String) : RtfConverter {
		var p = new RtfParser(data);
		p.parse();
		var elem = p.getParsedElement();
		return new RtfConverter(elem);
	}*/
	
	static var TROWD = 'trowd'; // Start of row-def
	static var CELL = 'cell';
	static var PAR = 'par';
	static var ROW = 'row';
	static var LASTROW = 'lastrow';
	static var TAB = 'tab';
	
	static var FCHARSET0 = 'fcharset0';
	static var COLORTBL = 'colortbl';
	static var GENERATOR = 'generator';   //  {\*\generator Msftedit 5.41.21.2508;}
	
	static var TEXT_BOLD = 'b';
	static var TEXT_BOLD_OFF = 'b0';
	static var TEXT_ITALIC = 'i';
	static var TEXT_ITALIC_OFF = 'i0';
	static var TEXT_UNDERLINE = 'ul';
	static var TEXT_UNDERLINE_OFF = 'ulnone';
	
	static var SPECIAL_CHAR_START = RtfParser.SPECIAL_CHAR_START; // '\'';
	
	public static var SPECIAL_STARDOT = 'b7';
	public static var SPECIAL_AE = 'e6';
	public static var SPECIAL_OE = 'f8';
	public static var SPECIAL_AA = 'e5';
	public static var SPECIAL_AE_CAP = 'c6';
	public static var SPECIAL_OE_CAP = 'd8';
	public static var SPECIAL_AA_CAP = 'c5';
	
	var tableElem:RtfElem; // = null;
	var inCell:Bool; // = false;
	var inRow:Bool; // = true;
	function parseTableBegins(it:Iterator < RtfElem > ) : Void {
		tableElem = null;
		inCell = false;
		out.tableBegin("border=1 width=80%");
		out.tableRowBegin();
		inRow = true;
		out.paragraphBegin();
		parseTableElem(it);
	}

	function doTableEnd() {
		if (inCell) {
			out.tableCellEnd();
		}
		if (inRow) {
			out.tableRowEnd();
		}
		out.tableEnd();
		inCell = false;
		inRow = false;
	}
	
	function resetFormatting() {
		if (isBold) { out.boldEnd(); isBold = false; }
		if (isItalic) { out.italicEnd(); isItalic = false;  }
		if (isUnderline) { out.underlineEnd(); isUnderline = false;  }
	}
	
	/**
	 * 
	 * @param	it
	 * @return true if table is at end
	 */
	function parseTableElem(it:Iterator < RtfElem > ) : Bool {
		resetFormatting();
		while (it.hasNext()) {
			//trace("ParseTable:NEXT<br>");
			var atEnd:Bool = false;
			tableElem = it.next();
			switch (tableElem) {
				case rtf_text(text) : {
					if (!inRow) {
						//tableRowBegin();
						//inRow = true;
						doTableEnd();
						out.textElement(text);
						return true;
					}
					if (!inCell) {
						//trace("TEXT_NOT_IN_CELL<br>");
						out.tableCellBegin();
						inCell = true;
					}
					//trace("TEXT:"+text+"<br>");
					out.textElement(text);
				}
				case rtf_tag(tag) : {
					if (tag == CELL)  {
							//trace("CELL,inCell=" + inCell + "<br>");
							if (!inRow) {
								out.tableRowBegin();
								inRow = true;
							}
							if (!inCell) {
								//trace("CELL begin<br>");
								out.tableCellBegin();
							}
							//trace("CELL end<br>");
							//resetFormatting();
							out.tableCellEnd();
							inCell = false;
						}
						else if (tag == ROW ) {
							//trace("ROW<br>");
							//trace("ROW end<br>");
							out.tableRowEnd();
							inRow = false;
						}
						else if (tag == TROWD || tag == 'ltrrow')  {
							//trace("ROW begin<br>");
							if (!inRow) {
								out.tableRowBegin();
								inRow = true;
							}
						}
						/*case PAR : {
							doTableEnd();
							return true;
						}*/
						else if (tag == LASTROW) {
							doTableEnd();
							return true;
						}
						else {
							/*if (StringTools.startsWith(tag, SPECIAL_CHAR_START)) {
								specialChar(tag.substr(1));
							}*/
							handleTag(tag);
						}						
					//}
				}
				case rtf_block(block) : {
					//trace(block);
					// could be a block having the \cell tags
					// or could be a block having the \row tag (after cells)
					//parseBlock(block);
					if (parseTableElem(block.iterator())) {
						return true;
					}
				}
				case rtf_metablock(block) : { }; // ignore
				case rtf_text_after_meta(txt) : { }; // ignore
			}
		}
		/*if (inCell) {
			tableCellEnd();
		}
		inCell = false;*/
		return false;
	}
	

	function parse() {
		switch (data) {
			case rtf_block(elems) : parseBlock(elems);
			default : throw "Expected rtf_block";
		}
	}

	var isBold : Bool; // = false;
	var isItalic : Bool; // = false;
	var isUnderline : Bool; // = false;
	
	function handleTag(tag:String) {
		if (tag == TEXT_BOLD ) {
				if (!isBold) {
					out.boldBegin();
					isBold = true;
				}
			}
		else if (tag == TEXT_BOLD_OFF ) {
				if (isBold) {
					out.boldEnd();
					isBold = false;
				}
			}
			else if (tag ==  TEXT_ITALIC ) {
				if (!isItalic) {
					out.italicBegin();
					isItalic = true;
				}
			}
			else if (tag ==  TEXT_ITALIC_OFF ) {
				if (isItalic) {
					out.italicEnd();
					isItalic = false;
				}
			}
			else if (tag ==  TEXT_UNDERLINE ) {
				if (!isUnderline) {
					out.underlineBegin();
					isUnderline = true;
				}
			}
			else if (tag ==  TEXT_UNDERLINE_OFF ) {
				if (isUnderline) {
					out.underlineEnd();
					isUnderline = false;
				}
			}
			else if (tag ==  TAB ) {
				out.textElement(' ');
			}
			else {
				if (StringTools.startsWith(tag, SPECIAL_CHAR_START)) {
					out.specialChar(tag.substr(1));
				}
			}
		//}		
	}
	
	
	function parseBlock(elems : List < RtfElem > ) : Void {
		resetFormatting();
		isBold = false;
		isItalic = false;
		isUnderline = false;
		var it:Iterator<RtfElem> = elems.iterator();
		var elem:RtfElem;
		var skipNextText:Bool = false;
		var lastTag:String = null;
		//paragraphBegin();
		var inPara:Bool = true;
		while (it.hasNext()) {
			//trace("ParseBlock:NEXT<br>");
			elem = it.next();
			switch (elem) {
				case rtf_text(text) : {
					if (!skipNextText) {
						out.textElement(text);
					} else {
						skipNextText = false;
					}
				}
				case rtf_tag(tag) : {
					//switch (tag) {
						/*case TEXT_BOLD : {
							boldBegin();
							isBold = true;
						}
						case TEXT_BOLD_OFF : {
							boldEnd();
							isBold = false;
						}
						case TEXT_ITALIC : {
							italicBegin();
							isItalic = true;
						}
						case TEXT_ITALIC_OFF : {
							italicEnd();
							isItalic = false;
						}
						case TEXT_UNDERLINE : {
							underlineBegin();
							isUnderline = true;
						}
						case TEXT_UNDERLINE_OFF : {
							underlineEnd();
							isUnderline = false;
						}*/
						if (tag == TROWD ) {
							parseTableBegins(it);
						}
						else if (tag == PAR ) {
							//paragraphEnd();
							inPara = false;
							//paragraphBegin();
							inPara = true;
						}
						else if ((tag == FCHARSET0) || (tag == COLORTBL) || (tag == GENERATOR)) {
							skipNextText = true;
						}else {
							/*if (StringTools.startsWith(tag, SPECIAL_CHAR_START)) {
								specialChar(tag.substr(1));
							}*/
							handleTag(tag);
						}
					//}
					lastTag = tag;
				}
				case rtf_block(block) : parseBlock(block); // buf.add(parseBlock(block));
				case rtf_metablock(block) : { }; // ignore
				case rtf_text_after_meta(txt) : { }; // ignore
			}
		}	
		/*if (isBold) { boldEnd(); isBold}
		if (isItalic) { italicEnd(); }
		if (isUnderline) { underlineEnd(); }*/
		resetFormatting();
		//if (inPara) { paragraphEnd(); } 
		
	}
	
}