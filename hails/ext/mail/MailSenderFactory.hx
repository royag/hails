package hails.ext.mail;
#if java
import hails.ext.mail.java.JavaMailSender;
#end
#if php
import hails.ext.mail.php.PhpMailSender;
#end


class MailSenderFactory
{

	public function new() 
	{
		
	}
	
	public static function createInstance():Mailer {
		#if java
		return new JavaMailSender();
		#elseif php
		return new PhpMailSender();
		#else
		return new Mailer();
		#end
	}
	
}