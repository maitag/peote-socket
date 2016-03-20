package de.peote.io.js;

import haxe.io.Bytes;

/**
 * ...
 * @author Sylvio Sell
 */

@:keep
@:expose("PeoteBytesInput") class PeoteBytesInput
{
	static function main() {}
	
	public var bytes:Array<Int>;
	
	//public var length(get,never):Int;
	public var length:Int = 0;
	public var position:Int = 0;
	
	// TODO: getter not work for exposed class ?
	//inline function get_length():Int { return bytes.length; }
	
	public function new(b:Array<Int>=null):Void {
		if (b != null) bytes = b;
		else bytes = new Array<Int>();
		
		length = this.bytes.length;
	}
	
	public inline function bytesLeft():Int {
		return length - position;
	}
	/*
	public static function alloc( length : Int ) : PeoteBytesInput {
		var b:Array<Int> = new Array();
		b[length-1] = 0;
		return new PeoteBytesInput(b);
	}
	*/
	public inline function append(b:Array<Int>, max_pos_before_trim:Int = 1024):Void {
		if (max_pos_before_trim != 0 && position >= max_pos_before_trim)
		{
			bytes = bytes.splice(position, bytesLeft() ).concat(b);
			position = 0;
		}
		else bytes = bytes.concat(b);		
		
		length = bytes.length;
	}
	
	
	// ---------------------------------------------------------------------
	// -----------------  read simple Datatypes ----------------------------
	// ---------------------------------------------------------------------
	
	public inline function readByte():Int {
		return bytes[position++];
	}
	
	public inline function readUInt16():Int {
		position += 2;
		return (
			(bytes[position - 1] << 8 ) |
			(bytes[position - 2] << 0 )
		);
	}
	
	public inline function readInt16():Int {
		position += 2;
		var output:Int = ( bytes[position - 1] << 8 ) | (bytes[position - 2] << 0 );
		if (output > 32767) output = output - 65536;
		return ( output );
	}
		
	public inline function readInt32():Int {
		position += 4;
		return (
			(bytes[position - 1] << 24 ) |
			(bytes[position - 2] << 16 ) |
			(bytes[position - 3] << 8 )  |
			(bytes[position - 4] << 0)
		);
	}
	
	public inline function readFloat():Float {
		var b:Bytes = Bytes.alloc(4);
		b.setInt32(0, readInt32() );
		return b.getFloat(0);
	}
	
	public inline function readDouble():Float {
		var b:Bytes = Bytes.alloc(8);
		b.setInt32(0, readInt32() );
		b.setInt32(4, readInt32() );
		return b.getDouble(0);
	}
	
	public inline function readString():String
	{
		var len:Int = readUInt16();
		//var b:Bytes = Bytes.alloc(len * 4);
		var b:Bytes = Bytes.alloc(len);
		
		//for (i in 0...len) b.setInt32(i * 4, readInt32() );
		for (i in 0...len) b.set(i, readByte() );
		
		return b.getString(0, len);
	}
	
}