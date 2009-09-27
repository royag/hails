/**
 * ...
 * @author ...
 */

package hails.ext;
#if js
#else
// serverside-specific imports:
import hails.html.ViewTool;
import hails.util.ServerCrossPlatform;
import hails.util.DynamicUtil;
#end
import haxe.Md5;

/**
 * ! TODO: This actually uses JQuery javascript library, and some untyped functions.
 * Of course: We'd like to use pure haxe...
 * 
 * Contains methods for serverside PHP(/Neko) and clientside JavaScript
 * to help communicating passwords over the wire, without sending passwords in cleartext.
 * 
 * This might be used for sites that have login-functionality, but are not secured with SSL.
 * This does not prevent session-hijacking. It only prevents sending passwords in clear-text.
 * It has built in easy-to-use functionality for three scenarios:
 * - Normal login (username + password)
 * - Admin setting password for other users (password + repeated password)
 * - Changing password (old password + new password + repeated new password)
 * 
 * When a password is set, only an md5-hash is sent to the server and stored in the database.
 * This means that not even the server will ever know what the users password is.
 * The only time the pure MD5-hash of the password is sent over the net, is when the password is SET/CHANGED.
 * (This MIGHT be made more secure, by using a one-time-key, encrypting the MD5... maybe in a later version ...)
 * On loading the login-page: The server creates a random "challenge" which is stored on the session.
 * When the user logs in, a MD5 hash over this "challenge" combined with the MD5-hash of the password is what sent to the server.
 * The server tries to recreate this by combining the password-MD5-hash in the DB and the random challenge stored on the session.
 * This means that every time the user logs in, a different MD5-value is sent to the server,
 * meaning it canNOT be snapped up and used a second time.
 * 
 * This might also very well be used in combination with SSL to provide maximum security.
 */
class HalfSecureLogin 
{
	static var hiddenFormName = 'hiddenForm';
	static var hiddenUsername = 'hidden_username';
	static var hiddenLogonkey = 'hiddenkey';
	
	static var pwdField = 'login_password';
	static var nameField = 'login_username';	
	
	public static function hashEncode(data:String) : String {
		// replace with other algorithm if desired (like hash.Sha1 from caffeine-hx):
		return Md5.encode(data);
	}
	
	public static function createPwdHash(password:String) {
		return hashEncode(password);
	}
	
	public static function createLoginKey(challenge:String, passwordHash:String) : String {
		return hashEncode(passwordHash + challenge);		
	}
	
	public static function encodeLogin(challenge:String, password:String) {
		var pwenc = createPwdHash(password);
		return createLoginKey(challenge, pwenc);
	}
	
	#if js
	// JavaScript-specific functions:
	public static function main() 
	{
	}
	
