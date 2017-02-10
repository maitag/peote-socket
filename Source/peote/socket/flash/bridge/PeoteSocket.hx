package peote.socket.flash.bridge;
/**
 * ~~~~~~~~~~~~~~~~~~~<o<~~~~~~
 * @author Sylvio Sell - maitag
 */

import peote.socket.flash.PeoteSocket;
import flash.external.ExternalInterface;
import flash.utils.ByteArray;
import haxe.io.Bytes;
import haxe.io.BytesData;

class PeoteSocket extends peote.socket.flash.PeoteSocket
{
	public var id:String;
	
	public function new(id:String) 
	{
		this.id = id;
		//ExternalInterface.call("console.log('new Socket("+id+")')");
		
		super({
			onConnect: this.onConnect,
			onData: this.onData,
			onClose: this.onClose,
			onError: this.onError
		});
	}
	override public function connect(server:String, port:Int):Void
	{	
		try _socket.connect(server, port) catch (unknown : Dynamic) {_onErrorCallback("ERROR: _socket.connect(server, port) :" + unknown);}
	}

	// PeoteSocketBridge Event Callbacks - flashplayer calls Javascript-Functions back :)=
	public inline function onData(bytes:Bytes):Void
	{	
		ExternalInterface.call("(function(id, arr){ var inst = window.PeoteSocket._instances[id]; if (inst.onData) inst.onData(window.PeoteSocketTool.toBytes(arr)); })",
			id,
			[ for( i in 0...bytes.length ) bytes.get(i) ]
		) ;
	}

	public inline function onConnect(connected:Bool, msg:String):Void 
	{
        ExternalInterface.call("(function(id, connected, msg){ var inst = window.PeoteSocket._instances[id]; if (inst.onConnect) inst.onConnect(connected, msg); })", id, connected, msg);
	}
	
	public inline function onClose(msg:String):Void 
	{
        ExternalInterface.call("(function(id, msg){ var inst = window.PeoteSocket._instances[id]; if (inst.onClose) inst.onClose(msg); })", id, msg);
	}
	
	public inline function onError(msg:String):Void 
	{
        ExternalInterface.call("(function(id, msg){ var inst = window.PeoteSocket._instances[id]; if (inst.onError) inst.onError(msg); })", id, msg);
	}

	
}