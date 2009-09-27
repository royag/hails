/**
 * ...
 * @author ...
 */

package hails;

enum Route {
	get_param(param1:String);
	get_param2(param1:String,param2:String);
	get;
	post_param(param1:String);
	post_param2(param1:String,param2:String);
	post;
	delete_param(param1:String);
	delete_param2(param1:String,param2:String);
}