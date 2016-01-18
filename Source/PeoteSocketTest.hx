package;

import lime.app.Application;
import haxe.Timer;

#if flash
import flash.utils.ByteArray;
#else
import haxe.io.Bytes;
import haxe.io.BytesData;
#end

import de.peote.socket.PeoteSocket;

class PeoteSocketTest extends Application {
	
	public var peoteSocket:PeoteSocket;
	
	public function new () {
		
		super();
		
		peoteSocket = new PeoteSocket( { 
				onConnect: function(connected, msg) {
					trace("onConnect:"+connected+" - "+msg);
				},
				onClose: function(msg) {
					trace("onClose:"+msg);
				},
				onError: function(msg) {
					trace("onError:"+msg);
				},
				onData: this.onData
		});
		peoteSocket.connect("192.168.1.50", 23);
		
	}
	
	#if flash
	public inline function onData(data:ByteArray):Void
	{
		trace("onData:" + data.bytesAvailable);
		peoteSocket.close();
		peoteSocket.connect("192.168.1.50", 23);
	}
	#else
	public inline function onData(data:Array<Int>):Void
	{
		trace("onData:" + data );
		peoteSocket.close();
		peoteSocket.connect("192.168.1.50", 23);
	}
	#end

}
