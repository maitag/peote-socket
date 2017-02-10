package;

import haxe.io.Bytes;
import lime.app.Application;

import bridge.PeoteSocketBridge;

import peote.socket.PeoteSocket;
import peote.telnet.PeoteTelnet;
import peote.io.PeoteBytesInput;
import peote.io.PeoteBytesOutput;

class PeoteTelnetTest extends Application {
	
	public var peoteSocket:PeoteSocket;
	public var peoteTelnet:PeoteTelnet;
	
	public function new ()
	{
		super();
		
		// for js or flash-targets only (cpp will ignore all that proxy-settings and go diretly throught)
		// webbrowser falls back to swfbridge or websockets (trying both)
		PeoteSocketBridge.load( {
			onload: openSocket,
			//prefareWebsockets: true,  // only for js
			proxys: {
				proxyServerWS:"localhost",  // only for js
				proxyPortWS  : 3211,
				
				proxyServerSWF:"localhost", // js targets going throught peoteSocketBridge.swf
				proxyPortSWF  :3211,
			},
			onfail: function() { trace("Browser doesn't support flash or websockets"); }
		});
	}
	
	public function openSocket():Void
	{
		peoteSocket = new PeoteSocket( { 
				onConnect: function(connected, msg) {
					trace("onConnect:" + connected + " - " + msg);
				},
				onClose: function(msg) {
					trace("onClose:"+msg);
				},
				onError: function(msg) {
					trace("onError:"+msg);
				},
				onData: onData
		});
		peoteTelnet = new PeoteTelnet(peoteSocket);
		peoteSocket.connect("192.168.1.81", 23); // be sure there is running telnet server
		
	}
	
	public inline function onData(bytes:Bytes ):Void 
	{
		var input:PeoteBytesInput = new PeoteBytesInput(bytes);
		peoteTelnet.parseTelnetData( input, remoteInput );
		
	}

	public inline function remoteInput(b:Int):Void
	{
		if (b != 13) trace( "remoteInput "+String.fromCharCode(b) );
	}
}
