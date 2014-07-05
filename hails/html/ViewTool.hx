/**
 * ...
 * @author ...
 */

package hails.html;
import hails.config.HailsConfig;
import hails.HailsBaseRecord;

class ViewTool 
{

	public static var PARAM_ARRAY_START = "(";
	public static var PARAM_ARRAY_END = ")";
	
	public static var callBacks = { 
		linkTo : _linkTo,
		pathToResource : _pathToResource,
		pathTo : _pathTo,
		pathToWithParam : _pathToWithParam,
		includeJavascript : _includeJavascript,
		includeCss : _includeCss,
		ajaxDiv : _ajaxDiv,
		h : _h,
		inputFor : _inputFor,
		checkboxFor : _checkboxFor,
		textareaFor : _textareaFor,
		formatDate : _formatDate,
		inputDateFor : _inputDateFor,
		formatDateDefault : _formatDateDefault,
		formatDateTimeDefault : _formatDateTimeDefault,
		urlEncode : _urlEncode
	};
	
	public static function link(path:String, content:String) : String {
		return "<a href='" + path + "'>" + content + "</a>";
	}
	
	public static function generateRandomString() : String {
		return Std.string(Math.round(Math.random() * 10000000 + Math.random() * 10000000));
	}
	
	public static function linkWithConfirm(path:String, content:String, confirmText:String, ?postParams:Dynamic) : String {
		var formId:String = generateRandomString();
		var form:String = "<form method='POST' style='display:none;' id='" + formId + "' action='" + path + "'>";
		var it = Reflect.fields(postParams).iterator();
		var key:String;
		while (it.hasNext()) {
			key = it.next();
			form += "<input type='hidden' name='" + key + "' value='" + Reflect.field(postParams, key) + "'/>";
		}
		form += "</form>";
		return 
			form +
			"<a href='javascript:void(null);' " +
			" onclick='javascript:if(confirm(\""+confirmText+"\")){$(\"#"+formId+"\").submit();}' >" +
			content + "</a>";
	}
	
	
	
	public static function pathTo(controller:String, ?action:String, ?getParams:Dynamic) : String {
		var ret:String = HailsConfig.getBaseUrl() + controller + (action == null ? "" : HailsConfig.URL_SEP + action);
		if (getParams != null) {
			if (Type.getClass(getParams) == String) {
				ret += "?" + getParams;
			} else {
				var it:Iterator<String> = Reflect.fields(getParams).iterator();
				var key:String;
				var first = true;
				while (it.hasNext()) {
					key = it.next();
					ret += (first ? "?" : "&");
					ret += key + "=" + StringTools.urlEncode(Std.string(Reflect.field(getParams, key)));
					first = false;
				}
			}
		}			
		return ret;
	}
	
	public static function ajaxDiv(divId:String, controller:String, ?action:String, ?getParams:Dynamic) : String {
		return "<DIV id='" + divId + "'>" +
		'<script language="javascript">'+
		'	$(document).ready(function() {' +
		'		$("#'+divId+'").load("'+pathTo(controller,action,getParams)+'");' +
		'	});' +
		'</script>' +
		"</DIV>";
	}
	
	public static function _ajaxDiv(resolve : String -> Dynamic, divId:String, controller:String, ?action:String, ?getParams:Dynamic) : String {
		if (getParams == '') {
			getParams = null;
		}
		return ajaxDiv(divId, controller, action, getParams);
	}
	
	public static function jsReplaceHtmlUrl(id:String, url:String) {
		//return "$('#" + id + "').empty().load('" + url + "')";
		return "$('#" + id + "').load('" + url + "')";
	}
	
	public static function jsLinkReplaceHtmlUrl(id:String, url:String, content:String) {
		return "<a href='javascript:void(null);' onclick=\"javascript:" + jsReplaceHtmlUrl(id, url) + "\">" +
			content +
			"</a>";
	}
	
	public static function includeJavascript(scriptName:String) {
		return "<script type='text/javascript' src='"+pathToResource(scriptName)+"'></script>\n";
	}

	public static function _includeJavascript( resolve : String -> Dynamic, scriptName:String ) {
		return includeJavascript(scriptName);
	} 

	public static function includeCss(cssName:String) {
		return "<link href='" + pathToResource(cssName) + "' rel='stylesheet' type='text/css'>";
	}

	public static function _includeCss( resolve : String -> Dynamic, cssName:String ) {
		return includeCss(cssName);
	} 
	

	public static function _pathTo( resolve : String -> Dynamic, controller:String, ?action:Dynamic ) {
		return pathTo(controller, Std.string(action));
	} 

	public static function _pathToWithParam( resolve : String -> Dynamic, controller:String, action:Dynamic, getParams:Dynamic ) {
		return pathTo(controller, Std.string(action), getParams);
	} 
	
	public static function pathToResource(resource:String) : String {
		return HailsConfig.getResourceBaseUrl() + resource;
	}
	public static function _pathToResource(resolve : String -> Dynamic, resource:String) : String {
		return pathToResource(resource);
	}
	
	public static function linkTo(controller:String, action:String, content:String) : String {
		return link(pathTo(controller, action), content);
	}
	
	public static function _linkTo( resolve : String -> Dynamic, controller:String, action:String, content:String ) {
		return linkTo(controller, action, content);
	}
	
