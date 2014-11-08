package hails.hailsservlet.java.javax.servlet ;
import java.NativeArray.NativeArray;
import java.StdTypes.Int8;

/**
 * ...
 * @author test
 */
@:native('javax.servlet.ServletOutputStream')
extern class ServletOutputStream
{
	@:overload public function print(s:String) : Void;
	@:overload public function println(s:String) : Void;
	@:overload public function flush() : Void;
	@:overload public function write(b:NativeArray<Int8>) : Void;
}