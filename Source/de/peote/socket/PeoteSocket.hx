package de.peote.socket;
/**
 *  /\/\/\                     ~^
 * @author Sylvio Sell - maitag
 */


#if cpp
typedef PeoteSocket = de.peote.socket.cpp.PeoteSocket;
#end

#if flash
typedef PeoteSocket = de.peote.socket.flash.PeoteSocket;
#end


// wrapping around pre generated PeoteSocketBridge.swf

#if js

@:native('PeoteSocket') extern class PeoteSocket
{
	public function new (o:Dynamic) {}

	public function connect(server:String, port:Int):Void {}
	public function close():Void {}
	public function writeByte(b:Int):Void {}
	public function writeBytes(data:Array<Int>):Void {}
	public function flush():Void {}	
}
#end
