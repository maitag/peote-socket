package de.peote.io.js;

import haxe.io.Bytes;

/**
 * ...
 * @author Sylvio Sell
 */

@:keep
@:expose("PeoteBytesOutput") class PeoteBytesOutput
{
	static function main() {}
	
	var bytes:Array<Int>;
	
	public function new() {
		bytes = new Array();
	}
	
	public inline function writeByte(b:Int):Void {
		bytes.push(b);
	}
	
	public inline function writeInt16(b:Int):Void {
		bytes.push( (b >> 0 ) & 255);
		bytes.push( (b >> 8 ) & 255);
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
		writeInt16(s.length);
		for (i in 0...b.length) bytes.push(b.get(i));
	}
	
	public inline function getBytes():Array<Int> {
		return(bytes);
	}
	
}