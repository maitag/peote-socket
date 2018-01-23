package peote.socket;

/**
 * /\/\/\  ~^
 * @author Sylvio Sell - maitag
**/

#if cpp
	typedef PeoteSocket = peote.socket.cpp.PeoteSocket;
#elseif neko
	typedef PeoteSocket = peote.socket.neko.PeoteSocket;
#elseif flash
	typedef PeoteSocket = peote.socket.flash.PeoteSocket;

#elseif js
// ------------------------- ----------------------------------
// wrapper around external Interface of flash socketbridge------

import haxe.io.Bytes;
import js.html.WebSocket;
import js.html.BinaryType;
import js.html.ArrayBuffer;
import js.html.Uint8Array;
import peote.bridge.js.PeoteSocketBridge;
import peote.io.PeoteBytesOutput;
import peote.io.PeoteBytesInput;

typedef Callbacks = {
	onConnect:Bool -> String -> Void,
	onClose:String -> Void,
	onError:String -> Void,
	onData:Bytes -> Void
}

#if !expose_js
// wrapping around pre generated PeoteSocketBridge.swf
@:native('PeoteSocket') extern class PeoteSocket
{
	public function new (callbacks:Callbacks) {}

	public function connect(server:String, port:Int):Void {}
	public function close():Void {}
	public function writeByte(b:Int):Void {}
	public function writeBytes(data:Bytes):Void {}
	public function flush():Void {}	
}
#end

// convert Array into peoteBytes (haxe.io.Bytes)
@:keep @:expose("PeoteSocketTool") class PeoteSocketTool {
	public static function toBytes(arr:Array<Int>):Bytes
	{
		return Bytes.ofData(new Uint8Array(arr).buffer);
	}
	public static function fromBytes(bytes:Bytes):Array<Int>
	{
		return [ for( i in 0...bytes.length ) bytes.get(i) ];
	}
}



// ------------ wrapping around websockets ---------------

@:keep @:expose("PeoteSocket") class #if !expose_js PeoteWebSocket #else PeoteSocket #end {

	#if expose_js static function main() {}#end
	
	var ws:WebSocket;
	var cb:Callbacks;
	
	var is_proxy:Bool = false;
	var	forward_server:String;
	var forward_port:Int;
	
	public function new (callbacks:Callbacks)
	{
		//trace('new PeoteWebSocket ($callbacks)');
		this.cb = callbacks;
		
	}
	public function connect(server:String, port:Int):Void
	{
		var _server:String = server;
		var _port:Int = port;
		
		if (PeoteSocketBridge.proxys != null)
		{
			if (PeoteSocketBridge.proxys.proxyServerWS != null) _server = PeoteSocketBridge.proxys.proxyServerWS;
			if (PeoteSocketBridge.proxys.proxyPortWS   != null) _port   = PeoteSocketBridge.proxys.proxyPortWS;
		}
		
		//trace('CONNECT $_server:$_port');

		try {ws = new WebSocket("ws://"+_server + ":" + _port);} 
		
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
		//trace("writeByte:" + b);
		ws.send(new Uint8Array([b]), { binary: true, mask: false });
		//trace('bufferedAmount: ${ws.bufferedAmount}');
	}
	
	public function writeBytes(data:Bytes):Void
	{
		//trace("writeBytes - number of bytes sending:" + data.length);
		//ws.send("TestString");
		//ws.send(new Uint8Array(data));
		//ws.send(new Uint8Array(data), { binary: true, mask: false });
		ws.send(new Uint8Array(data.getData()), { binary: true, mask: false });
		//trace('bufferedAmount: ${ws.bufferedAmount}');
	}
	
	public function flush():Void
	{
		// how realize this with websockets?
	}	

	// events -------------------
	
	function onOpen()
	{
		//trace("onOpen");
		//trace('binaryType: ${ws.binaryType}');
		//trace('protocol: ${ws.protocol}');
		
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
		//trace("onClose");
		cb.onClose("closed");
	};
	
	function onError(s:String)
	{
		//trace("onError");
		cb.onError(s);
	};	

	function onMessage(e:Dynamic) //BytesData
	{
		//trace("onMessage - " + e.data + " - number of bytes comming in: " + e.data.byteLength);
		//var ab:ArrayBuffer = e.data;
		//var a:Array<Int> = cast new Uint8Array(ab, 0, ab.byteLength);
		
		//cb.onData( cast new Uint8Array(e.data, 0, e.data.byteLength) );
		cb.onData( Bytes.ofData(e.data) );
		
	};
	
}

#end
