package de.peote.socket.flash;
/**
 * @author sylvio sell
 */

import flash.net.Socket;
import flash.events.EventDispatcher;
import flash.events.Event;
import flash.events.ErrorEvent;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.utils.Timer;
import flash.events.TimerEvent;

import haxe.io.BytesData;
import haxe.io.Bytes;

import de.peote.io.PeoteBytesOutput;
import bridge.PeoteSocketBridge;

class PeoteSocket 
{
	public var _socket:Socket;

	var _onConnectCallback:Bool -> String -> Void;
	var _onDataCallback:Bytes -> Void;
	var _onCloseCallback:String -> Void;
	var _onErrorCallback:String -> Void;
	
	var _timer:Timer;
	
	var is_proxy:Bool = false;
	var forward_server:String;
	var forward_port:Int;

	public function new(param:Dynamic) 
	{
		_onConnectCallback = param.onConnect;
		_onDataCallback = param.onData;
		_onCloseCallback = param.onClose;
		_onErrorCallback = param.onError;
		
		_socket = new Socket();
		
		//_timer = new Timer(0, 42);
		/*_timer = new Timer(0, 1);
		_timer.addEventListener(TimerEvent.TIMER, function (_) {
			while (_socket.bytesAvailable>0) {
				var myBA:BytesData = new BytesData();
				try {_socket.readBytes(myBA);} catch (unknown : Dynamic) { _onErrorCallback("READSOCKET-ERROR: _socket.readBytes(myBA) :"+ unknown); }
				// myBA.position = 0; 
				_onDataCallback(Bytes.ofData(myBA));
			}
		});
		*/
		if (_onConnectCallback != null) _socket.addEventListener(Event.CONNECT, function(e:Event) {
			
			// for proxy send adress to forward
			if (is_proxy)
			{
				var output:PeoteBytesOutput = new PeoteBytesOutput();
				output.writeString(forward_server);
				output.writeUInt16(forward_port);
				writeBytes( output.getBytes() );
			}
			_onConnectCallback(_socket.connected, e.toString());
		});

		if (_onDataCallback != null) _socket.addEventListener(ProgressEvent.SOCKET_DATA, function(e:ProgressEvent):Void {
			//_timer.reset();
			//_timer.start();
			var myBA:BytesData = new BytesData();
			try { _socket.readBytes(myBA); } catch (unknown : Dynamic) { _onErrorCallback("READSOCKET-ERROR: _socket.readBytes(myBA) :" + unknown); }
			_onDataCallback(Bytes.ofData(myBA));
			
		});

		if (_onCloseCallback != null) _socket.addEventListener(Event.CLOSE, function(e:Event):Void { _onCloseCallback(e.toString()); });
		
		if (_onErrorCallback != null) {
			_socket.addEventListener(ErrorEvent.ERROR, function(e:ErrorEvent):Void { _onErrorCallback("SOCKETERROR"+e.text); });
			_socket.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):Void { _onErrorCallback("SOCKETIOError:"+e.text); } );
			_socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(e:SecurityErrorEvent):Void { _onErrorCallback("SOCKET-SecurityError:"+e.text); } );
		}
	}
	
	public function setForward(server:String, port:Int):Void
	{	
		is_proxy = true;
		forward_server = server;
		forward_port = port;
	}
	
	public function connect(server:String, port:Int):Void
	{	
		var _server:String = server;
		var _port:Int = port;
		
		if (PeoteSocketBridge.proxys != null)
		{
			if (PeoteSocketBridge.proxys.proxyServerSWF != null) _server = PeoteSocketBridge.proxys.proxyServerSWF;
			if (PeoteSocketBridge.proxys.proxyPortSWF   != null) _port   = PeoteSocketBridge.proxys.proxyPortSWF;
		}
		
		try _socket.connect(_server, _port) catch (unknown : Dynamic) {_onErrorCallback("ERROR: _socket.connect(_server, _port) :" + unknown);}
		
		// for proxys send adress to forward
		if (_server != server || _port != port)
		{
			setForward(server, port);
		}
	}

	public function close():Void
	{	
		try _socket.close() catch (unknown : Dynamic) _onErrorCallback("ERROR: _socket.close() :" + unknown);
	}
	
	public function writeByte(b:Int):Void
	{
		try _socket.writeByte(b) catch (unknown : Dynamic) _onErrorCallback("ERROR: _socket.writeByte(ba) :"+ unknown);
	}
	
	public function writeBytes(ba:Bytes):Void
	{
		try _socket.writeBytes(ba.getData()) catch (unknown : Dynamic) _onErrorCallback("ERROR: _socket.writeBytes(ba) :"+ unknown);
	}
	
	public function writeFullBytes(bytes:Bytes, pos:Int, len:Int):Void
	{
		var tmp_ba:BytesData = new BytesData(); // TODO: optimize
		// tmp_ba.clear();
		var ba:BytesData = bytes.getData();
		ba.position = pos;
		ba.readBytes(tmp_ba, 0, len);
				
		try _socket.writeBytes(tmp_ba) catch (unknown : Dynamic) _onErrorCallback("ERROR: _socket.writeFullBytes() :"+ unknown);
	}
	
	public function flush():Void
	{
		try _socket.flush() catch (unknown : Dynamic) _onErrorCallback("ERROR: _socket.writeBytes(ba) :"+ unknown);
	}
	/*
	public function SendUTFString(msg:String):Void
	{
		//var ba:ByteArray = new ByteArray();	//	ba.writeMultiByte(msg + "\n", "UTF-8");
		//ba.writeUTFBytes(msg);
		//_socket.writeBytes(ba);
		_socket.writeUTFBytes(msg);
		_socket.flush();
	}
	*/
	
}