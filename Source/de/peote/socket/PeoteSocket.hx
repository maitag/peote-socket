package de.peote.socket;

/**
 *  /\/\/\                     ~^
 * @author Sylvio Sell - maitag
 */
#if js
import js.html.WebSocket;
import js.html.BinaryType;
import js.html.ArrayBuffer;
import js.html.Uint8Array;
import bridge.js.PeoteSocketBridge;
import de.peote.io.PeoteBytes;
import de.peote.io.PeoteBytesOutput;
#end

#if cpp
typedef PeoteSocket = de.peote.socket.cpp.PeoteSocket;
#end

#if flash
typedef PeoteSocket = de.peote.socket.flash.PeoteSocket;
#end



#if js
typedef Callbacks = {
	onConnect:Bool -> String -> Void,
	onClose:String -> Void,
	onError:String -> Void,
	onData:PeoteBytes -> Void
}

// wrapping around pre generated PeoteSocketBridge.swf
@:native('PeoteSocket') extern class PeoteSocket
{
	public function new (callbacks:Callbacks) {}

	public function connect(server:String, port:Int):Void {}
	public function close():Void {}
	public function writeByte(b:Int):Void {}
	public function writeBytes(data:PeoteBytes):Void {}
	public function flush():Void {}	
}


// wrapping around websockets
@:expose("PeoteSocket") class PeoteWebSocket {
	
	var ws:WebSocket;
	var cb:Callbacks;
	
	var is_proxy:Bool = false;
	var	forward_server:String;
	var forward_port:Int;
	
	public function new (callbacks:Callbacks)
	{
		trace('new PeoteWebSocket ($callbacks)');
		this.cb = callbacks;
		
	}
	public function connect(server:String, port:Int):Void
	{
		var _server:String = (PeoteSocketBridge.proxys.proxyServerWS != null) ? PeoteSocketBridge.proxys.proxyServerWS : server;
		var _port:Int = (PeoteSocketBridge.proxys.proxyPortWS != null) ? PeoteSocketBridge.proxys.proxyPortWS : port;
		
		trace('CONNECT $_server:$_port');

		ws = new WebSocket("ws://"+_server + ":" + _port); 
		
		ws.binaryType = BinaryType.ARRAYBUFFER;
		ws.onopen    = onOpen;
		ws.onclose   = onClose;
		ws.onerror   = onError;
		ws.onmessage = onMessage;
		
		// for proxys send adress to forward
		if (_server != server || _port != port)
		{
			is_proxy = true;
			forward_server = server;
			forward_port = port;
		}
	}
	
	public function close():Void
	{
		ws.close();
	}
	
	public function writeByte(b:Int):Void
	{
		trace("writeByte:" + b);
		ws.send(new Uint8Array([b]), { binary: true, mask: false });
		trace('bufferedAmount: ${ws.bufferedAmount}');
	}
	
	public function writeBytes(data:PeoteBytes):Void
	{
		trace("writeBytes - number of bytes sending:" + data.length);
		//ws.send("TestString");
		//ws.send(new Uint8Array(data));
		ws.send(new Uint8Array(data), { binary: true, mask: false });
		trace('bufferedAmount: ${ws.bufferedAmount}');
	}
	
	public function flush():Void
	{
		// how realize this with websockets?
	}	

	// events -------------------
	
	function onOpen()
	{
		trace("onOpen");
		trace('binaryType: ${ws.binaryType}');
		trace('protocol: ${ws.protocol}');
		
		// for proxys send adress to forward
		if (is_proxy)
		{
			var output:PeoteBytesOutput = new PeoteBytesOutput();
			output.writeString(forward_server);
			output.writeUInt16(forward_port);
			writeBytes( output.getBytes() );
		}

		cb.onConnect(true,"connect");
	};
	
	function onClose()
	{
		trace("onClose");
		cb.onClose("closed");
	};
	
	function onError(s:String)
	{
		trace("onError");
		cb.onError(s);
	};	

	function onMessage(e:Dynamic)
	{
		trace("onMessage - " + e.data + " - number of bytes comming in: " + e.data.byteLength);
		//var ab:ArrayBuffer = e.data;
		//var a:Array<Int> = cast new Uint8Array(ab, 0, ab.byteLength);
		cb.onData( cast new Uint8Array(e.data, 0, e.data.byteLength) );
		
	};
	
}


#end
