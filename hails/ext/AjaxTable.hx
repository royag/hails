/**
 * ...
 * @author ...
 */

package hails.ext;
import hails.HailsDbRecord;
import hails.html.HtmlElem;
import hails.html.ViewTool;
import hails.util.DynamicUtil;
import hails.util.StringUtil;
import hails.util.TypeUtil;

	typedef ControllerAction = {
		controller:String,
		action:String,
		param:Dynamic
	};

class AjaxTable /*implements HtmlElem*/
{
	public var fields:Array<String>;
	public var virtualFields:Dynamic<HailsDbRecord -> String>;
	public var presentations:Dynamic<HailsDbRecord -> String>;
	public var titles:Dynamic;
	public var cellWidth:Dynamic;
	public var conditions:Array<Dynamic>;
	public var join:String;
	public var include:String;
	public var select:String;
	public var showNewRecord:Bool;
	public var controllerId:String;
	public var tableClass:String;
	
	
	public var editableFields:Array<String>;
	public var insertableFields:Array<String>;

	public var useInlineEdit:Bool;
	public var showPageInfo:Bool;
	
	var modelClass:Class<HailsDbRecord>;
	var limit:Array<Int>;
	var order:String;
	var id:String;
	var isCallback:Bool;
	var callbackUrl:ControllerAction;
	
	public function new(modelClass:Class<HailsDbRecord>, 
		options:{perPage:Int, pageNo:Int, order:String, isCallback:Bool, callbackUrl:ControllerAction}, ?id:String) 
	{
		this.modelClass = modelClass;
		this.id = (id != null ? id : HailsDbRecord.tableNameForClass(modelClass) + "_atable");
		this.order = options.order;
		this.isCallback = options.isCallback;
		this.callbackUrl = options.callbackUrl;
		limit = [options.perPage * (options.pageNo - 1), options.perPage];
		this.useInlineEdit = false;
		this.showNewRecord = false;
		this.tableClass = 'ajaxtable';
		this.showPageInfo = true;
	}
	
	
	public static function INLINE_EDIT_BUTTON(self:AjaxTable, editCaption:String, deleteCaption:String, deletePrompt:String) : HailsDbRecord -> String {
		return function(rec:HailsDbRecord) : String {
				var ret = "<a href='javascript:void(null);' onclick=\"javascript:" +
					"$.getScript('" + 
						ViewTool.pathTo(self.controllerId, 'ajaxedit', DynamicUtil.copyFields({id : rec.id, rowid:self.getRowId(rec)}, self.callbackUrl.param)) +
						"')" + 
					"\">" + editCaption + "</a>";
				ret += " <a href='javascript:void(null);' onclick=\"javascript:if(confirm('"+deletePrompt+"')){" +
					"$.post('" + 
						ViewTool.pathTo(self.controllerId, 'ajaxdelete', DynamicUtil.copyFields({id : rec.id, rowid:self.getRowId(rec)}, self.callbackUrl.param)) +
						"', {}, null, 'script')" + //"</tr></table></form></td>')" +
					";}\">" +
					deleteCaption + "</a>";	
				return ret;
		}
	}
	
	public function getId() : String {
		return id;
	}
	
	function findRecs(?extraConditions:Array<Dynamic>) : List < HailsDbRecord > {
		var conds = HailsDbRecord.mergeConditions(conditions, extraConditions);
		/*conditions;
		if (conds == null) {
			conds = extraConditions;
		} else if (extraConditions != null) {
			conds[0] = conds[0] + ' and ' + extraConditions[0];
			conds = conds.concat(extraConditions.splice(1, 1));
		}*/
		//trace(conds);
		//trace(conds);
		return HailsDbRecord.findAllType(modelClass, 
			{limit:limit, order:order, conditions:conds, join:join, include:include, select:select} );
	}
	
	function countAllRecs() : Int {
		return HailsDbRecord.countAll(modelClass,
			{conditions:conditions, join:join, include:include, select:select});
	}

	public function getTableId() {
		return this.id;
	}
	
	public function getRowIdForId(id:Int) {
		return getTableId() + "_tr_" + id;
	}
	
	public function getRowId(rec:HailsDbRecord) {
		return getRowIdForId(rec.id);
	}
	
	public function getRowNoFieldId(recNo:Int, fn:String) {
		return getRowIdForId(recNo) + "_" + fn;
	}
	
