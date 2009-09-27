/**
 * ...
 * @author ...
 */

package hails.ext.text;

interface IDocumentWriter 
{

	function link(url:String, content:String) : Void;
	
	function filelink(nameOrId:String, content:String) : Void;
	
	function image(nameOrId:String, ?options:Dynamic) : Void;
	
	function tableBegin(?options:String) : Void;
	
	function tableRowBegin() : Void;
	
	function tableRowEnd() : Void;
	
	function tableCellBegin(?options:String) : Void;

	function tableCellEnd() : Void;
	
	function tableEnd() : Void;
	
	function textElement(text:String) : Void;
	
	function boldBegin() : Void;
	
	function boldEnd() : Void;

	function paragraphBegin() : Void;
	
	function paragraphEnd() : Void;
	
	function italicBegin() : Void;
	
	function italicEnd() : Void;
	
	function underlineBegin() : Void;
	
	function underlineEnd() : Void;
	
	function specialChar(code:String) : Void;
	
	function toString() : String;
	
	
	function header1Begin() : Void;
	function header1End() : Void;
	function header2Begin() : Void;
	function header2End() : Void;
	function header3Begin() : Void;
	function header3End() : Void;
	
	function orderedListStart() : Void;
	function orderedListEnd() : Void;
	function unorderedListStart() : Void;
	function unorderedListEnd() : Void;
	function listElementStart() : Void;
	function listElementEnd() : Void;
	
}