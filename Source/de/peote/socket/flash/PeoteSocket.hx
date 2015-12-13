package de.peote.socket.flash;
/**
 * @author sylvio sell
 */

import flash.net.Socket;
import flash.utils.ByteArray;
import flash.events.EventDispatcher;
import flash.events.Event;
import flash.events.ErrorEvent;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.utils.Timer;
import flash.events.TimerEvent;

//import openfl.system.Security;

class PeoteSocket 
{
	private var _onConnectCallback:Bool -> String -> Void;
	private var _onDataCallback:ByteArray -> Void;
	private var _onCloseCallback:String -> Void;
	private var _onErrorCallback:String -> Void;
	
	public var _socket:Socket;

	private var _timer:Timer;

	public function new(param:Dynamic) 
	{
		_onConnectCallback = param.onConnect;
		_onDataCallback = param.onData;
		_onCloseCallback = param.onClose;
		_onErrorCallback = param.onError;
		
		_socket = new Socket();
		
		_timer = new Timer(0, 42);
		_timer.addEventListener(TimerEvent.TIMER, function (_) {
			
			/*var anz_bytes:Int = _socket.bytesAvailable;
			if (anz_bytes>0) {
				var myBA:ByteArray = new ByteArray();
				try {_socket.readBytes(myBA);} catch (unknown : Dynamic) { trace("ERROR: _socket.readBytes(myBA) :"+ unknown); }
				// myBA.position = 0;
				_onDataCallback(myBA, anz_bytes);
			}*/
			while (_socket.bytesAvailable>0) {
				var myBA:ByteArray = new ByteArray();
				try {_socket.readBytes(myBA);} catch (unknown : Dynamic) { _onErrorCallback("READSOCKET-ERROR: _socket.readBytes(myBA) :"+ unknown); }
				// myBA.position = 0; 
				_onDataCallback(myBA);
			}
		});

		if (_onConnectCallback != null) _socket.addEventListener(Event.CONNECT, function(e:Event) {
			_onConnectCallback(_socket.connected, e.toString());
		});

		if (_onDataCallback != null) _socket.addEventListener(ProgressEvent.SOCKET_DATA, function(e:ProgressEvent):Void {
			_timer.reset();
			_timer.start();
		});

		if (_onCloseCallback != null) _socket.addEventListener(Event.CLOSE, function(e:Event):Void { _onCloseCallback(e.toString()); });
		
		if (_onErrorCallback != null) {
			_socket.addEventListener(ErrorEvent.ERROR, function(e:ErrorEvent):Void { _onErrorCallback("SOCKETERROR"+e.text); });
			_socket.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):Void { _onErrorCallback("SOCKETIOError:"+e.text); } );
			_socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(e:SecurityErrorEvent):Void { _onErrorCallback("SOCKET-SecurityError:"+e.text); } );
		}
	}
	
	public function connect(server:String, port:Int):Void
	{	
		//Security.loadPolicyFile("xmlsocket://"+server+":843"); 
		try _socket.connect(server, port) catch (unknown : Dynamic) {_onErrorCallback("ERROR: _socket.connect(server, port) :" + unknown);}
	}

	public function close():Void
	{	
		try _socket.close() catch (unknown : Dynamic) _onErrorCallback("ERROR: _socket.close() :" + unknown);
	}
	
	public function writeByte(b:Int):Void
	{
		try _socket.writeByte(b) catch (unknown : Dynamic) _onErrorCallback("ERROR: _socket.writeByte(ba) :"+ unknown);
	}
	
	public function writeBytes(ba:ByteArray):Void
	{
		try _socket.writeBytes(ba) catch (unknown : Dynamic) _onErrorCallback("ERROR: _socket.writeBytes(ba) :"+ unknown);
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