	public function getRowFieldId(rec:HailsDbRecord, fn:String) {
		return getRowId(rec) + "_" + fn;
	}
	
	public function getDivId() {
		return this.id + '_div';
	}
	
	// Denne blir ikke inlinet skikkelig: (haxe-bug?)
	function curPage() {
		return Math.floor(limit[0] / perPage()) + 1;
	}
	
	function perPage() {
		return limit[1];
	}
	
	function firstRecNo() {
		return (curPage() - 1) * perPage() + 1;
	}
	
	function lastRecNo(totalRecs:Int) {
		var last = (curPage() * perPage());
		if (last > totalRecs) {
			return totalRecs;
		}
		return last;
	}
	
	function makeOrderByLink(colName:String, content:String) {
		if (this.order != null) {
			if (this.order == colName) {
				// currently sorted on this column
				// maybe show an icon ?
				colName += ' desc';
			} else if (this.order == colName + ' desc') {
				// corrently desc sorted on this column
				// nothing to do... maybe icon ?
			}
		}
		var html = ViewTool.jsLinkReplaceHtmlUrl(getDivId(), 
				ViewTool.pathTo(callbackUrl.controller, callbackUrl.action,
				DynamicUtil.copyFields({ page : 1, order : colName },callbackUrl.param) ), 
				content);
		return html;
	}
	
	function makePageInfo(totalRecs:Int, totalPages:Int) {
		var curPage = curPage();
		
		var pageInfo = "Viser treff " + firstRecNo() + "-" + lastRecNo(totalRecs) + " av " + totalRecs;
		
		var pageNav = "";
		
		if (curPage > 2) {
			pageNav += ViewTool.jsLinkReplaceHtmlUrl(getDivId(), 
				ViewTool.pathTo(callbackUrl.controller, callbackUrl.action,
				DynamicUtil.copyFields({ page : 1 },callbackUrl.param) ), 
				" << F&oslash;rste ");
		}
		if (curPage > 1) {
			pageNav += ViewTool.jsLinkReplaceHtmlUrl(getDivId(), 
				ViewTool.pathTo(callbackUrl.controller, callbackUrl.action,
				DynamicUtil.copyFields({ page : curPage - 1 },callbackUrl.param) ), 
				" < Forrige ");
		}
		if (curPage < totalPages) {
			pageNav += ViewTool.jsLinkReplaceHtmlUrl(getDivId(), 
				ViewTool.pathTo(callbackUrl.controller, callbackUrl.action,
				DynamicUtil.copyFields({ page : curPage+1},callbackUrl.param)),
				" Neste >");
		}
		if (curPage + 1 < totalPages) {
			pageNav += ViewTool.jsLinkReplaceHtmlUrl(getDivId(), 
				ViewTool.pathTo(callbackUrl.controller, callbackUrl.action,
				DynamicUtil.copyFields({ page : totalPages},callbackUrl.param)),
				" Siste >>");
		}
		
		return "<table class='ajaxtable_info'><tr><td class='ajaxtable_info_nav'>" + pageNav + "</td><td class='ajaxtable_info_pages'>" + pageInfo +"</td></tr></table>";
	}
	
	function createTHRow() {
		var th:String = "<TR>";
		var fieldIter:Iterator<String> = this.fields.iterator();
		var fn:String;
		var title:String;
		var content:String;
		while (fieldIter.hasNext()) {
			fn = fieldIter.next();
			title = fn;
			if (titles != null && Reflect.hasField(titles, fn)) {
				title = Reflect.field(titles, fn);
			}
			content = title;
			var thClass = 'ajaxth_norm';
			if (isSortable(fn)) {
				content = makeOrderByLink(fn, title);
				thClass = 'ajaxth_sortable';
			}
			th += "<TH class='"+thClass+"'>" + content + "</TH>";
		}
		th += "</TR>";
		return th;
	}
	
	function isSortable(colName:String) {
		return (virtualFields == null) || (! Reflect.hasField(virtualFields, colName));
	}
	
	/**
	 * 
	 * @param	fn   tableized_field_name
	 * @param	id
	 */
	function fieldIsEditableForRecId(fn:String, id:Int) : Bool {
		var fields:Array<String> = ( id == 0 ?
			(insertableFields == null ? editableFields : insertableFields ) :
			editableFields );
		if (fields == null) {
			return false;
		}
		return Lambda.has(fields, fn);
	}

