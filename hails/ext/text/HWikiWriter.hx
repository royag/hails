/**
 * ...
 * @author ...
 */

package hails.ext.text;

class HWikiWriter implements IDocumentWriter
{
	var buf:StringBuf; // = new StringBuf();
	
	public function new() 
	{
		this.buf = new StringBuf();
	}
	
	public function tableBegin(?options:String) {
		buf.add(HWikiDefs.TABLE_START +(options != null ? StringTools.trim(options) : '')+ '\n');
	}
	
	public function image(nameOrId:String, ?options:Dynamic) {
		
	}
	
	public function link(url:String, content:String) : Void {}
	
	public function filelink(nameOrId:String, content:String) : Void {}
	
	
	public function tableRowBegin() {	buf.add(HWikiDefs.TABLE_ROW_START + '\n'); }
	
	public function tableRowEnd() { buf.add('\n'); }
	
	public function tableCellBegin(?options:String) { buf.add(HWikiDefs.TABLE_CELL_START); }
	
	public function tableCellEnd() { }
	
	public function tableEnd() { buf.add(HWikiDefs.TABLE_END + '\n');	}
	
	public function textElement(text:String) { 
		buf.add(text);
	}
	
	public function boldBegin() { buf.add(HWikiDefs.MARK_BOLD); }
	
	public function boldEnd() { buf.add(HWikiDefs.MARK_BOLD); }

	public function italicBegin() { buf.add(HWikiDefs.MARK_ITALIC); }
	
	public function italicEnd() { buf.add(HWikiDefs.MARK_ITALIC); }

	public function underlineBegin() {	buf.add(HWikiDefs.MARK_UNDERLINE); }
	
	public function underlineEnd() { buf.add(HWikiDefs.MARK_UNDERLINE); }
	
	public function paragraphBegin() { buf.add('\n');  }
	
	public function paragraphEnd() { buf.add('\n'); }
	
	public function header1Begin() : Void { buf.add(HWikiDefs.MARK_HEADER_1); }
	public function header1End() : Void { buf.add(HWikiDefs.MARK_HEADER_1); }
	public function header2Begin() : Void { buf.add(HWikiDefs.MARK_HEADER_2); }
	public function header2End() : Void { buf.add(HWikiDefs.MARK_HEADER_2); }
	public function header3Begin() : Void { buf.add(HWikiDefs.MARK_HEADER_3); }
	public function header3End() : Void { buf.add(HWikiDefs.MARK_HEADER_3); }
	
	// Not too good... no support for ordered list:
	public function orderedListStart() : Void { }
	public function orderedListEnd() : Void { buf.add(HWikiDefs.LINE_FEED); }
	public function unorderedListStart() : Void { }
	public function unorderedListEnd() : Void { buf.add(HWikiDefs.LINE_FEED); }
	public function listElementStart() : Void { buf.add(HWikiDefs.UNORDERED_LIST_DOT_START); }
	public function listElementEnd() : Void { }
	
	
	public function specialChar(code:String) { 
		switch(code) {
			case RtfConverter.SPECIAL_AE : buf.add('æ');
			case RtfConverter.SPECIAL_OE : buf.add('ø');
			case RtfConverter.SPECIAL_AA : buf.add('å');
			case RtfConverter.SPECIAL_AE_CAP : buf.add('Æ');
			case RtfConverter.SPECIAL_OE_CAP : buf.add('Ø');
			case RtfConverter.SPECIAL_AA_CAP : buf.add('Å');
			case RtfConverter.SPECIAL_STARDOT : { buf.add('*');  } ;
		}
	}

	public function toString() : String {
		return buf.toString();
	}
}