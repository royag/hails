/**
 * ...
 * @author ...
 */

package hails.ext.text;

import hails.ext.text.RtfElem;
import hails.html.ViewTool;
//import haxe.Stack;

class HtmlWriter implements IDocumentWriter
{
	var buf:StringBuf; // = new StringBuf();
	var fileUrlCreator:String -> String;
	
	public function new(?fileUrlCreator:String->String) 
	{
		this.buf = new StringBuf();
		this.fileUrlCreator = fileUrlCreator;
	}
	
	public function tableBegin(?options:String) {
		buf.add('\n<TABLE '+(options != null ? StringTools.htmlEscape(StringTools.trim(options)) : '')+'>\n');
	}
	
	public function image(nameOrId:String, ?options:Dynamic) : Void {
		var attrs = '';
		if (Reflect.hasField(options, 'width') && Reflect.field(options, 'width') != null) {
			attrs += ' width=' + Reflect.field(options, 'width');
		}
		if (Reflect.hasField(options, 'height') && Reflect.field(options, 'height') != null) {
			attrs += ' height=' + Reflect.field(options, 'height');
		}
		if (Reflect.hasField(options, 'customOptions') && Reflect.field(options, 'customOptions') != null) {
			attrs += ' ' + StringTools.htmlEscape(Reflect.field(options, 'customOptions'));
		}
		buf.add("<img src='" + 
			(fileUrlCreator == null ? nameOrId : fileUrlCreator(StringTools.urlEncode(nameOrId))) +
			"' "+attrs+" />");
	}
	
	public function link(url:String, content:String) : Void {
		buf.add("<a href='" + StringTools.htmlEscape(url) + "'>" + StringTools.htmlEscape(content) + "</a>");
	}
	
	public function filelink(nameOrId:String, content:String) : Void {
		buf.add("<a href='" + (fileUrlCreator == null ? 
			StringTools.urlEncode(nameOrId) : 
			fileUrlCreator(StringTools.urlEncode(nameOrId))) + "'>" + 
			StringTools.htmlEscape(content) + "</a>");
	}
	
	
	public function tableRowBegin() {	buf.add('\t<TR>\n'); }
	
	public function tableRowEnd() { buf.add('\t</TR>\n'); }
	
	public function tableCellBegin(?options:String) { 
		buf.add('\t\t<TD'+(options != null ? ' ' + options : '')+'>\n'); 
	}
	
	public function tableCellEnd() { buf.add('\n\t\t</TD>\n'); }
	
	public function tableEnd() { buf.add('</TABLE>\n');	}
	
	public function textElement(text:String) { 
		buf.add(replaceNorwegian(
					StringTools.replace(
						StringTools.htmlEscape(text), '\n', '<BR>')));
	}
	
	public function boldBegin() {	/*trace("BOLD ON<br>");*/  buf.add('<B>'); }
	
	public function boldEnd() { /*trace("BOLD OFF<br>");*/ buf.add('</B>'); }

	public function italicBegin() { buf.add('<I>'); }
	
	public function italicEnd() { buf.add('</I>'); }

	public function underlineBegin() {	buf.add('<U>'); }
	
	public function underlineEnd() { buf.add('</U>'); }
	
	public function paragraphBegin() { buf.add('<P>');  }
	
	public function paragraphEnd() { buf.add('</P>'); }
	
	public function header1Begin() : Void { buf.add('<H1>'); }
	public function header1End() : Void { buf.add('</H1>'); }
	public function header2Begin() : Void { buf.add('<H2>'); }
	public function header2End() : Void { buf.add('</H2>'); }
	public function header3Begin() : Void { buf.add('<H3>'); }
	public function header3End() : Void { buf.add('</H3>'); }
	
	public function orderedListStart() : Void { buf.add('<OL>\n'); }
	public function orderedListEnd() : Void { buf.add('</OL>\n'); }
	public function unorderedListStart() : Void { buf.add('<UL>\n'); }
	public function unorderedListEnd() : Void { buf.add('</UL>\n'); }
	public function listElementStart() : Void { buf.add('<LI>'); }
	public function listElementEnd() : Void { buf.add('</LI>\n'); }
	
	public static var HTML_AE = '&aelig;';
	public static var HTML_OE = '&oslash;';
	public static var HTML_AA = '&aring;';
	public static var HTML_AE_CAP = '&AElig;';
	public static var HTML_OE_CAP = '&Oslash;';
	public static var HTML_AA_CAP = '&Aring;';
	
	public static function replaceNorwegian(s:String) : String {
		//trace('replaceNorw');
		return 
			StringTools.replace(StringTools.replace(StringTools.replace(
			StringTools.replace(StringTools.replace(StringTools.replace(s, 
				'æ', HTML_AE),
				'ø', HTML_OE),
				'å', HTML_AA),
				'Æ', HTML_AE_CAP),
				'Ø', HTML_OE_CAP),
				'Å', HTML_AA_CAP);
	}
	
	public function specialChar(code:String) { 
		switch(code) {
			case RtfConverter.SPECIAL_AE : buf.add(HTML_AE);
			case RtfConverter.SPECIAL_OE : buf.add(HTML_OE);
			case RtfConverter.SPECIAL_AA : buf.add(HTML_AA);
			case RtfConverter.SPECIAL_AE_CAP : buf.add(HTML_AE_CAP);
			case RtfConverter.SPECIAL_OE_CAP : buf.add(HTML_OE_CAP);
			case RtfConverter.SPECIAL_AA_CAP : buf.add(HTML_AA_CAP);
		}
	}
	
	public function toString() : String {
		return buf.toString();
	}
}