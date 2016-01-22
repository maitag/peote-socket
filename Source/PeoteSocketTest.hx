package;

import lime.app.Application;
import haxe.Timer;

import haxe.io.Bytes;
import haxe.io.BytesData;


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
	public inline function onData(data:Array<Int>):Void {
		var bytes:Bytes = Bytes.ofData(new BytesData(data.length));
		for (i in 0...data.length) bytes.set(i, data[i]);
		debug_output( bytes );
	}
	#else

	public inline function onData(bytes:Bytes):Void	{
		debug_output(bytes);
	}
	#end
	
	public inline function debug_output(bytes:Bytes):Void 
	{
		var s:String = "";
		for (i in 0 ...bytes.length) s += bytes.get(i)+" ";
		trace("onData:" + s);
		peoteSocket.close();
		peoteSocket.connect("192.168.1.50", 23);
	}

}
