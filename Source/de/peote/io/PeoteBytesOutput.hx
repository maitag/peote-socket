package de.peote.io;

import de.peote.io.js.PeoteBytesOutput;
/**
 * ...
 * @author Sylvio Sell
 */

#if js
	typedef PeoteBytesOutput = de.peote.io.js.PeoteBytesOutput;
#else
	class PeoteBytesOutput extends haxe.io.BytesOutput
	{
		override public function writeString(s:String):Void
		{
			//writeUInt16(s.length); // did not work in flash
			writeUInt16(haxe.io.Bytes.ofString(s).length); // OK (flash and windows-cpp)
			super.writeString(s);
		}
	}
#end