	function createRowContent(rec:HailsDbRecord, ?editable:Bool = false, ?includeTR:Bool=false) : String {
		var fieldIter:Iterator<String> = this.fields.iterator();
		var fn:String;
		var callBack:(HailsDbRecord -> String);
		var tableRow = "";
		/*if (editable) {
			tableRow += "<FORM>";
		}*/
		
		var editPostData = "";
		var hasPostData = false;
		
		while (fieldIter.hasNext()) {
				//trace('NeXT');
			var cellContent = "";
			fn = fieldIter.next();
			if ((fn == 'edit') && editable) {
				cellContent = "<a href='javascript:void(null);' onclick=\"javascript:" +
					"$.post('" + 
						ViewTool.pathTo(controllerId, 'ajaxsave', DynamicUtil.copyFields({id : rec.id, rowid:getRowId(rec)}, callbackUrl.param)) +
						"', {"+editPostData+"}, null, 'script')" + //"</tr></table></form></td>')" +
					"\">" +
					"<script language='javascript'>"+
					"$('#"+getRowId(rec)+"').keyup(function(e){if(e.keyCode==13){$.post('" + 
						ViewTool.pathTo(controllerId, 'ajaxsave', DynamicUtil.copyFields({id : rec.id, rowid:getRowId(rec)}, callbackUrl.param)) +
					"', {" + editPostData + "}, null, 'script');}});";
					cellContent += "</script>"+
					'Lagre' + "</a>";	
			} else {
				if (virtualFields != null && Reflect.hasField(virtualFields, fn)) {
					callBack = Reflect.field(virtualFields, fn);
					cellContent = callBack(rec);
				} else {
					// normal db-field:
					if (presentations != null && Reflect.hasField(presentations, fn)) {
						// Almost like a virtualField, but it IS an actual field,
						// meaning it is also sortable (which virtualFields are not)
						callBack = Reflect.field(presentations, fn);
						cellContent = callBack(rec);
					} else {
						// field-data is displayed raw in table cell
						var camelFieldName = StringUtil.camelizeWithFirstAsLower(fn);
						if (Reflect.hasField(rec, camelFieldName)) {
							// Field on record (main-table)
							cellContent = Reflect.field(rec, StringUtil.camelizeWithFirstAsLower(fn));
							if (editable && fieldIsEditableForRecId(fn, rec.id)) {
								cellContent = "<INPUT class='inlineEditField' id='" + getRowId(rec) + "_" + fn +"' value='" + cellContent + "'/>";
								if (hasPostData) {
									editPostData += ",";
								}
								editPostData += (fn + ":$('#" + getRowFieldId(rec, fn) + "')[0].value");
								hasPostData = true;
							}
						} else {
							if (rec.hasJoinedFields()) {
								cellContent = rec.getJoinedField(fn);
							} else {
								cellContent = '[NO SUCH FIELD]';
							}
						}
					}
					
				}
			}
			var tdWidth = '';
			if (this.cellWidth != null) {
				if (Reflect.hasField(this.cellWidth, fn)) {
					tdWidth = " width='"+Reflect.field(this.cellWidth, fn)+"'";
				}
			}
			
			tableRow += "<TD"+tdWidth+">" + cellContent + "</TD>";
		}
		//trace('666');
		/*if (editable) {
			tableRow += "</FORM>";
		}*/
		if (includeTR) {
			tableRow = "<TR id='"+getRowId(rec)+"'>" + tableRow + "</TR>";
		}
		return tableRow;
	}
	
	public function loadOneRow(id:Int, ?editable:Bool = false, ?includeTR:Bool=false) : String {
		//trace('loadOneRow:' + id);
		//trace([HailsDbRecord.tableNameForClass(modelClass) + '.id = ?', id]);
		var rec:HailsDbRecord = findRecs([HailsDbRecord.tableNameForClass(modelClass) + '.id = ?', id]).first();
		if (rec == null) {
			throw "NOT FOUND";
		}
		//trace('creating Row from rec:' + rec);
		//trace(this.fields);
		var tmp = createRowContent(rec, editable, includeTR);
		//trace('creatED Row');
		return tmp;
	}
	
	public function renderNewRow() {
			var tmpRec:HailsDbRecord = Type.createInstance(modelClass, []);
			tmpRec.id = 0;
			tmpRec.fillInDefaultsAndCreatedAt();
			//trace('tmpRec:::::::::' + tmpRec);
			return createRowContent(tmpRec, true);
	}
	
