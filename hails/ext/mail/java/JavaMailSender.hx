package hails.ext.mail.java;

import hails.ext.mail.Mailer;
#if java
import java.util.Properties;
import java.lang.System;
import java.javax.mail.Message;
import java.javax.mail.Session;
import java.javax.mail.Transport;
import java.javax.mail.internet.InternetAddress;
import java.javax.mail.internet.MimeMessage;
#end

/**
 * Requires javamail
 * Get it at: 
 * http://javamail.java.net/
 * or
 * http://www.oracle.com/technetwork/java/javamail/index-138643.html
 * put mail.jar into <project>\war\WEB-INF\lib\
 * Then add the path in haxeconfig like this:
	 javalibs: war\WEB-INF\lib\mail.jar
 */
class JavaMailSender extends Mailer
{
	#if java
	public override function send():Bool {
		var ok = false;
		try
        {
			var props:Properties = System.getProperties();
			props.put("mail.transport.protocol", "smtp");
			props.put("mail.smtp.port", this.port); 
			
			// Set properties indicating that we want to use STARTTLS to encrypt the connection.
			// The SMTP session will begin on an unencrypted connection, and then the client
			// will issue a STARTTLS command to upgrade to an encrypted connection.
			props.put("mail.smtp.auth", this.smtpAuth ? "true" : "false");
			if (this.smtpSecure) {
				props.put("mail.smtp.starttls.enable", "true");
				props.put("mail.smtp.starttls.required", "true");
			}

			// Create a Session object to represent a mail session with the specified properties. 
			var session:Session = Session.getDefaultInstance(props);

			// Create a message with the specified information. 
			var msg:MimeMessage = new MimeMessage(session);
			msg.setFrom(new InternetAddress(this.from));
			var toAddress = new InternetAddress(this.to);
			untyped __java__("msg.setRecipient(javax.mail.Message.RecipientType.TO, toAddress);");
			msg.setSubject(this.subject);
			msg.setContent(this.body,"text/plain");
				
			// Create a transport.        
			var transport:Transport = session.getTransport();
			try {		
				// Send the message.
				transport.connect(this.host, this.username, this.password);
				
				// Send the email.
				transport.sendMessage(msg, msg.getAllRecipients());
				//trace("Email sent!");
				ok = true;
			} catch (ex:java.lang.Exception) {
				errorInfo = ex.getMessage();
			}
			transport.close();   
        }
        catch (ex:java.lang.Exception) {
            errorInfo = ex.getMessage();
        }		
		return ok;
	}
	#end
}