/**
 * ...
 * @author ...
 */

package hails.util;

class Mailer 
{

	#if php
	public static function sendMail(toAdress:String, title:String, body:String, ?headers:String) : Bool {
		return untyped __call__('mail', toAdress, title, body, headers);
	}
	
	public static function sendMailFrom(
		options: { to:String, title:String, body:String, fromName:String, fromEmail:String } ): Bool {
			
		return sendMail(options.to, options.title, options.body,
			"From: " + options.fromName + " <" + options.fromEmail + ">");			
	}
	#else
	public static function sendMail(toAdress:String, title:String, body:String, ?headers:String) : Bool {
		return false;
	}
	
	public static function sendMailFrom(
		options: { to:String, title:String, body:String, fromName:String, fromEmail:String } ): Bool {
			
		return false;			
	}
	#end
	
}