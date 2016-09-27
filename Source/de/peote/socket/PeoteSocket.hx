package de.peote.socket;

/**
 *  /\/\/\                     ~^
 * @author Sylvio Sell - maitag
 */
#if js
import js.html.WebSocket;
import js.html.BinaryType;
import js.html.ArrayBuffer;
import js.html.Uint8Array;
import haxe.io.Bytes;
#end

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
	public function new (param:Dynamic) {}

	public function connect(server:String, port:Int):Void {}
	public function close():Void {}
	public function writeByte(b:Int):Void {}
	public function writeBytes(data:Array<Int>):Void {}
	public function flush():Void {}	
}


// will be overridden by peoteSocketBridge.swf on load---
@:expose("PeoteSocket") class PeoteSocketWS {
	
	public function new (param:Dynamic)
	{
		trace('new PeoteSocketWS ($param)');
	}

	public function connect(server:String, port:Int):Void
	{
		trace('CONNECT $server:$port');
	}
	public function close():Void {}
	public function writeByte(b:Int):Void {}
	public function writeBytes(data:Array<Int>):Void {}
	public function flush():Void {}	

	//TODO
	/*public function new () {
		
		var ws = new WebSocket("ws://localhost:3211"); 
		
		trace('binaryType ${ws.binaryType}');
		trace('protocol: ${ws.protocol}');
		
		ws.binaryType = BinaryType.ARRAYBUFFER;
		
		
		ws.onopen = function()
		{
    		trace("CONNECT");
			trace('bufferedAmount: ${ws.bufferedAmount}');
			
   			//ws.send("TestString");
			var ab:ArrayBuffer = new ArrayBuffer(3);
			var bytes:Uint8Array = new Uint8Array(ab, 0, 3);
			//bytes.set([65, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
			bytes.set([65,66,67]);
			
   			ws.send(ab);
			
			trace('bufferedAmount: ${ws.bufferedAmount}');
			trace('binaryType: ${ws.binaryType}');
			trace('protocol: ${ws.protocol}');
		};

		ws.onmessage = function(e)
		{
   			trace("RECEIVE: " + e.data);
			var bytes:Bytes = Bytes.ofString(e.data);
			for (i in 0...bytes.length)
			{
				trace(bytes.get(i));				
			}
		};
		
		ws.onclose = function()
		{
   			trace("DISCONNECT");
		};

	}*/
	
	
}


#end
