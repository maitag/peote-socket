package de.peote.socket.flash.bridge;
/**
 * ~~~~~~~~~~~~~~~~~~~<o<~~~~~~
 * @author Sylvio Sell - maitag
 */

import de.peote.socket.flash.PeoteSocket;
import flash.external.ExternalInterface;
import flash.utils.ByteArray;
import haxe.io.Bytes;
import haxe.io.BytesData;
//import haxe.crypto.Base64;

class PeoteSocket extends de.peote.socket.flash.PeoteSocket
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
		try _socket.connect(_server, _port) catch (unknown : Dynamic) {_onErrorCallback("ERROR: _socket.connect(_server, _port) :" + unknown);}
	}

	// PeoteSocketBridge Event Callbacks - flashplayer calls Javascript-Functions back :)=
	public inline function onData(bytes:Bytes):Void
	{	
		//var data:Array<Int> = new Array<Int>();
		//for( i in 0...bytes.length ) data.push( bytes.get(i) );
		//ExternalInterface.call("(function(id, bytes){ var inst = window.PeoteSocket._instances[id]; if (inst.onData) inst.onData(bytes); })", id, data ) ;
		ExternalInterface.call("(function(id, bytes){ var inst = window.PeoteSocket._instances[id]; if (inst.onData) inst.onData(bytes); })", id,
			[ for( i in 0...bytes.length ) bytes.get(i) ]
		) ;
		
		//ExternalInterface.call("(function(id, bytes){ var inst = window.PeoteSocket._instances[id]; if (inst.onData) inst.onData(bytes); })", id, Base64.encode(bytes) ) ;
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