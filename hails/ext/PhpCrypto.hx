package hails.ext;
import haxe.io.Bytes;
import haxe.io.BytesData;
import php.Lib;
import php.NativeArray;

/**
 * ...
 * @author roy
 */
class PhpCrypto
{

	public function new() 
	{
		
	}
	#if php
	
	public static function test1() :String{
		var ret = "";
		
		var len = 8;
		var b:BytesData = getRandomBytes(len);
		
		ret += "8 random bytes: ";
		var bytes = Bytes.ofData(b);
		for (i in 0...len) {
			ret += Std.string(bytes.get(i))+ ",";
		}
		ret += "<br>";
		
		var key:BytesData = getRandomBytes(32);
		var iv:BytesData = getRandomBytes(16);
		var plain = "Hello there you";
		var method = "AES-256-CBC";
		var encrypted = encryptSymmetric(Bytes.ofString(plain).getData(), method, key, iv);
		var decrypted = decryptSymmetric(encrypted, method, key, iv);
		ret += "PLAIN: " + plain +"<br>";
		ret += "encrypted: " + Std.string(encrypted) +"<br>";
		ret += "decrypted: " + Std.string(decrypted) +"<br>";
		
		//var hash = digest(Bytes.ofString(plain).getData(), "SHA256");
		//ret += "SHA256: " + Std.string(hash) + "<br>";
		for (s in getDigestMethods()) {
			ret += s + ",";
		}
		ret += "<br>";
		for (s in getCipherMethods()) {
			ret += s + ",";
		}
		ret += "<br>";
		
		ret += "JAU";
	    
		return ret;
		
	}
	
	public static function encryptSymmetric(plainData:BytesData, method:String, secretKey:BytesData, iv:BytesData) : BytesData {
		return untyped __call__("openssl_encrypt", plainData, method, secretKey, 0, iv);
	}

	public static function decryptSymmetric(encryptedData:BytesData, method:String, secretKey:BytesData, iv:BytesData) : BytesData {
		return untyped __call__("openssl_decrypt", encryptedData, method, secretKey, 0, iv);
	}
	
	public static function digest(data:BytesData, method:String) : BytesData {
		return untyped __call__("openssl_digest", data, method, true); // crashes some misconfigured apache-servers
	}
	
	public static function getDigestMethods() : Array<String> {
		return untyped Lib.toHaxeArray(untyped __call__("openssl_get_md_methods"));
	}
	public static function getCipherMethods() : Array<String> {
		return untyped Lib.toHaxeArray(untyped __call__("openssl_get_cipher_methods"));
	}
	
	public static function getRandomBytes(len:Int) : BytesData {
		var cryptoSafe : Bool = false;
		var ret:BytesData = untyped __call__("openssl_random_pseudo_bytes", len, cryptoSafe);
		
		if (!cryptoSafe) {
			throw "Oh no! random bytes not safe!";
		}
		return ret;
	}
	
	
	#end
	
}