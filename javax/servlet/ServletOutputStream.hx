package javax.servlet;
import java.NativeArray.NativeArray;
import java.StdTypes.Int8;

/**
 * ...
 * @author test
 */
extern class ServletOutputStream
{
	@:overload public function print(s:String) : Void;
	@:overload public function println(s:String) : Void;
	@:overload public function flush() : Void;
	@:overload public function write(b:NativeArray<Int8>) : Void;
}