package;

import lime.app.Application;


import de.peote.socket.PeoteSocket;
import de.peote.telnet.PeoteTelnet;
import de.peote.io.PeoteBytesInput;
import de.peote.io.PeoteBytes;

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
				onData: onData
		});
		peoteTelnet = new PeoteTelnet(peoteSocket);
		peoteSocket.connect("192.168.1.50", 23);
		
	}
	
	public inline function onData(peoteBytes:PeoteBytes ):Void 
	{
		var input:PeoteBytesInput = new PeoteBytesInput(peoteBytes);
		peoteTelnet.parseTelnetData( input, remoteInput );
		
	}

	public inline function remoteInput(b:Int):Void
	{
		if (b != 13) trace( String.fromCharCode(b) );
	}
}