	public function loadAndRender() : String {
		var totalRecs:Int = countAllRecs();
		var totalPages:Int = Math.floor(totalRecs / perPage());
		if (totalPages * perPage() < totalRecs) {
			totalPages += 1;
		}
		var recs:List<HailsDbRecord> = findRecs();
		var it:Iterator<HailsDbRecord> = recs.iterator();
		var rec:HailsDbRecord;
		var pageInfoHtml = makePageInfo(totalRecs, totalPages);
		var table = "<TABLE class='"+this.tableClass+"' id='" + getTableId() + "'>";
		var tableRows = "";
		while (it.hasNext()) {
			rec = it.next();
			var tableRow = "<TR id='"+getRowId(rec)+"'>";
			if (this.fields == null) {
				this.fields = TypeUtil.listToArray(rec.getFieldNames());
			}
			tableRow += createRowContent(rec);
			tableRow += "</TR>";
			tableRows += tableRow + "\n";
		}
		table += createTHRow() + tableRows;
		if (showNewRecord) {
			//trace('huba');
			var tmpRec:HailsDbRecord = Type.createInstance(modelClass, []);
			tmpRec.id = 0;
			table += createRowContent(tmpRec, true, true);
		}
		table += "</TABLE>";
		var content = 
			(this.showPageInfo ? pageInfoHtml + "\n" : "") + table;
		if (!this.isCallback) {
			// This is the first render, so we want to make the DIV, around it...
			content = "<DIV id='" + getDivId() + "'>" + content + '</DIV>';
		}
		return content;
	}
	
	/**
	 * For inlineEdit: controller.ajaxedit-callback, render this raw
	 * @param	Hash < String >
	 * @return
	 */
	public function doAjaxEdit(params : Hash < String > ) : String {
		return "$('#"+params.get('rowid')+"').html(\"" +
			StringTools.replace(loadOneRow(Std.parseInt(params.get('id')), true),'"','\\"') + "\")";
	}
	
	public function doAjaxDelete(params : Hash < String > ):String {
		var rowid = params.get('rowid');
		var idparam = params.get('id');
		var rec:HailsDbRecord = HailsDbRecord.findById(modelClass, idparam);
		if (rec.destroy()) {
			return "$('#" + params.get('rowid') + "').remove();";
		} else {
			return "alert('Kunne ikke slette');";
		}		
	}
	
	/**
	 * For inlineEdit: controller.ajaxsave-callback, render this raw.
	 * The fields specified in property editableFields/insertableFields will be updated.
	 * @param	params
	 * @return
	 */
	public function doAjaxSave(params : Hash < String > , ?extraValues : Dynamic ) : String {
		var rowid = params.get('rowid');
		var idparam = params.get('id');
		var isNew = idparam == '0';
		var rec = 
			(isNew ? 
				Type.createInstance(modelClass, []) :
				HailsDbRecord.findById(modelClass, idparam));
		
		var fields:Array<String> = ( isNew ?
			(insertableFields == null ? editableFields : insertableFields ) :
			editableFields );
		if (fields != null) {
			var it:Iterator<String> = fields.iterator();
			var fn:String;
			while (it.hasNext()) {
				fn = it.next();
				Reflect.setField(rec, StringUtil.camelizeWithFirstAsLower(fn), params.get(fn));
			}
		}
		if (extraValues != null) {
			var it:Iterator<String> = Reflect.fields(extraValues).iterator();
			var fn:String;
			while (it.hasNext()) {
				fn = it.next();
				Reflect.setField(rec, StringUtil.camelizeWithFirstAsLower(fn), Reflect.field(extraValues, fn));
			}
		}
		if (rec.save()) {
			if (isNew) {
				return "$('#"+params.get('rowid')+"').before(\"" +
					StringTools.replace(loadOneRow(rec.id, false, isNew), '"', '\\"') + "\");" +
					"$('#" + params.get('rowid') + "').find(':input').attr('value',''); " +
					// Focus on first editable field:
					"$('#" + getRowNoFieldId(0, fields[0]) + "').focus();";
				
			} else {
				return "$('#" + params.get('rowid') + "').html(\"" +
					StringTools.replace(loadOneRow(rec.id, false, isNew), '"', '\\"') + "\");";
			}
		} else {
			return "alert('Kunne ikke lagre. Sjekk at datene er riktig');";
		}
		return '';
	}
	
	public function toString() : String {
		return loadAndRender();
	}
	
}