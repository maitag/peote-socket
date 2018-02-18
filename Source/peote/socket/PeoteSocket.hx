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

// wrapper around external Interface of flash socketbridge------

import haxe.io.Bytes;
import jsCompat.html.WebSocket; // TODO: check for support in later haxe versions
import js.html.BinaryType;
import js.html.Uint8Array;
import peote.bridge.js.PeoteSocketBridge;
import peote.io.PeoteBytesOutput;

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

	#if expose_js static function main() {} #end
	
	var ws:WebSocket;
	var cb:Callbacks;
	
	var is_proxy:Bool = false;
	var	forward_server:String;
	var forward_port:Int;
	
	public function new (callbacks:Callbacks)
	{
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

		try {
			ws = new WebSocket("ws://"+_server + ":" + _port);
		} catch (err:Dynamic) {
			trace("WebSocket connection Error:" + err);
			cb.onError("WebSocket connection Error:" + err);
		}
		
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
	
	public function writeByte(byte:Int):Void
	{
		try {
			ws.send(new Uint8Array([byte]), { binary: true, mask: false });
			// little hack because sending 1 byte that is 48 did not flush
			if (byte == 48) ws.send(new Uint8Array([]), { binary: true, mask: false });
			//trace("wroteByte(" + byte+"): 1");
		}
		catch (err:Dynamic) {
			trace("WebSocket writeByte Error:"+err);
			trace('bufferedAmount: ${ws.bufferedAmount}');
			cb.onError("WebSocket writeByte Error:"+err);
		}
	}
	
	public function writeBytes(bytes:Bytes):Void
	{
		try { //trace("SENDING:",bytes.length);
			if (bytes.length <= 0x10000)
				ws.send(new Uint8Array(bytes.getData()), { binary: true, mask: false });
			else { // to keep lower than "maxpayload" in peote-proxy ( see Protocol::Websocket there)
				var pos:Int = 0;
				var len:Int = 0x10000;
				while (pos < bytes.length) {
					len = Std.int(Math.min(bytes.length - pos, len));
					var chunk:Bytes = Bytes.alloc(len);
					chunk.blit(0, bytes, pos, len);
					//trace("CHUNK:",pos, len);
					ws.send(new Uint8Array(chunk.getData()), { binary: true, mask: false });
					// little hack because sending 1 byte that is 48 did not flush
					if (chunk.length == 1) if (chunk.get(0) == 48) ws.send(new Uint8Array([]), { binary: true, mask: false });
					pos += len;
				}
			}
			// little hack because sending 1 byte that is 48 did not flush
			if (bytes.length == 1) if (bytes.get(0) == 48) ws.send(new Uint8Array([]), { binary: true, mask: false });
			
			//trace("wroteBytes: " + bytes.length, bytes.get(0));
		}
		catch (err:Dynamic) {
			trace("WebSocket writeBytes Error:"+err);
			trace('bufferedAmount: ${ws.bufferedAmount}');
			cb.onError("WebSocket writeBytes Error:"+err); //TODO
		}
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
	}
	
	function onClose(event:Dynamic)
	{
        var reason:String;
        reason = switch (event.code) {
			// See http://tools.ietf.org/html/rfc6455#section-7.4.1
			case 1000: "Normal closure, meaning that the purpose for which the connection was established has been fulfilled.";
			case 1001: "An endpoint is \"going away\", such as a server going down or a browser having navigated away from a page.";
			case 1002: "An endpoint is terminating the connection due to a protocol error";
			case 1003: "An endpoint is terminating the connection because it has received a type of data it cannot accept (e.g., an endpoint that understands only text data MAY send this if it receives a binary message).";
			case 1004: "Reserved. The specific meaning might be defined in the future.";
			case 1005: "No status code was actually present.";
			case 1006: "The connection was closed abnormally, e.g., without sending or receiving a Close control frame";
			case 1007: "An endpoint is terminating the connection because it has received data within a message that was not consistent with the type of the message (e.g., non-UTF-8 [http://tools.ietf.org/html/rfc3629] data within a text message).";
			case 1008: "An endpoint is terminating the connection because it has received a message that \"violates its policy\". This reason is given either if there is no other sutible reason, or if there is a need to hide specific details about the policy.";
			case 1009: "An endpoint is terminating the connection because it has received a message that is too big for it to process.";
			case 1010: "An endpoint (client) is terminating the connection because it has expected the server to negotiate one or more extension, but the server didn't return them in the response message of the WebSocket handshake. <br /> Specifically, the extensions that are needed are: " + event.reason;
			case 1011: "A server is terminating the connection because it encountered an unexpected condition that prevented it from fulfilling the request.";
			case 1015: "The connection was closed due to a failure to perform a TLS handshake (e.g., the server certificate can't be verified).";
			default: "Unknown reason";
		}
			
		cb.onClose("closed: "+ reason);
	}
	
	function onError(s:Dynamic)
	{
		trace("WEBSOCKET-ERROR:",s);
		cb.onError("WEBSOCKET-ERROR:"+s);
	}

	function onMessage(e:Dynamic) // BytesData
	{
		//trace("PeoteSocket: Recieve "+e.data.byteLength+" Bytes");
		cb.onData( Bytes.ofData(e.data) );		
	}
	
}

#end
