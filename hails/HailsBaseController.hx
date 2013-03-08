/**
* ...
* @author Default
*/

package hails;

import config.HailsConfig;
import hails.html.ViewTool;
import hails.util.StringUtil;
import haxe.Template;
import sys.io.File;
import hails.platform.IWebContext;


class HailsBaseController {
	var WebCtx:IWebContext;
	
	public function new(initialAction:String, ctx:IWebContext) {
		this.WebCtx = ctx;
		this.initialAction = initialAction;
		this.hasRendered = false;
		this.shouldRender = true;
		this.renderType = "html";
		this.defaultLayout = null; // "main";
		this.viewData = { };
	}

	public function route(r:Route) : String {
		switch (r) {
			case get : return 'index';
			case get_param(param) : return 'show';
			case get_param2(p1,p2) : return null;
			case post : return 'create';
			case post_param(param) : return 'update';
			case post_param2(p1,p2) : return null;
			case delete_param(param) : return 'delete';
			case delete_param2(p1,p2) : return null;
		}
	}	
	
	public var errorMessage:String;
	public var infoMessage:String;
	public var urlParam:String;
	public var urlParam2:String;
	public var hasRendered:Bool;
	public var shouldRender:Bool;
	public var renderType:String;
	
	var viewData:Dynamic;
	
	function addDefaultViewData(data:Dynamic) {
		
	}
	
	public var initialAction:String; // Name of the action called by dispatcher
	public var controllerId:String;
	private var defaultLayout:String;
	
	public function getDefaultSubs() : Array<String> {
		return [];
	}
	
	public function setDefaultLayout(layout:String) {
		this.defaultLayout = layout;
	}
	
	private function resolveViewName(action:String) {
		/*if (action == null) {
			action = this.initialAction;
		}*/
		if (action == null) {
			throw /*new Exception(*/"No action to render";// );
		}
		if (action.indexOf("/") < 0) {
			return config.HailsConfig.phpViewRoot + "/" + controllerId + "/" + action;
		} else {
			return HailsConfig.phpViewRoot + "/" + action;
		}
	}
	
	private function resolveLayoutHtmlFile(layout:String) {
		return config.HailsConfig.phpViewRoot + "/layout/" + layout + ".html";
	}
	
	private function resolvePhpViewName(action:String) {
		return resolveViewName(action) + ".php";
	}

	private function resolveHtmlViewName(action:String) {
		//Lib.print(resolveViewName(action) + ".html");
		return resolveViewName(action) + ".html";
	}
	
	private function resolveHtmlSubViewName(sub:String) {
		var slash:Int = sub.indexOf("/");
		var sname:String = sub;
		if (slash >= 0) {
			sname = sub.substr(0, slash) + "/_" + sub.substr(slash + 1, sub.length - (slash + 1));
		} else {
			sname = "_" + sname;
		}
		return resolveViewName(sname) + ".html";
	}
	
	function setAsRendered() {
		this.hasRendered = true;
		this.shouldRender = false;
	}
	
	function doRender() {
		trace("TRALALAL");
	}
	
	private function getHtml(fileName:String, ?vars:Dynamic, ?layout:String, ?callBacks:Dynamic) : String {
		var content:String = File.getContent(fileName);
		var t = new Template(content);
		var contentHtml = t.execute(vars, callBacks);
		if (layout != null) {
			Reflect.setField(vars, 'content', contentHtml);
			//trace(callBacks);
			return getHtml(resolveLayoutHtmlFile(layout), vars, null, callBacks);
		}
		return contentHtml;
	}
	
	public function render(?options:Dynamic) {
		setAsRendered();
		var data:Dynamic = this.viewData;
		if (data == null) {
			data = { };
		}
		Reflect.setField(data, 'hasError', (errorMessage != null));
		Reflect.setField(data, 'errorMessage', errorMessage);
		Reflect.setField(data, 'hasInfo', (infoMessage != null));
		Reflect.setField(data, 'infoMessage', infoMessage);
		var action:String = this.initialAction;
		var layout:String = this.defaultLayout;
		var format:String = this.renderType;
		var callBacks:Dynamic = ViewTool.callBacks;
		var subviews:Array<String> = null;
		var subviews:Array<String> = null;
		var viewAction:String = StringUtil.tableize(action);
		if (options != null) { // || getDefaultSubs() != null) {
			if (Reflect.hasField(options, 'view')) {
				viewAction = Reflect.field(options, 'view');
			}
			if (Reflect.hasField(options, 'callbacks')) {
				var cbField = Reflect.field(options, 'callbacks');
				var cbArr:Array<String> = Reflect.fields(cbField);
				var cbIt:Iterator<String> = cbArr.iterator();
				var cbkey:String;
				while (cbIt.hasNext()) {
					cbkey = cbIt.next();
					Reflect.setField(callBacks, cbkey, Reflect.field(cbField, cbkey));
				}
			}
			//callBacks = ViewTool.callBacks;
			if (Reflect.hasField(options, 'data')) {
				data = Reflect.field(options, 'data');
			}
			addDefaultViewData(data);
			if (Reflect.hasField(options, 'action')) {
				viewAction = Reflect.field(options, 'action');
			}
			//trace(action);
			if (Reflect.hasField(options, 'layout')) {
				layout = Reflect.field(options, 'layout');
			}
			if (Reflect.hasField(options, 'format')) {
				format = Reflect.field(options, 'format');
			}
			if (Reflect.hasField(options, 'sub') || getDefaultSubs() != null) {
				subviews = Reflect.field(options, 'sub');
				if (subviews == null) {
					subviews = getDefaultSubs();
				} else if (getDefaultSubs() != null) {
					subviews = subviews.concat(getDefaultSubs());
				}
				var it:Iterator<String> = subviews.iterator();
				var svname:String;
				var svshortname:String;
				while (it.hasNext()) {
					svname = it.next();
					svshortname = svname.split("/").pop();
					Reflect.setField(data, '_' + svshortname, 
						getHtml(resolveHtmlSubViewName(svname),
						data, null, callBacks));
				}
			}
		} else {
			addDefaultViewData(data);
		}
		if (format == 'html') {
			var html = getHtml(resolveHtmlViewName(viewAction), data, layout, callBacks);
			WebCtx.print(html);
		} else {
			throw /*new Exception(*/"Unknown format: " + format; // );
		}
	}
	
	function renderRaw(outputData) {
		setAsRendered();
		WebCtx.print(outputData);
	}
	
	#if php
	/**
	 * Include default php-view in action-methods, so that the calling method's local variables 
	 * - as well as the controllers methods and instance method - are made available to the PHP-script.
	 * E.g:	"var mystring = 'something'" in action-method will be available as "$mystring",
	 * and the PHP-file will actually be a part of the controller class, 
	 * so the controller-instance is actually available as "$this".
	 * @param	?action		If specified, render an other action than the initial action called by dispatcher.
	 */
	inline function includePhp(?action:String) {
		setAsRendered();
		var render = doRender;
		HailsPhpRenderer.includePhp(resolvePhpViewName(action));
	}
	#end
}