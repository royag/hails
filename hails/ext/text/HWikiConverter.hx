/**
 * ...
 * @author ...
 */

package hails.ext.text;
import hails.Logger;

class HWikiConverter extends StringReader
{
	/*
	 
{| 
|+ caption 
|- 
| navn | addresse | telefon 
|- 
| roy | drammen | 95875480 
|- 
| sdfsdf | sdfsdfsd | zsdfsdf 
|}
	
	 */
	var out:IDocumentWriter;
	
	var globalTableNo:Int;
	var editMode:Bool;
	
	public var articleUrlCreator:String -> String;
	
	public function new(hwikidata:String, writer:IDocumentWriter, ?editMode) 
	{
		super(hwikidata);
		this.editMode = (editMode != null) && editMode;
		out = writer;
		globalTableNo = 0;
	}
	
	public static function hwikiToHtml(hwikidata : String, 
			?imageUrlCreator:String -> String,
			?articleUrlCreator:String->String) : String {
		var writer = new HtmlWriter(imageUrlCreator);
		var c:HWikiConverter = new HWikiConverter(hwikidata, writer);
		c.articleUrlCreator = articleUrlCreator;
		c.parse();
		return writer.toString();
	}
	
	
	public function reset() {
		pos = 0;
	}
	
	var isBold:Bool;
	var isItalic:Bool;
	var isUnderline:Bool;
	var isH1:Bool;
	var isH2:Bool;
	var isH3:Bool;
	
	function resetFormatVars() {
		isBold = false;
		isItalic = false;
		isUnderline = false;
		isH1 = false;
		isH2 = false;
		isH3 = false;
	}
	
	function findAndSkip(mark:String) : Bool {
		return (currentStartsWith(mark) ?
			(skip(mark.length) && true) : false);
	}
	
	public function parse() {
		var inOrderedList = false;
		var inUnorderedList = false;
		var inListElement = false;
		var nextOrderedListPoint = 1;
		resetFormatVars();
		var txt:String;
		var lastPos = pos;
		while (hasMore()) {
			if (findAndSkip(HWikiDefs.MARK_HEADER_1)) {
				(isH1 ? out.header1End() : out.header1Begin());
				isH1 = !isH1;
			} else if (findAndSkip(HWikiDefs.MARK_HEADER_2)) {
				(isH2 ? out.header2End() : out.header2Begin());
				isH2 = !isH2;
			} else if (findAndSkip(HWikiDefs.MARK_HEADER_3)) {
				(isH3 ? out.header3End() : out.header3Begin());
				isH3 = !isH3;
			} else if (findAndSkip(HWikiDefs.MARK_BOLD)) {
				(isBold ? out.boldEnd() : out.boldBegin());
				isBold = !isBold;
			} else if (findAndSkip(HWikiDefs.MARK_ITALIC)) {
				(isItalic ? out.italicEnd() : out.italicBegin());
				isItalic = !isItalic;
			} else if (findAndSkip(HWikiDefs.MARK_UNDERLINE)) {
				(isUnderline ? out.underlineEnd() : out.underlineBegin());
				isUnderline = !isUnderline;
			} else if (findAndSkip(HWikiDefs.IMAGE_FUNC)) {
				readImage();
			} else if (findAndSkip(HWikiDefs.LINK_FUNC)) {
				readLink();
			} else if (findAndSkip(HWikiDefs.FILELINK_FUNC)) {
				readFilelink();
			} else if (findAndSkip(HWikiDefs.ARTICLELINK_FUNC)) {
				readArticlelink();
			} else if (findAndSkip(HWikiDefs.TABLE_START)) {
				readTable();
			} else if (findAndSkip(HWikiDefs.UNORDERED_LIST_DOT_START) ||
						findAndSkip(HWikiDefs.UNORDERED_LIST_LINE_START)) {
				if (!inUnorderedList) {
					out.unorderedListStart();
					out.listElementStart();
					inUnorderedList = true;
					inListElement = true;
				} else {
					// allready in list
					out.listElementEnd();
					out.listElementStart();
				}
			} else if (findAndSkip(HWikiDefs.ORDERED_LIST_ELEMENT_START(nextOrderedListPoint))) {
				if (!inOrderedList) {
					out.orderedListStart();
					out.listElementStart();
					inOrderedList = true;
					inListElement = true;
				} else {
					// allready in list
					out.listElementEnd();
					out.listElementStart();
				}
				nextOrderedListPoint += 1;
			} else if (currentIs(HWikiDefs.LINE_FEED) && (inUnorderedList || inOrderedList)) {
				if (inUnorderedList) {
					out.listElementEnd();
					out.unorderedListEnd();
					inUnorderedList = false;
					inListElement = false;
					pop();
					//break;
				}
				if (inOrderedList) {
					out.listElementEnd();
					out.orderedListEnd();
					inOrderedList = false;
					inListElement = false;
					nextOrderedListPoint = 1;
					pop();
					//break;
				}
			} else {
				// we can't write characters one-by-one,
				// since special-norwegian-chars are actually 2 chars,
				// meaning the textElement() method then won't be able to handle/convert them.
				txt = readUntilAnyOf([
					HWikiDefs.MARK_HEADER_1.charAt(0),
					HWikiDefs.MARK_BOLD.charAt(0),
					HWikiDefs.MARK_ITALIC.charAt(0),
					HWikiDefs.MARK_UNDERLINE.charAt(0),
					HWikiDefs.TABLE_START.charAt(0),
					HWikiDefs.IMAGE_FUNC.charAt(0),
					HWikiDefs.LINE_FEED]);
				if (txt == null || txt.length == 0) {
					// don't want no infinite loop ... so pop'n'put:
					out.textElement(pop());
				} else {
					out.textElement(txt);
				}
			}
			if (pos == lastPos) {
				throw "Infine loop"; // while under development .. TODO : remove!
				Logger.logError("Parse-Error: Possible Infinite loop detected at pos " + pos + ": " + 
					data.substr(pos - 10, 10) + '|HERE|' + data.substr(pos, 10) + ". Skipping one character...");
				skip();
			}
			lastPos = pos;
		}
	}
	