	public static function doLogin() {
		untyped __js__("
			$('#hidden_username').attr('value', $('#login_username').attr('value'));
			$('#hiddenkey').attr('value', 
				hails.ext.HalfSecureLogin.encodeLogin($('#challenge').attr('value'), $('#login_password').attr('value')));
			$('#hiddenForm').submit();
		");
	}
	
	public static function doChangePwd() {
		untyped __js__("
			$('#hidden_newpw1').attr('value', 
				hails.ext.HalfSecureLogin.createPwdHash($('#newpw1').attr('value')));
			$('#hidden_newpw2').attr('value', 
				hails.ext.HalfSecureLogin.createPwdHash($('#newpw2').attr('value')));
			$('#hiddenkey').attr('value', 
				hails.ext.HalfSecureLogin.encodeLogin($('#challenge').attr('value'), $('#login_password').attr('value')));
			$('#hiddenForm').submit();
		");
	}
	
	public static function doSetPwd() {
		untyped __js__("
			$('#hidden_newpw1').attr('value', 
				hails.ext.HalfSecureLogin.createPwdHash($('#newpw1').attr('value')));
			$('#hidden_newpw2').attr('value', 
				hails.ext.HalfSecureLogin.createPwdHash($('#newpw2').attr('value')));
			$('#hiddenkey').attr('value', 
				hails.ext.HalfSecureLogin.encodeLogin($('#challenge').attr('value'), $('#newpw1').attr('value')));
			$('#hiddenForm').submit();
		");
	}

	#else
	// ServerSide-specific functions:
	static var thisClassName = 'hails.ext.HalfSecureLogin';
	static var CHALLENGE = 'CHALLENGE';
	public static function createChallenge() {
		return Std.string(Math.round(Math.random() * 10000000 + Math.random() * 10000000));
	}
	
	public static function putChallengeOnSession() {
		return ServerCrossPlatform.setSession(CHALLENGE, createChallenge());
	}
	
	public static function getChallengeFromSession() {
		return ServerCrossPlatform.getSession(CHALLENGE);
	}
	
	public static function clearChallenge() {
		ServerCrossPlatform.setSession(CHALLENGE, null);
	}
	
	public static function renderNewLoginForm(?options:Dynamic) : String {
		var submitPath:String = DynamicUtil.fieldOrDefault(options, 'submitPath', ViewTool.pathTo('session'));
		var namePrompt:String = DynamicUtil.fieldOrDefault(options, 'namePrompt', 'Brukernavn:');
		var pwdPrompt:String = DynamicUtil.fieldOrDefault(options, 'pwdPrompt', 'Passord:');
		var loginScript:String = DynamicUtil.fieldOrDefault(options, 'loginScript', 'login.js');
		var buttonText:String = DynamicUtil.fieldOrDefault(options, 'buttonText', 'Logg inn');
		var extraFormData:String = DynamicUtil.fieldOrDefault(options, 'extraFormData', '');
		var submitOnEnterField:String = DynamicUtil.fieldOrDefault(options, 'submitOnEnterField', 'login_password');
		
		putChallengeOnSession();
		var challenge = getChallengeFromSession();
		
		return
		'<script type="text/javascript" src="'+ViewTool.pathToResource(loginScript)+'"></script>' +
		'<input id="challenge" type="hidden" value="' + challenge + '"/>' +
		
		'<table id="loginFormTable" class="securePasswordTable">' +
		'<tr><td>' + namePrompt + '</td><td>' + '<input id="'+nameField+'" /><br/>' + '</td></tr>' +
		'<tr><td>' + pwdPrompt + '</td><td>' + '<input type="password" id="'+pwdField+'" /><br/>' + '</td></tr>' +
		'<tr><td>' + '<input id="loginButton" type="button" value="' + buttonText + '" onclick="javascript:' + thisClassName + '.doLogin();" />' + '</td></tr>' +
		'</table>' +
		
		'<form action="'+submitPath+'" method="post" id="'+hiddenFormName+'">' +
		'<input type="hidden" name="'+hiddenUsername+'" id="'+hiddenUsername+'"/>' +
		'<input type="hidden" name="' + hiddenLogonkey + '" id="' + hiddenLogonkey + '"/>' +
		extraFormData + 
		'</form>' +
		
		'<script language="javascript">'+
		'	$(document).ready(function() {' +
		'       $("#'+nameField+'").focus();' +
		'		$("#'+submitOnEnterField+'").keyup(function(e) { if (e.keyCode == 13) { hails.ext.HalfSecureLogin.doLogin(); }} );' +
		'	});' +
		'	$(document).ready(function() {' +
		'		$("#loginButton").keyup(function(e) { if (e.keyCode == 13) { hails.ext.HalfSecureLogin.doLogin(); }} );' +
		'	});' +
		'</script>';
		
	}
	
	public static function renderSetPwdForm(?options:Dynamic) : String {
		var submitPath:String = DynamicUtil.fieldOrDefault(options, 'submitPath', ViewTool.pathTo('password'));
		var namePrompt:String = DynamicUtil.fieldOrDefault(options, 'namePrompt', 'Brukernavn:');
		var newPwdPrompt:String = DynamicUtil.fieldOrDefault(options, 'newPwdPrompt', 'Passord:');
		var repeatPwdPrompt:String = DynamicUtil.fieldOrDefault(options, 'repeatPwdPrompt', 'Gjenta Passord:');
		var loginScript:String = DynamicUtil.fieldOrDefault(options, 'loginScript', 'login.js');
		var buttonText:String = DynamicUtil.fieldOrDefault(options, 'buttonText', 'Sett passord');
		var submitOnEnterField:String = DynamicUtil.fieldOrDefault(options, 'submitOnEnterField', 'newpw2');
		var extraFormData:String = DynamicUtil.fieldOrDefault(options, 'extraFormData', '');
		
		putChallengeOnSession();
		var challenge = getChallengeFromSession();
		
		return
		'<script type="text/javascript" src="'+ViewTool.pathToResource(loginScript)+'"></script>' +
		'<input id="challenge" type="hidden" value="' + challenge + '"/>' +
		
		'<table id="setPasswordFormTable" class="securePasswordTable">' +
		'<tr><td>' + newPwdPrompt + '</td><td>' + '<input type="password" id="newpw1" /><br/>' + '</td></tr>' +
		'<tr><td>' + repeatPwdPrompt + '</td><td>' + '<input type="password" id="newpw2" /><br/>' + '</td></tr>' +
		'<tr><td>' + '<input id="setPwdButton"  type="button" value="' + buttonText + '" onclick="javascript:' + thisClassName + '.doSetPwd();" />' + '</td></tr>' +
		'</table>' +
		
		'<form action="'+submitPath+'" method="post" id="'+hiddenFormName+'">' +
		'<input type="hidden" name="pwaction" value="set"/>' +
		'<input type="hidden" name="hidden_newpw1" id="hidden_newpw1"/>' +
		'<input type="hidden" name="hidden_newpw2" id="hidden_newpw2"/>' +
		'<input type="hidden" name="hiddenkey" id="hiddenkey"/>' +
		extraFormData + 
		'</form>' +
		'<script language="javascript">'+
		'	$(document).ready(function() {' +
		'       $("#newpw1").focus();' +
		'		$("#'+submitOnEnterField+'").keyup(function(e) { if (e.keyCode == 13) { hails.ext.HalfSecureLogin.doSetPwd(); }} );' +
		'	});' +
		'	$(document).ready(function() {' +
		'		$("#setPwdButton").keyup(function(e) { if (e.keyCode == 13) { hails.ext.HalfSecureLogin.doSetPwd(); }} );' +
		'	});' +
		'</script>';
	}
	
	public static function renderChangePwdForm(?options:Dynamic) : String {
		var submitPath:String = DynamicUtil.fieldOrDefault(options, 'submitPath', ViewTool.pathTo('password'));
		var namePrompt:String = DynamicUtil.fieldOrDefault(options, 'namePrompt', 'Brukernavn:');
		var oldPwdPrompt:String = DynamicUtil.fieldOrDefault(options, 'oldPwdPrompt', 'Gammelt Passord:');
		var newPwdPrompt:String = DynamicUtil.fieldOrDefault(options, 'newPwdPrompt', 'Nytt Passord:');
		var repeatPwdPrompt:String = DynamicUtil.fieldOrDefault(options, 'repeatPwdPrompt', 'Gjenta Nytt Passord:');
		var loginScript:String = DynamicUtil.fieldOrDefault(options, 'loginScript', 'login.js');
		var buttonText:String = DynamicUtil.fieldOrDefault(options, 'buttonText', 'Endre passord');
		var extraFormData:String = DynamicUtil.fieldOrDefault(options, 'extraFormData', '');
		var submitOnEnterField:String = DynamicUtil.fieldOrDefault(options, 'submitOnEnterField', 'newpw2');
		
		putChallengeOnSession();
		var challenge = getChallengeFromSession();
		
		return
		'<script type="text/javascript" src="'+ViewTool.pathToResource(loginScript)+'"></script>' +
		'<input id="challenge" type="hidden" value="' + challenge + '"/>' +
		
		'<table id="changePasswordFormTable" class="securePasswordTable">' +
		'<tr><td>' + oldPwdPrompt + '</td><td>' + '<input type="password" id="'+pwdField+'" /><br/>' + '</td></tr>' +
		'<tr><td>' + newPwdPrompt + '</td><td>' + '<input type="password" id="newpw1" /><br/>' + '</td></tr>' +
		'<tr><td>' + repeatPwdPrompt + '</td><td>' + '<input type="password" id="newpw2" /><br/>' + '</td></tr>' +
		'<tr><td>' + '<input id="changePwdButton" type="button" value="' + buttonText + '" onclick="javascript:' + thisClassName + '.doChangePwd();" />' + '</td></tr>' +
		'</table>' +
		
		'<form action="'+submitPath+'" method="post" id="'+hiddenFormName+'">' +
		'<input type="hidden" name="pwaction" value="change"/>' +
		'<input type="hidden" name="hidden_newpw1" id="hidden_newpw1"/>' +
		'<input type="hidden" name="hidden_newpw2" id="hidden_newpw2"/>' +
		'<input type="hidden" name="hiddenkey" id="hiddenkey"/>' +
		extraFormData + 
		'</form>' +
		'<script language="javascript">'+
		'	$(document).ready(function() {' +
		'       $("#'+pwdField+'").focus();' +
		'		$("#'+submitOnEnterField+'").keyup(function(e) { if (e.keyCode == 13) { hails.ext.HalfSecureLogin.doChangePwd(); }} );' +
		'	});' +
		'	$(document).ready(function() {' +
		'		$("#changePwdButton").keyup(function(e) { if (e.keyCode == 13) { hails.ext.HalfSecureLogin.doChangePwd(); }} );' +
		'	});' +
		'</script>';
	}
	
	public static function getPasswordAction() : String {
		return ServerCrossPlatform.getParam('pwaction');
	}
	
	public static function getEnteredUsername() : String {
		return ServerCrossPlatform.getParam(hiddenUsername);
	}
	
	public static function setPwdOk() : Bool {
		var pw1 = ServerCrossPlatform.getParam('hidden_newpw1');
		var pw2 = ServerCrossPlatform.getParam('hidden_newpw2');
		return ((pw1 == pw2) && passwordHashMatches(pw1));
	}
	
	public static function changePwdOk(oldPasswordHash:String) : Bool {
		var pw1 = ServerCrossPlatform.getParam('hidden_newpw1');
		var pw2 = ServerCrossPlatform.getParam('hidden_newpw2');
		return ((pw1 == pw2) && passwordHashMatches(oldPasswordHash));
	}
	
	/**
	 * When action is "change" password, the old passord hash must be provided.
	 * When action is "set" password, it can be called without parameters.
	 * @param	?oldPasswordHash
	 */
	public static function getNewPasswordHash(?oldPasswordHash:String) {
		var pwaction = getPasswordAction();
		if (pwaction == 'set') {
			if (!setPwdOk()) {
				throw "Set Password Not OK";
			}
		} else if (pwaction == 'change') {
			if (!changePwdOk(oldPasswordHash)) {
				throw "Change password Not OK";
			}
		} else {
			throw "Passwordaction not specified";
		}
		return ServerCrossPlatform.getParam('hidden_newpw1');
	}
	
	public static function passwordHashMatches(passwordHash:String) : Bool {
		var key:String = ServerCrossPlatform.getParam(hiddenLogonkey);
		return (key == createLoginKey(getChallengeFromSession(), passwordHash));
	}
	
	#end
		
}