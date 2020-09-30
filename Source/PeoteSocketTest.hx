package;

/**
 * by Sylvio Sell Rostock 2015
 * 
 */

import haxe.io.Bytes;
import lime.app.Application;

import peote.io.PeoteBytesInput;
import peote.io.PeoteBytesOutput;
import peote.socket.PeoteSocket;

class PeoteSocketTest extends Application {
	
	public var peoteSocket:PeoteSocket;
	
	public function new ()
	{
		super();
		
		peoteSocket = new PeoteSocket( { 
				onConnect: function(connected, msg) {
					trace("onConnect:" + connected + " - " + msg);
					//sendTestData();
				},
				onClose: function(msg) {
					trace("onClose:"+msg);
				},
				onError: function(msg) {
					trace("onError:" + msg);
					#if html5
					// TODO: trace("Browser doesn't support websockets")
					#end
				},
				onData: onData
		});
		#if html5
		// for html5 target a peote-proxy server is need to translate websocket-protocol into TCP
		peoteSocket.setProxy("localhost", 3211);
		#end
		peoteSocket.connect("lem", 23);
	}
	
	public inline function sendTestData():Void
	{	
		var output:PeoteBytesOutput = new PeoteBytesOutput();
		
		output.writeByte(127);
		output.writeByte(128);
		output.writeByte(129);
		output.writeByte(0);
		/*
		output.writeUInt16(65535);
		output.writeInt16(32767);
		output.writeInt16(-32768);
		output.writeInt32(2147483647);
		output.writeInt32(-2147483648);
		output.writeFloat(1.2345678);
		output.writeDouble(1.2345678901234567890123456789);
		
		output.writeString("Hello Server/n");
		output.writeByte(0);
		*/
		peoteSocket.writeBytes( output.getBytes() );
		/*
		peoteSocket.writeByte( 127 );
		peoteSocket.writeByte( 128 );
		peoteSocket.writeByte( 129 );
		*/
	}
	
	public inline function onData(bytes:Bytes ):Void 
	{
		trace("onData:");

		var input:PeoteBytesInput = new PeoteBytesInput(bytes);
		trace( "data bytes length = " + input.length);
		while (input.position < input.length)
		{
			trace(input.position + ":" + input.readByte());
		}
		/*
		trace(input.readByte());
		trace(input.readUInt16());
		trace(input.readInt16());
		trace(input.readInt32());
		trace(input.readFloat());
		trace(input.readDouble());
		trace(input.readString());
		*/
		
	}

}
