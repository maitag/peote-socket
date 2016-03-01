package de.peote.io;
import de.peote.io.js.PeoteBytesInput;

/**
 * ...
 * @author Sylvio Sell
 */

#if js
	typedef PeoteBytesInput = de.peote.io.js.PeoteBytesInput;
#else
	import haxe.io.Bytes;
	import haxe.io.BytesInput;
	
	class PeoteBytesInput
	{
		public var length(get,never):Int;
		public var position(get,set):Int;
		
		var bytesInput:BytesInput;
		
		public inline function new(bytes:Bytes):Void
		{
			bytesInput = new BytesInput(bytes);
		}
		
		inline function get_length():Int { return bytesInput.length; }
		inline function get_position():Int { return bytesInput.position; }
		inline function set_position(p:Int):Int { return bytesInput.position = p; }
		
		public inline function readByte():Int { return bytesInput.readByte(); }
		public inline function readInt16():Int { return bytesInput.readInt16(); }
		public inline function readInt32():Int { return bytesInput.readInt32(); }
		public inline function readFloat():Float { return bytesInput.readFloat(); }
		public inline function readDouble():Float { return bytesInput.readDouble(); }
		
		public inline function readString():String
		{
			return bytesInput.readString(bytesInput.readInt16());
		}

	}
#end