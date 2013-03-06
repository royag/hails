/**
 * ...
 * @author ...
 */

package hails.ext.text;

class HWikiDefs 
{
	public static var MARK_HEADER_1 = '====';
	public static var MARK_HEADER_2 = '==';
	public static var MARK_HEADER_3 = '=';
	public static var MARK_BOLD = '**';
	public static var MARK_ITALIC = '%%';
	public static var MARK_UNDERLINE = '__';
	
	public static var TABLE_START = '{|';
	public static var TABLE_CAPTION_START = '|+';
	public static var TABLE_CAPTION_END = '';
	public static var TABLE_END = '|}';
	public static var TABLE_ROW_START = '|-';
	public static var TABLE_ROW_END = '';
	public static var TABLE_CELL_START = '|';
	
	public static var LINE_FEED = '\n';
	
	public static var UNORDERED_LIST_LINE_START = LINE_FEED + '- ';
	public static var UNORDERED_LIST_DOT_START = LINE_FEED + '* ';
	public static var ORDERED_LIST_START = ORDERED_LIST_ELEMENT_START(1); // LINE_FEED + '1. ';
	
	public static function ORDERED_LIST_ELEMENT_START(num:Int) : String {
		return LINE_FEED + num + '. ';
	}
	
	public static var IMAGE_FUNC = "$pic";
	public static var LINK_FUNC = "$link";
	public static var FILELINK_FUNC = "$file";
	public static var ARTICLELINK_FUNC = "$article";
}