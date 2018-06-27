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
		writeChunkSize(haxe.io.Bytes.ofString(s).length); // OK (flash and windows-cpp) TODO: variable chunkssize
		super.writeString(s);
	}
	
	override public function write(b:haxe.io.Bytes):Void
	{
		writeChunkSize(b.length); // TODO: variable chunkssize
		super.write(b);
	}
	
	public static inline var maxBytesPerChunkSize = 4;
	public function writeChunkSize(chunk_size:Int):Void
	{
		if (chunk_size < 0) throw("Error(writeChunkSize): can't handle negative chunksize");
		
		var chunkBytecount:Int = 0;
		var byte:Int;
		
		do
		{
			chunkBytecount++;
			if (chunkBytecount < maxBytesPerChunkSize) {
				byte = chunk_size & 127; // get 7 bits
				chunk_size = chunk_size >> 7;
			}
			else {
				byte = chunk_size & 255; // last get 8 bits
				chunk_size = chunk_size >> 8;
			}
			
			if (chunk_size > 0) byte += 128;
			
			writeByte(byte);
			
		}
		while (chunk_size > 0 && chunkBytecount < maxBytesPerChunkSize);

		if (chunk_size > 0) throw('chunksize to great for maxBytesPerChunkSize=$maxBytesPerChunkSize');
	}

}
