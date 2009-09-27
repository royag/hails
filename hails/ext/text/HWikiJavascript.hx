/**
 * ...
 * @author ...
 */

package hails.ext.text;
import js.Dom;
import js.Lib;
//import js.Textarea;
import hails.ext.text.HWikiDefs;

class HWikiJavascript 
{

	#if js
	// JavaScript-specific functions:
	public static function main() 
	{
	}
	
	public static function insertAtCursor(textAreaId:String, val:String) {
		untyped __js__("
			ta = $('#' + textAreaId);
			if (document.selection) {
				ta.focus();
				sel = document.selection.createRange();
				sel.text = val;
			} else if (ta.selectionStart || (ta.selectionStart == '0')) {
				var startPos = ta.selectionStart; 
				var endPos = ta.selectionEnd; 
				ta.value = ta.value.substring(0, startPos)+ val+ ta.value.substring(endPos, ta.value.length);
			} else {
				ta.attr('value', ta.attr('value') + val);
			}
		");	
	}
	
	public static function insertBold(textAreaId:String, val:String) {
		insertAtCursor(textAreaId, HWikiDefs.MARK_BOLD + val + HWikiDefs.MARK_BOLD);
	}
	
	public static function insertItalic(textAreaId:String, val:String) {
		insertAtCursor(textAreaId, HWikiDefs.MARK_ITALIC + val + HWikiDefs.MARK_ITALIC);
	}

	public static function insertUnderline(textAreaId:String, val:String) {
		insertAtCursor(textAreaId, HWikiDefs.MARK_UNDERLINE + val + HWikiDefs.MARK_UNDERLINE);
	}

	public static function insertHeader(textAreaId:String, val:String) {
		insertAtCursor(textAreaId, HWikiDefs.MARK_HEADER_2 + val + HWikiDefs.MARK_HEADER_2);
	}
	
	public static function insertTable(textAreaId:String, rows:Int, cols:Int) {
		var data:String = HWikiDefs.LINE_FEED + HWikiDefs.TABLE_START + "border=1 width='90%'";
		for (row in 0...rows) {
			data += HWikiDefs.LINE_FEED + HWikiDefs.TABLE_ROW_START;
			for (col in 0...cols) {
				data += HWikiDefs.TABLE_CELL_START +
					" L" + Std.string(row+1) + ",C" + Std.string(col+1) + " ";
			}
			data += HWikiDefs.TABLE_ROW_END;
		}
		data += HWikiDefs.LINE_FEED + HWikiDefs.TABLE_END + HWikiDefs.LINE_FEED;
		insertAtCursor(textAreaId, data);
	}
	
	public static function insertImage(textAreaId:String, imageName:String) {
		insertAtCursor(textAreaId, HWikiDefs.IMAGE_FUNC + "(" + imageName + ")");
	}

	
	public static function insertImageWithWidth(textAreaId:String, imageName:String, width:String, height:String) {
		insertAtCursor(textAreaId, HWikiDefs.IMAGE_FUNC + "(" + imageName + ","+width+","+height+")");
	}
	
	public static function insertArticleLink(textAreaId:String, articleId:String) {
		insertAtCursor(textAreaId, HWikiDefs.ARTICLELINK_FUNC + "(" + articleId + ",Les mer...)");
	}

	public static function insertLink(textAreaId:String) {
		insertAtCursor(textAreaId, HWikiDefs.LINK_FUNC + "(http://www.google.com,Søk på google)");
	}

	public static function insertFileLink(textAreaId:String, fileName:String) {
		insertAtCursor(textAreaId, HWikiDefs.FILELINK_FUNC + "(" + fileName + ",Last ned "+fileName+")");
	}
	
	
	
	
	#end
}