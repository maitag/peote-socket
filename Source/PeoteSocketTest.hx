package;
/**
 * ...
 * @author Sylvio Sell
 */


import haxe.io.Bytes;
import lime.app.Application;

import peote.bridge.PeoteSocketBridge;
import peote.io.PeoteBytesInput;
import peote.io.PeoteBytesOutput;
import peote.socket.PeoteSocket;

class PeoteSocketTest extends Application {
	
	public var peoteSocket:PeoteSocket;
	
	public function new ()
	{
		super();
		// provides adresses for peote-proxy server that handles flashpolicy and websockets
		// only relevant for js or flash targets
		// (cpp will ignore this and opens directly tcp socket immediatly)
		PeoteSocketBridge.load( {
			onload: openSocket,
			//preferWebsockets: true,
			proxys: {
				proxyServerWS:"localhost",  // js websockets
				//proxyServerWS:"192.168.1.81",
				proxyPortWS  : 3211,
				
				proxyServerSWF:"localhost", // js throught peoteSocketBridge.swf
				//proxyServerSWF:"192.168.1.81",
				proxyPortSWF  :3211,
			},
			onfail: function() { trace("Browser doesn't support flash- or websockets"); }
		});
	}
	
	public function openSocket():Void
	{
		peoteSocket = new PeoteSocket( { 
				onConnect: function(connected, msg) {
					trace("onConnect:" + connected + " - " + msg);
					sendTestData();
				},
				onClose: function(msg) {
					trace("onClose:"+msg);
				},
				onError: function(msg) {
					trace("onError:"+msg);
				},
				onData: onData
		});
		peoteSocket.connect("192.168.1.81", 23);
		//peoteSocket.connect("127.0.0.1", 7685);
		//peoteSocket.connect("mud.tubmud.de", 7680);
		//peoteSocket.connect("lem", 23);
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
