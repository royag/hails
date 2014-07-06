/**
* ...
* @author Default
*/

package hails.script;

import hails.util.StringUtil;
import sys.io.File;
//import neko.Lib;
import hails.platform.Platform;
//import java.Lib;
class CodeParser {

	var rootDir:String;
	public var doOutput:Bool;
	
	public function new(_rootDir:String) {
		this.rootDir = _rootDir;
		this.doOutput = true;
	}
	
	public function output(s:String) : Void {
		if (doOutput) {
			Platform.println(s);
		}
	}
	
	public function pathToClass(cname:String) : String {
		var classDir = rootDir;
		//trace(cname);
		if (cname.indexOf("hails.") == 0) {
			classDir = "C:/HaxeToolkit/haxe/lib/hails/0,0,2/";
		}
		var fn = classDir + StringTools.trim(StringTools.replace(cname, '.', '/')) + ".hx";
		//trace("path to class: " + fn);
		return fn;
	}
	
	public function findParentClass(className:String) : String {
		var fileName = pathToClass(className);
		var s:String = File.getContent(fileName);
		var lines:Array < String > = s.split("\n");
		for (l in lines) {
			var parts:Array < String > = StringTools.trim(l).split(' ');
			if (parts.length >= 3 && parts[0] == 'class' && parts[2] == 'extends') {
				var s:String = parts[3];
				if (s.indexOf('{') > -1) {
					s = s.substr(0, s.indexOf('{'));
				}
				for (l2 in lines) {
					if (l2.indexOf("import") > -1 && l2.indexOf(s) > - 1) {
						output("------------");
						var parentClass = l2.split(' ')[1].split(';')[0];
						if (parentClass == "php.db.Object") {
							output("Parent is " + parentClass + ": ignoring...");
							return null;
						}
						return parentClass;
					}
				}
				return s;
			}
		}
		return null;
	}
	
	/**
	 * Intended to be used for looking up model-properties in the haxe source-files,
	 * so that this info can be used for automatic db-migration.
	 * @param	className
	 * @param	prev
	 */
	public function findPublicProperties(className:String, prev:Map < String, DbFieldInfo > ) {
		output(className);
		var ret:Map < String, DbFieldInfo >;
		if (prev == null) {
			ret = new Map < String, DbFieldInfo >();
		} else {
			ret = prev;
		}
		var fileName = pathToClass(className);
		var s:String = File.getContent(fileName);
		var lines:Array < String > = s.split("\n");
		for (l in lines) {
			var parts:Array < String > = StringTools.trim(l).split(' ');
			if (parts[0] == 'public' && parts[1] == 'var') {
				var s2:String = "";
				for (i in 2...parts.length) {
					s2 += parts[i];
				}
				var fieldAndType:Array < String > = s2.split(":");
				var fieldName = StringUtil.tableize(StringTools.trim(fieldAndType[0]));
				// Fields starting with "_" are "virtual" fields...
				if (! StringTools.startsWith(fieldName, '_')) {
					var fieldType = StringTools.trim(fieldAndType[1].split(";")[0]);
					output("\t" + fieldName + " : " + fieldType);
					var annot:String = findAnnotation(l);
					var fieldInfo = DbFieldInfo.createFromHaxeTypeName(fieldType, annot);
					if (fieldName.toLowerCase() == "id") {
						fieldInfo.isId = true;
					}
					ret.set(fieldName, fieldInfo);
				}
			}
		}
		var parent:String = findParentClass(className);
		if (parent == null) {
			return ret;
		} else {
			output("Checking parent-class (" + parent + ")");
			return findPublicProperties(parent, ret);
		}
	}
	
	function findAnnotation(line:String) : String {
		var p1:Array < String > = line.split('//'); // Split on comment
		if (p1 != null && p1.length > 1) {
			var p2:Array<String> = StringTools.trim(p1[1]).split(' ');
			if (p2 != null && p2[0].charAt(0) == '@') {
				return p2[0];
			}
		}
		return null;
	}
	
}