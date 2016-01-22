package de.peote.socket.cpp;

/**
 * @author sylvio sell
 */

import haxe.io.Bytes;
import haxe.io.BytesData;
import haxe.Timer;

import sys.net.Socket;
import sys.net.Host;

class PeoteSocket
{
	private var _onConnectCallback:Bool -> String -> Void;
	private var _onDataCallback:Bytes -> Void;
	private var _onCloseCallback:String -> Void;
	private var _onErrorCallback:String -> Void;
	
	public var _socket:Socket;
	
	private var _timer:Timer;
	private var stopReading:Bool = true;
	
	public function new(param:Dynamic)
	{
		_onConnectCallback = param.onConnect;
		_onDataCallback = param.onData;
		
		// TODO
		_onCloseCallback = param.onClose;
		_onErrorCallback = param.onError;
		
		
	}

	public function readFromSocket():Void
	{	
		_timer.stop();
		if (stopReading) return; // on socket close
		
		var end:Bool = false;
		var char:Int = 0;
		
		var data:BytesData = new BytesData();

		// -> TODO: optimize like here _socket.input.readAll();
		
		while (!end) {
			try {
				char = _socket.input.readByte();
			}
			catch (unknown : Dynamic)
			{
				end = true;
				if (Std.string(unknown) != "Blocked") _onErrorCallback("Unknown exception : "+Std.string(unknown));
			}
			if (!end)
			{	
				data.push(cast char);
			}
		}
			
		if (data.length > 0) _onDataCallback(Bytes.ofData(data));
		
		// start timer again
		_timer = new Timer(60);
		_timer.run = readFromSocket;
	}
	
	public function connect(server:String, port:Int):Void
	{
		_socket = new Socket();
		_socket.setTimeout(3);
		
		try {
			_socket.connect(new Host(server), port);
		}
		catch (unknown : Dynamic)
		{
			if (_onConnectCallback != null) _onConnectCallback(false, "false");
			return;
		}
		
		_socket.setBlocking(false);
		
		if (_onConnectCallback != null) _onConnectCallback(true, "true");
		
		if (_onDataCallback != null)
		{
			stopReading = false;
			_timer = new Timer(60);
			_timer.run = readFromSocket;
		}
	}
	
	public function close():Void
	{	
		stopReading = true;
		_socket.close();
	}
	
	public function writeByte(b:Int):Void
	{
		// TODO: check blocking !
		var end:Bool = false;
		while (!end) {
			try {
				_socket.output.writeByte(b);
				//_socket.output.writeByte(b & 0xFF); // like _socket.output.writeInt8(b);
				end = true;
			}
			catch (unknown : Dynamic)
			{
				_onErrorCallback("writeByte(b) exception: "+Std.string(unknown)+" end:"+end);
			}
		}
	}
	
	public function writeBytes(bytes:Bytes):Void
	{	
		// TODO: check blocking !
		var end:Bool = false;
		while (!end) {
			try {
				//_socket.output.write(cast ba);
				_socket.output.write(bytes);
				end = true;
			}
			catch (unknown : Dynamic)
			{
				_onErrorCallback("writeBytes(ba) exception: " + Std.string(unknown) + " end:" + end);
				//end = true;
			}
		}
	}
	
	public function writeFullBytes(bytes:Bytes, pos:Int, len:Int):Void
	{	
		// TODO: check blocking !
		var end:Bool = false;
		while (!end) {
			try {
				//_socket.output.write(cast ba);
				_socket.output.writeFullBytes(bytes, pos, len);
				end = true;
			}
			catch (unknown : Dynamic)
			{
				_onErrorCallback("writeBytes(ba) exception: " + Std.string(unknown) + " end:" + end);
				//end = true;
			}
		}
	}
	
	public function flush():Void
	{
		_socket.output.flush();
	}
	
	//public function SendUTFString(msg:String):Void
	//{
	//	_socket.write(msg);
	//	_socket.output.flush();
		/*
		var ba:ByteArray = new ByteArray();	//	ba.writeMultiByte(msg + "\n", "UTF-8");
		ba.writeUTFBytes(msg);
		_socket.output.writeBytes(ba);
		_socket.output.flush();
		*/
	//}
	
	
}