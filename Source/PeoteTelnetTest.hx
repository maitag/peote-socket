package;

import haxe.io.Bytes;
import haxe.io.BytesData;
import lime.app.Application;
import lime.graphics.RenderContext;
import haxe.Timer;

import haxe.crypto.Base64;

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
	/*
	#if flash
	public inline function onData(data:ByteArray):Void
	{
		var bytes:Array<Int> = new Array<Int>();
		for( i in 0...data.bytesAvailable ) bytes.push( data.readUnsignedByte() );

		peoteTelnet.parseTelnetData( bytes, remoteInput );
	}
	#else
	public inline function onData(data:Array<Int>):Void
	{
		peoteTelnet.parseTelnetData( data, remoteInput );
	}
	#end
	*/
	
	#if js
	public inline function onData(data:Array<Int>):Void {
		var bytes:Bytes = Bytes.ofData(new BytesData(data.length));
		for (i in 0...data.length) bytes.set(i, data[i]);
		
		peoteTelnet.parseTelnetData( bytes, remoteInput );
	}
	#else
	public inline function onData(bytes:Bytes):Void
	{
		peoteTelnet.parseTelnetData( bytes, remoteInput );
	}
	#end
	
	public inline function remoteInput(b:Int):Void
	{
		if (b != 13) trace( String.fromCharCode(b) );
	}
}
