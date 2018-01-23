package;

/**
 * by Sylvio Sell Rostock 2015
 * 
 */

import haxe.io.Bytes;
import lime.app.Application;

import peote.bridge.PeoteSocketBridge;

import peote.socket.PeoteSocket;
import peote.telnet.PeoteTelnet;
import peote.io.PeoteBytesInput;

class PeoteTelnetTest extends Application {
	
	public var peoteSocket:PeoteSocket;
	public var peoteTelnet:PeoteTelnet;
	
	public function new ()
	{
		super();
		
		// provides adresses for peote-proxy server that handles flashpolicy and websockets
		// only relevant for js or flash targets
		// (cpp will ignore this and opens directly tcp socket immediatly)
		PeoteSocketBridge.load( {
			onload: openSocket,
			preferWebsockets: true,  // only for js
			proxys: {
				proxyServerWS:"localhost",  // for js websocket proxy
				proxyPortWS  : 3211,
				
				proxyServerSWF:"localhost", // for flash proxy
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
		peoteSocket.connect("lem", 23); // be sure there is running telnet server
		
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
