package peote.io;

/**
 * by Sylvio Sell - Rostock 2015
 * 
 */

import haxe.io.Bytes;
import haxe.io.BytesOutput;

class PeoteBytesOutput extends BytesOutput
{	
	var maxBytesPerChunkSize:Int;

	public function new(maxBytesPerChunkSize:Int = 4, ?bigEndian:Null<Bool>):Void
	{
		super();		
		this.maxBytesPerChunkSize = maxBytesPerChunkSize;		
		if (bigEndian != null) this.bigEndian = bigEndian;
	}
	
	public inline function writeBool(b:Bool):Void
	{
		if (b) writeByte(1) else writeByte(0);
	}

	override public function writeString(s:String#if (haxe_ver >= "4.0.0"), ?encoding:haxe.io.Encoding#end):Void
	{
		//writeUInt16(s.length); // did not work in flash
		writeChunkSize(Bytes.ofString(s).length); // OK (flash and windows-cpp) TODO: variable chunkssize
		// TODO: maybe s.length ?
		super.writeString(s#if (haxe_ver >= "4.0.0"), encoding#end);
	}
	
	override public function write(b:haxe.io.Bytes):Void
	{
		writeChunkSize(b.length); // TODO: variable chunkssize
		super.write(b);
	}
	
	public function writeChunkSize(chunk_size:Int):Void
	{
		//trace("PeoteBytesOutput - writeChunkSize:", chunk_size);
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
