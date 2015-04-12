package;

import lime.app.Application;
import lime.graphics.RenderContext;
import haxe.Timer;

#if js
import js.html.Uint8Array;
#end
import lime.utils.ByteArray;

import de.peote.socket.PeoteSocket;
import de.peote.telnet.PeoteTelnet;

class PeoteTelnetTest extends Application {
	
	public var peoteSocket:PeoteSocket;
	public var peoteTelnet:PeoteTelnet;
	
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
		peoteTelnet = new PeoteTelnet(peoteSocket);
		peoteSocket.connect("192.168.1.50", 23);
		
	}
	
	#if js
	public inline function onData(data:Uint8Array):Void
	{
		// TODO: optimize raw-socket data from swf-bridge ( see PeoteSocketBridge.hx )
		//trace(data);
		var bytes = new ByteArray();
		for (i in 0...data.length)
			bytes.writeByte( data[i] );
		bytes.position = 0;
		
		peoteTelnet.parseTelnetData( bytes );
	}
	#else
	public inline function onData(data:ByteArray):Void
	{
		peoteTelnet.parseTelnetData( data );
	}
	#end

}
