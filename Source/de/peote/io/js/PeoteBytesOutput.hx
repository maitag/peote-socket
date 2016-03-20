package de.peote.io.js;

import haxe.io.Bytes;
import haxe.io.Error;
/**
 * ...
 * @author Sylvio Sell
 */

@:keep
@:expose("PeoteBytesOutput") class PeoteBytesOutput
{
	static function main() {}
	
	var bytes:Array<Int>;
	
	public var length(get, null):Int;

	function get_length() {
		return bytes.length;
	}
	
	public function new() {
		bytes = new Array();
	}
	
	public inline function writeByte(b:Int):Void {
		bytes.push(b);
	}
	
	public inline  function writeUInt16(b:Int) {
		bytes.push( (b >> 0 ) & 255);
		bytes.push( (b >> 8 ) & 255);
	}
	
	public inline function writeInt16(b:Int):Void {
		bytes.push( (b >> 0 ) & 255);
		if (b >= -32768 && b < 0) {
			bytes.push( ( (b >> 8 ) & 127) + 128  );
		}
		else if (b < 32768) {
			bytes.push( (b >> 8 ) & 127 );
		}
		else throw Error.Overflow;
	}
	
	public inline function writeInt32(b:Int):Void {
		bytes.push( (b >> 0 ) & 255);
		bytes.push( (b >> 8 ) & 255);
		bytes.push( (b >> 16) & 255);
		bytes.push( (b >> 24) & 255);
	}
	
	public inline function writeFloat(f:Float):Void {
		var b:Bytes = Bytes.alloc(4);
		b.setFloat(0, f);
		writeInt32(b.getInt32(0));
	}
	
	public inline function writeDouble(f:Float):Void {
		var b = Bytes.alloc(8);
		b.setDouble(0, f);
		writeInt32(b.getInt32(0));
		writeInt32(b.getInt32(4));
	}
	
	public inline function writeString(s:String):Void {
		var b = Bytes.ofString(s);
		writeUInt16(s.length);
		for (i in 0...b.length) bytes.push(b.get(i));
	}
	// TODO: only this is need if PeoteBytesOutput extends BytesOutput
	// only return b property  (this is Array for Javascript)
	public inline function getBytes():Array<Int> {
		return(bytes);
	}
	
}