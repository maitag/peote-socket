package;

/**
 * by Sylvio Sell Rostock 2015
 * 
 */

import haxe.io.Bytes;
import lime.app.Application;

import peote.socket.PeoteSocket;
import peote.telnet.PeoteTelnet;
import peote.io.PeoteBytesInput;

class PeoteTelnetTest extends Application {
	
	public var peoteSocket:PeoteSocket;
	public var peoteTelnet:PeoteTelnet;
	
	public function new ()
	{
		super();
		
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
		#if js
		// for html5 target a peote-proxy server is need to translate websocket-protocol into TCP
		peoteSocket.setProxy("localhost", 3211);
		#end
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