	public static function h(s:String) : String {
		return htmlSpecialChars(s);	
	}
	
	public static function _h( resolve : String -> Dynamic, s:String ) {
		return h(s);
	}
	
	public static function htmlEntities(s:String) : String {
		#if php
		return untyped __call__("htmlentities", s);
		#else
		return null;
		#end
	}
	
	public static function htmlSpecialChars(s) : String {
		#if php
		return untyped __call__("htmlspecialchars", s);
		#else
		return null;
		#end
	}
	
	public static function _inputFor(resolve : String -> Dynamic, recName:String, fieldName:String) : String {
		var rec:HailsBaseRecord = resolve(recName);
		var classAttr:String = "";
		if (rec.fieldHasError(fieldName)) {
			classAttr = " class='field_with_error' ";
		}
		var val = Reflect.field(rec, fieldName);
		return "<input id='" + recName + "_" + fieldName + "'" + 
			classAttr +
			" name='"+recName + PARAM_ARRAY_START + fieldName+ PARAM_ARRAY_END + "' value='"+val+"'/>";
	}
	
	public static function _inputDateFor(resolve : String -> Dynamic, recName:String, fieldName:String) : String {
		var rec:HailsBaseRecord = resolve(recName);
		var classAttr:String = "";
		if (rec.fieldHasError(fieldName)) {
			classAttr = " class='field_with_error' ";
		}
		var origVal:Dynamic = Reflect.field(rec, fieldName);
		var val = (origVal != null ? _formatDateDefault(resolve, origVal) : "");
		return "<input id='" + recName + "_" + fieldName + "'" + 
			classAttr +
			" name='"+recName + PARAM_ARRAY_START + fieldName+ PARAM_ARRAY_END + "' value='"+val+"'/>";
	}

	public static function _checkboxFor(resolve : String -> Dynamic, recName:String, fieldName:String) : String {
		var rec:HailsBaseRecord = resolve(recName);
		var classAttr:String = "";
		if (rec.fieldHasError(fieldName)) {
			classAttr = " class='field_with_error' ";
		}
		var val:Bool = Reflect.field(rec, fieldName);
		var checked = "";
		if (val) {
			checked = " checked='1'";
		}
		return "<input type='checkbox' id='" + recName + "_" + fieldName + "'" + 
			classAttr +
			" name='"+recName + PARAM_ARRAY_START + fieldName+ PARAM_ARRAY_END + "' "+checked+"/>";
	}
	
	
	public static function _textareaFor(resolve : String -> Dynamic, recName:String, fieldName:String) : String {
		var rec:HailsBaseRecord = resolve(recName);
		var classAttr:String = "";
		if (rec.fieldHasError(fieldName)) {
			classAttr = " class='field_with_error' ";
		}
		var val = Reflect.field(rec, fieldName);
		return "<textarea id='" + recName + "_" + fieldName + "'" +
			classAttr +
			" name='"+recName + PARAM_ARRAY_START + fieldName+ PARAM_ARRAY_END +"'>"+val+"</textarea>";
	}
	
	public static function _formatDateDefault(resolve : String -> Dynamic, d:Dynamic) : String {
		return formatDateDefault(d);
	}
	public static function _formatDateTimeDefault(resolve : String -> Dynamic, d:Dynamic) : String {
		return formatDateTimeDefault(d);
	}
	public static function formatDateDefault(d:Dynamic) : String {
		return formatDate(d, '%d.%m.%Y');
	}
	public static function formatDateTimeDefault(d:Dynamic) : String {
		return formatDate(d, '%d.%m.%Y %H:%M');
	}
	public static function _formatDate(resolve : String -> Dynamic, d:Dynamic, format:String) : String {
		return formatDate(d, format);
	}
	public static function _urlEncode(resolve : String -> Dynamic, str:String) : String {
		return StringTools.urlEncode(str);
	}
	public static function formatDate(d:Dynamic, format:String) : String {
		var theDate:Date = null;
		if (Type.getClass(d) == String) {
			// Ooops... we actually get String's from MySQL.. and PHP is dynamically typed, so... :|
			theDate = Date.fromString(cast d);
		} else {
			theDate = d;
		}
		return DateTools.format(theDate, format);
	}
	
	public static function parseDateDefault(dt:String) : Date {
		if (dt == null || dt.length == 0) {
			return null;
		}
		var errMsg = 'Dato må angis på formatet dd.mm.åååå';
		var dtParts:Array < String > = dt.split('.');
		if (dtParts == null || dtParts.length != 3) {
			throw errMsg;
		}
		try {
			var d = Std.parseInt(dtParts[0]);
			var m = Std.parseInt(dtParts[1]);
			var y = Std.parseInt(dtParts[2]);
			if (d < 1 || m < 1 || y < 1 || d > 31 || m > 12) {
				throw errMsg;
			}
			m = m - 1;
			if (y < 100) {
				y = 1900 + y;
			}
			//trace(d);
			//trace(m);
			//trace(y);
			var ret:Date = new Date(y, m, d, 0, 0, 0);
			//trace(DateTools.format(ret,'%y-%m-%d'));
			return ret;
		} catch (e:Dynamic) {
			throw errMsg;
		}
	}
	
	
}