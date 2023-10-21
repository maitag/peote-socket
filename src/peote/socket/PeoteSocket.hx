package peote.socket;

/**
 * /\/\/\  ~^
 * @author Sylvio Sell - maitag
**/

#if cpp
	typedef PeoteSocket = peote.socket.cpp.PeoteSocket;
#elseif neko
	typedef PeoteSocket = peote.socket.neko.PeoteSocket;
#elseif hl
	typedef PeoteSocket = peote.socket.neko.PeoteSocket;
#elseif flash
	typedef PeoteSocket = peote.socket.flash.PeoteSocket;
#elseif (html5 || js)

import haxe.io.Bytes;

import jsCompat.html.WebSocket; // TODO: check for support in later haxe versions
//import js.html.WebSocket;

import js.html.BinaryType;

#if (haxe_ver >= "4.0.0")
import js.lib.Uint8Array;
#else
import js.html.Uint8Array;
#end

import peote.io.PeoteBytesOutput;

typedef Callbacks = {
	onConnect:Bool -> String -> Void,
	onClose:String -> Void,
	onError:String -> Void,
	onData:Bytes -> Void
}

// ------------ wrapping around websockets ---------------

//@:keep @:expose("PeoteSocket") class PeoteSocket {
class PeoteSocket {

	//#if expose_js static function main() {} #end
	
	var ws:WebSocket;
	var cb:Callbacks;
	var isConnected:Bool = false;

	var is_proxy:Bool = false;
	var	proxy_server:String;
	var proxy_port:Int;
	var	forward_to_server:String;
	var forward_to_port:Int;
	
	public function new (callbacks:Callbacks)
	{
		this.cb = callbacks;		
	}
	
	public function setProxy(server:String, port:Int):Void 
	{
		is_proxy = true;
		proxy_server = server;
		proxy_port = port;		
	}

	public function connect(server:String, port:Int):Void
	{
		var supported:Bool = untyped __js__("('WebSocket' in window || 'MozWebSocket' in window)");
		if (!supported) {
			cb.onConnect(false, "Websockets not available");
		}
		
		// TODO: if (isConnected) -> already connected

		if (is_proxy)
		{
			forward_to_server = server;
			forward_to_port = port;
			server = proxy_server;
			port = proxy_port;
		}
		
		//trace('CONNECT $server:$port');

		//try {
			ws = new WebSocket("ws://"+server + ":" + port, []);
/*		} catch (err:Dynamic) {
			// TODO: useless here because never catched
			trace("WebSocket connection Error:" + err);
			//cb.onError("WebSocket connection Error:" + err);
			cb.onConnect(false, "WebSocket connection Error:" + err);
		}
*/		
		ws.binaryType = BinaryType.ARRAYBUFFER;
		ws.onopen    = onOpen;
		ws.onclose   = onClose;
		//ws.onerror   = onError;
		ws.onmessage = onMessage;
	}
	
	public function close():Void
	{
		ws.close();
	}
	
	public function writeByte(byte:Int):Void
	{
		try {
			//trace("PeoteSocket(WS) - writeByte:", byte);
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
		try {
			//trace("PeoteSocket(WS) - writeBytes:", bytes.toHex(),bytes.getData().byteLength, bytes.length);
			if (bytes.length <= 0x10000) {
				
				//ws.send(new Uint8Array(bytes.getData()), { binary: true, mask: false });
				
				// CHECK: after haxe 4 migration it needs "sclice" here 
				ws.send(bytes.getData().slice(0, bytes.length), { binary: true, mask: false });
				
			}
			else { // to keep lower than "maxpayload" in peote-proxy ( see Protocol::Websocket there)
				var pos:Int = 0;
				var len:Int = 0x10000;
				while (pos < bytes.length) {
					len = Std.int(Math.min(bytes.length - pos, len));
					var chunk:Bytes = Bytes.alloc(len);
					chunk.blit(0, bytes, pos, len);
					//trace("CHUNK:",pos, len);
					
					// TODO CHECK: needs "sclice" here also ?
					//ws.send(new Uint8Array(chunk.getData()), { binary: true, mask: false });
					ws.send(chunk.getData(), { binary: true, mask: false });
					
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
		isConnected = true;
		ws.onerror  = onError;
		//trace("onOpen");
		//trace('binaryType: ${ws.binaryType}');
		//trace('protocol: ${ws.protocol}');
		
		// for proxys send adress where to forward
		if (is_proxy)
		{
			var output:PeoteBytesOutput = new PeoteBytesOutput();
			//output.writeString(forward_to_server);
			output.writeString(forward_to_server, haxe.io.Encoding.RawNative);
			output.writeUInt16(forward_to_port);
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
			case 1010: "An endpoint (client) is terminating the connection because it has expected the server to negotiate one or more extension, but the server didn't return them in the response message of the WebSocket handshake. Specifically, the extensions that are needed are: " + event.reason;
			case 1011: "A server is terminating the connection because it encountered an unexpected condition that prevented it from fulfilling the request.";
			case 1015: "The connection was closed due to a failure to perform a TLS handshake (e.g., the server certificate can't be verified).";
			default: "Unknown reason";
		}
		
		if (!isConnected) cb.onConnect(false, reason);
		else {
			isConnected = false;
			cb.onClose("closed: " + reason);
		}
	}
	
	function onError(s:Dynamic)
	{
		//trace("WEBSOCKET-ERROR:",s);
		cb.onError("WEBSOCKET-ERROR:"+s);
	}

	function onMessage(e:Dynamic) // BytesData
	{
		//trace("PeoteSocket: Recieve "+e.data.byteLength+" Bytes");
		cb.onData( Bytes.ofData(e.data) );		
	}
	
}

#end