	function readLink() : Void {
		skipBlanks();
		if (currentIs('(')) {
			skip();
			skipBlanks();
			var url:String = readUntilAnyOf([',', ')']);
			if (currentIs(',')) {
				skip();
				skipBlanks();
				var content = readUntil(')');
				skip();
				out.link(url, content);
			} else {
				skip();
				out.link(url, url);
			}
		}
	}
	
	function readFilelink() : Void {
		skipBlanks();
		if (currentIs('(')) {
			skip();
			skipBlanks();
			var idOrName = readUntilAnyOf([',', ')']);
			if (currentIs(',')) {
				skip();
				skipBlanks();
				var content = readUntil(')');
				skip();
				out.filelink(idOrName, content);
			} else {
				skip();
				out.filelink(idOrName, idOrName);
			}
		}
	}

	function readArticlelink() : Void {
		skipBlanks();
		if (currentIs('(')) {
			skip();
			skipBlanks();
			var id = readUntilAnyOf([',', ')']);
			var url = "";
			if (articleUrlCreator == null) {
				url = "articleUrlCreatorNotSet";
			} else {
				url = articleUrlCreator(id);
			}
			if (currentIs(',')) {
				skip();
				skipBlanks();
				var content = readUntil(')');
				skip();
				out.link(url, content);
			} else {
				skip();
				out.link(url, url);
			}
		}
	}
	
	
	function readImage() : Void {
		// IMAGE_FUNC ("$pic") has already been read.
		skipBlanks();
		if (currentIs('(')) {
			skip();
			var imgId = readUntilAnyOf([',', ')', ' ']);
			skipBlanks();
			var width:String = null;
			var height:String = null;
			var customOptions:String = null;
			if (currentIs(',')) {
				skip();
				skipBlanks();
				width = readUntilAnyOf([',', ')', ' ']);
				skipBlanks();
				if (currentIs(',')) {
					skip();
					skipBlanks();
					height = readUntilAnyOf([',', ')', ' ']);
					skipBlanks();
				}
			}
			skipBlanks();
			if (currentIs(',')) {
				skip();
				customOptions = readUntil(')');
			}
			skip(); // assume ")"
			out.image(imgId, { width:width, height:height, customOptions:customOptions } );
		}
	}
	

	function idForTableCell(tableNo:Int, rowNo:Int, cellNo:Int) {
		return 'td_' + tableNo + '_' + rowNo + '_' + cellNo;
	}
	
	function optionsForTableCell(tableNo:Int, rowNo:Int, cellNo:Int) {
		var id:String = idForTableCell(tableNo, rowNo, cellNo);
		var ret = 'id=' + id;
		if (editMode) {
			ret += " onclick='javascript:alert(\""+id+"\")'";
		}
		//trace(ret);
		return ret;
	}
	
	function readTable() : Void {
		globalTableNo += 1;
		var tableNo = globalTableNo;
		var rowNo = 0;
		var cellNo = 0;
		// TABLE_START "{|\n" is allready read.
		var options:String = readUntil('|');
		var inRow = false;
		var inCell = false;
		var txt:String;
		var tmpConverter:HWikiConverter;
		skipBlanks();
		if (findAndSkip(HWikiDefs.TABLE_CAPTION_START)) {
			// caption... TODO
			//readUntil(HWikiDefs.TABLE_CAPTION_END);
			//skip(HWikiDefs.TABLE_CAPTION_END.length);
			txt = readUntil('|'); // caption
			skipBlanks();
		}
		out.tableBegin(options);
		var lastPos = pos;
		while (hasMore()) {
			skipBlanks();
			if (findAndSkip(HWikiDefs.TABLE_ROW_START)) {
				if (inCell) { out.tableCellEnd();  }
				if (inRow) { out.tableRowEnd();  }
				inRow = true;
				rowNo += 1;
				cellNo = 0;
				out.tableRowBegin();
			} else if (findAndSkip(HWikiDefs.TABLE_END)) {
				if (inCell) { out.tableCellEnd();  }
				if (inRow) { out.tableRowEnd();  }
				out.tableEnd();
				return;
			} else if (findAndSkip(HWikiDefs.TABLE_CELL_START)) {
				cellNo += 1;
				if (inCell) { out.tableCellEnd(); }
				inCell = true;
				out.tableCellBegin(optionsForTableCell(tableNo, rowNo, cellNo));
			} else if (findAndSkip(HWikiDefs.TABLE_START)) {
				//trace("NESTED TABLE");
				readTable();
			} else {
				txt = pop() + readUntilAnyOf(['|', '{']);   // the pop() is there to avoid infinite loop on '{'
				tmpConverter = new HWikiConverter(txt, out);
				tmpConverter.articleUrlCreator = articleUrlCreator;
				tmpConverter.parse();
			}
			if (pos == lastPos) {
				Logger.logError("Parse-Error: Possible Infinite loop detected at pos " + pos + ": " + 
					data.substr(pos - 10, 10) + '|HERE|' + data.substr(pos, 10) + ". Skipping one character...");
				skip();
			}
			lastPos = pos;
		}
	}
}