package peote.io;

/**
 * by Sylvio Sell - Rostock 2015
 * 
 */

#if expose_js
@:keep
@:expose("PeoteBytesOutput")
#end
class PeoteBytesOutput extends haxe.io.BytesOutput
{
	#if expose_js static function main() {} #end

	override public function writeString(s:String):Void
	{
		//writeUInt16(s.length); // did not work in flash
		writeUInt16(haxe.io.Bytes.ofString(s).length); // OK (flash and windows-cpp)
		super.writeString(s);
	}
}
