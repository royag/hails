package hails.ext.mail.php;
import hails.ext.mail.Mailer;

/**
 * Requires PHPMailerAutoload to be in PHP include path
 * Get it at https://github.com/PHPMailer/PHPMailer
 */
class PhpMailSender extends Mailer
{
	#if php
	public override function send():Bool {
		untyped __call__("require", "PHPMailerAutoload.php");
		var mail:Dynamic = untyped __call__("new PHPMailer");
		
		mail.isSMTP();                                      // Set mailer to use SMTP
		mail.Host = this.host;  // Specify main and backup SMTP servers
		mail.SMTPAuth = this.smtpAuth;                               // Enable SMTP authentication
		mail.Username = this.username;                 // SMTP username
		mail.Password = this.password;                           // SMTP password
		if (this.smtpSecure) {
			mail.SMTPSecure = 'tls';                            // Enable TLS encryption, `ssl` also accepted
		}
		mail.Port = this.port;                                    // TCP port to connect to

		mail.From = this.from;
		mail.FromName = this.fromName;
		mail.addAddress(this.to, this.toName);     // Add a recipient

		mail.Subject = this.subject;
		mail.Body    = this.body;
		var ok:Bool = mail.send();
		if (!ok) {
			this.errorInfo = mail.errorInfo;
		}
		return ok;
	}
	#end
}