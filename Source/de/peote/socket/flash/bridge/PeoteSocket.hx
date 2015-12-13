package de.peote.socket.flash.bridge;
/**
 * ~~~~~~~~~~~~~~~~~~~<o<~~~~~~
 * @author Sylvio Sell - maitag
 */

import de.peote.socket.flash.PeoteSocket;
import flash.external.ExternalInterface;
import flash.utils.ByteArray;

class PeoteSocket extends de.peote.socket.flash.PeoteSocket
{
	public var id:String;
	
	public function new(id:String) 
	{
		this.id = id;
		ExternalInterface.call("console.log('new Socket("+id+")')");
		
		super({
			onConnect: this.onConnect,
			onData: this.onData,
			onClose: this.onClose,
			onError: this.onError
		});
	}

	// PeoteSocketBridge Event Callbacks - flashplayer calls Javascript-Functions back :)=
	public inline function onData(data:ByteArray):Void
	{	//ExternalInterface.call("(function(byte){ console.log('len',byte); })", data.length ) ;
		var bytes:Array<Int> = new Array<Int>();
		
		for( i in 0...data.bytesAvailable )
			bytes.push( data.readUnsignedByte() );
		
		//ExternalInterface.call("(function(bytes){ console.log(bytes); })", bytes ) ;
		ExternalInterface.call("(function(id, bytes){ var inst = window.PeoteSocket._instances[id]; if (inst.onData) inst.onData(bytes); })", id, bytes ) ;
		//ExternalInterface.call("(function(id, bytes){ var inst = window.PeoteSocket._instances[id]; if (inst.onData) inst.onData(bytes); })", id, data.toString()) ;
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