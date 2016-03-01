package;

import lime.app.Application;

import de.peote.io.PeoteBytes;
import de.peote.io.PeoteBytesInput;
import de.peote.io.PeoteBytesOutput;
/*import haxe.io.Bytes;
import haxe.io.BytesData;*/


import de.peote.socket.PeoteSocket;

class PeoteSocketTest extends Application {
	
	public var peoteSocket:PeoteSocket;
	
	public function new () {
		
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
					trace("onError:"+msg);
				},
				onData: onData
		});
		peoteSocket.connect("192.168.1.50", 23);
		
	}
	
	public inline function sendTestData():Void
	{	
		var output:PeoteBytesOutput = new PeoteBytesOutput();
		
		output.writeByte(255);
		output.writeInt16(12345);
		output.writeInt32(123456789);
		output.writeFloat(1.2345678);
		output.writeDouble(1.2345678901234567890123456789);
		output.writeString("Hello Server");
		
		peoteSocket.writeBytes( output.getBytes() ); // send chunk
	}
	
	public inline function onData(peoteBytes:PeoteBytes ):Void 
	{
		trace("onData:");

		var input:PeoteBytesInput = new PeoteBytesInput(peoteBytes);
		trace( "data bytes length = " + input.length);
		while (input.position < input.length)
		{
			trace(input.position + ":" + input.readByte());
		}
		/*
		trace(input.readInt16());
		trace(input.readInt32());
		trace(input.readFloat());
		trace(input.readDouble());
		trace(input.readString());
		*/
		
	}

}
