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
	
	public function writeBool(b:Bool):Void
	{
		if (b) writeByte(1) else writeByte(0);
	}

	override public function writeString(s:String):Void
	{
		//writeUInt16(s.length); // did not work in flash
		writeUInt16(haxe.io.Bytes.ofString(s).length); // OK (flash and windows-cpp) TODO: variable chunkssize
		super.writeString(s);
	}
	
	override public function write(b:haxe.io.Bytes):Void
	{
		writeUInt16(b.length); // TODO: variable chunkssize
		super.write(b);
	}
}
