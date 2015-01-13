package hails.ext.mail;


class Mailer
{

	public var smtpSecure(default, default) : Bool = true;
	public var smtpAuth(default, default) : Bool = true;
	public var host(default, default) : String = null;
	public var port(default, default) : Int = 587;
	public var username(default, default) : String = null;
	public var password(default, default) : String = null;
	
	public var from(default, default) : String = null;
	public var fromName(default, default) : String = null;
	public var to(default, default) : String = null;
	public var toName(default, default) : String = null;

	public var subject(default, default) : String = null;
	public var body(default, default) : String = null;
	
	public var errorInfo(default, null) : String = null;
	
	public function new() 
	{
		
	}
	
	public function send():Bool {
		trace("Send Mail not implemented on this platform.");
		return false;
	}
	
}