/**
 * ...
 * @author ...
 */

package hails.ext.text;

enum RtfElem {
	rtf_block(elems:List<RtfElem>);
	rtf_metablock(elems:List<RtfElem>);
	rtf_tag(name:String);
	rtf_text(data:String);
	rtf_text_after_meta(data:String);
}