/**
* ...
* @author Default
*/

package hails.util;

class GDImage {

	public var im:Dynamic;
	public var bgColor:Int;
	
	/*public function new(width:Int, height:Int, bgR:Int, bgG:Int, bgB:Int) {
		this.im = untyped __call__("@imagecreate", width, height);
		this.bgColor = allocColor(bgR, bgG, bgB);
	}*/
	public function new() {
		
	}
	
	public static function createNew(width:Int, height:Int, ?bgColor:{r:Int,g:Int,b:Int}) : GDImage {
		var ret = new GDImage();
		ret.im = untyped __call__("@imagecreatetruecolor", width, height);
		if (bgColor != null) {
			ret.bgColor = ret.allocColor(bgColor.r, bgColor.g, bgColor.b);
		}
		return ret;
	}
	
	public static function createFromString(data:String) : GDImage {
		var ret = new GDImage();
		ret.im = untyped __call__('imagecreatefromstring', data);
		return ret;
	}
	
	public static function createFromJpeg(path:String) : GDImage {
		var ret = new GDImage();
		ret.im = untyped __call__('imagecreatefromjpeg', path);
		return ret;
	}

	public static function createFromPng(path:String) : GDImage {
		var ret = new GDImage();
		ret.im = untyped __call__('imagecreatefrompng', path);
		return ret;
	}
	
	public function getWidth() : Int {
		return untyped __call__('imagesx', im);
	}

	public function getHeight() : Int {
		return untyped __call__('imagesy', im);
	}
	
	public function scaleByWidth(newX:Int) : GDImage {
		var origX = getWidth();
		var origY = getHeight();
		var newY:Int = Math.round((origY * newX) / origX);
		var ret:GDImage = GDImage.createNew(newX, newY);
		untyped __call__('imagecopyresampled', ret.im, this.im, 0, 0, 0, 0, 
			newX, newY, origX, origY);
		return ret;
	}

	public function scaleByHeight(newY:Int) : GDImage {
		var origX = getWidth();
		var origY = getHeight();
		var newX:Int = Math.round((origX * newY) / origY);
		var ret:GDImage = GDImage.createNew(newX, newY);
		untyped __call__('imagecopyresampled', ret.im, this.im, 0, 0, 0, 0, 
			newX, newY, origX, origY);
		return ret;
	}
	
	public function outputPNG() : Bool{
		return untyped __call__("imagepng", this.im);
	}
	
	public function outputJPEG() : Bool{
		return untyped __call__("imagejpeg", this.im);
	}
	
	public function toPNGString() : String {
		untyped __call__("ob_start");
		var ok:Bool = untyped __call__("imagepng", this.im, null);
		var ret:String = untyped __call__("ob_get_contents");
		if (ok) {
			return ret;
		}
		return null;
	}

	public function toJPEGString() : String {
		untyped __call__("ob_start");
		var ok:Bool = untyped __call__("imagejpeg", this.im, null);
		var ret:String = untyped __call__("ob_get_contents");
		if (ok) {
			return ret;
		}
		return null;
	}
	
	public function destroy() : Void {
		untyped __call__("imagedestroy", this.im);
	}
	
	public function allocColor(r:Int, g:Int, b:Int) : Int {
		return untyped __call__("imagecolorallocate", this.im, r, g, b);
	}
	
	public function writeString(x:Int, y:Int, txt:String, color:Int) : Bool {
		return untyped __call__("imagestring", this.im, 1, x, y, txt, color);
	}

	public function drawEllipse(x:Int, y:Int, width:Int, height:Int, color:Int) : Bool {
		return untyped __call__("imageellipse", this.im, x, y, width, height, color);
	}
	
	public function drawLine(x1:Int, y1:Int, x2:Int, y2:Int, color:Int) : Bool {
		return untyped __call__("imageline", this.im, x1, y1, x2, y2, color);
	}
	
	public function drawPixel(x:Int, y:Int, color:Int) : Bool {
		return untyped __call__("imagesetpixel", this.im, x, y, color);
	}
	
	/**
	 * 
	 * @param	pixels	An array of int, where 0 means do NOT plot, and anything else means do plot.
	 * @param	x
	 * @param	y
	 * @param	color
	 */
	public function drawPixelRow(pixels:Array < Int > , x:Int, y:Int, color:Int) {
		for ( i in 0...pixels.length ) {
			if (pixels[i] > 0) {
				drawPixel(x + i, y, color);
			}
		}
	}
	
	public function drawPixelRows(pixels:Array<Array<Int>>, x:Int, y:Int, color:Int) {
		for ( i in 0...pixels.length ) {
			drawPixelRow(pixels[i], x, y + i, color);
		}
	}
}