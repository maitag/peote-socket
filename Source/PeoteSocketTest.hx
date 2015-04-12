package;

import lime.app.Application;
import haxe.Timer;

#if js
import js.html.Uint8Array;
#else
import lime.utils.ByteArray;
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
	
	#if js
	public inline function onData(data:Uint8Array):Void
	#else
	public inline function onData(data:ByteArray):Void
	#end
	{
		trace("onData:" + data);
		peoteSocket.close();
		peoteSocket.connect("192.168.1.50", 23);
	}

}
