package hails.hailsservlet.neko;

import haxe.ds.StringMap;
import neko.Lib;
import neko.Web;

class Session {
  public static var started(default, null) : Bool;
  public static var id : String;
  public static var savePath/*(default, set_SavePath)*/ : String;
  private static var sessionData : StringMap<Dynamic>;
  public static var sessionName/*(default, set_Name)*/ : String;
  private static var needCommit : Bool;
  
    public static function getCacheLimiter() {
       trace("not implemented");
        return null;
    }    
    
    public static function setCacheLimiter(l : CacheLimiter) {
       trace("not implemented");
    }
    
    public static function getCacheExpire() : Int {
       trace("not implemented");
       return 0;
    }
    
    public static function setCacheExpire(minutes : Int) {
       trace("not implemented");
    }
    
    public static function setName(name : String) {
      if( started ) throw "Can't set name after Session start";
       sessionName = name;
       return name;
    }
    
    public static function getName() : String {
       return sessionName;
    }
    
    public static function getId() : String { return id; }    
    public static function setId(_id : String) : String{
      if( started ) throw "Can't set id after Session.start";
      id = _id;
      return id;
    }

    public static function getSavePath() : String { return savePath; }
    
    public static function setSavePath(path : String) : String {
        if(started) throw "You can't set the save path while the session is already in use";
        savePath = path;
        return path;
    }
    
    public static function getModule() : String {
       trace("not implemented");
       return "";
    }
    
    public static function setModule(module : String) {
        if(started) throw "You can't set the module while the session is already in use";
       trace("not implemented");
       return "";
    }
    
    public static function regenerateId(?deleteold : Bool) : Bool {
       trace("not implemented");
       return false;
    }
    
    public static function get(name : String) : Dynamic {
        start();
        return sessionData.get(name); 
    }
    
    public static function set(name : String, value : Dynamic) {
        start();
        needCommit = true;
        sessionData.set(name, value);
		commit();
    }
    
    public static function setCookieParams(?lifetime : Int, ?path : String, ?domain : String, ?secure : Bool, ?httponly : Bool) {
        if(started) throw "You can't set the cookie params while the session is already in use";
       trace("not implemented");
    }
    
    public static function getCookieParams() : { lifetime : Int, path : String, domain : String, secure : Bool, httponly : Bool} {
       trace("not implemented");
       return null;
    }
    
    public static function setSaveHandler(open : String -> String -> Bool, close : Void -> Bool, read : String -> String, write : String -> String -> Bool, destroy, gc) : Bool {
       trace("not implemented");
       return false;
    }
    
    public static function exists(name : String) {
        start();
        return sessionData.exists(name);
    }
    
    public static function remove(name : String) {
        start();
        needCommit = true;
        sessionData.remove(name);
    }
    
    public static function start() {
        if(started) return;
        needCommit = false;
        if ( sessionName == null ) sessionName = "HXSESSIONID";
		
    if( savePath == null ) savePath = Sys.getCwd();

        if( id==null ){
      var params = Web.getParams();
      id = params.get(sessionName);
      // trace("getting id from req");
    }
    if( id==null ){
      var cookies = Web.getCookies();
      id = cookies.get(sessionName);
      // trace("getting id from cookie");
    }
    if( id==null ){
      var args = Sys.args();
      for( a in args ){
        var s = a.split("=");
        trace(s);
        if( s[0] == sessionName ){
          id=s[1];
          break;
        }
      }
      // trace("getting id from command line");
    }
    var file : String;
    var fileData : String;
    if( id!=null ){
      file = savePath + id + ".sess";
      if( !sys.FileSystem.exists(file) ) id = null;
      else{
        fileData = try sys.io.File.getContent(file) catch ( e:Dynamic ) null;
        if( fileData == null ){
          id = null;
          try sys.FileSystem.deleteFile(file) catch( e:Dynamic ) null;
        }else{
          sessionData = haxe.Unserializer.run(fileData);
        }
      } 
    }
    if( id==null ){
      //trace("no id found, creating a new session.");
      sessionData = new StringMap<Dynamic>();
      do{
        id = haxe.crypto.Md5.encode(Std.string(Math.random()));
        file = savePath + id + ".sess";
      }while( sys.FileSystem.exists(file) );
      started = true;
      commit();
    }
	Web.setCookie(sessionName, id);
    started = true;
    }
    
    public static function clear() {
        sessionData = new StringMap<Dynamic>();
    }
    private static function commit(){
      if( !started ) return;
        var w = sys.io.File.write(savePath + id + ".sess", true);
        w.writeString( haxe.Serializer.run( sessionData ) );
        w.close();
  }
    public static function close() {
      if( needCommit ) commit();
        started = false;
    }
}

enum CacheLimiter {
    Public;
    Private;
    NoCache;
    PrivateNoExpire;
}