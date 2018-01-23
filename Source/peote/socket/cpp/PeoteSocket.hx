package peote.socket.cpp;

/**
 * @author sylvio sell
 */

import haxe.io.Bytes;
import haxe.io.BytesOutput;
import haxe.Timer;

import sys.net.Socket;
import sys.net.Host;

typedef Callbacks = {
	onConnect:Bool -> String -> Void,
	onClose:String -> Void,
	onError:String -> Void,
	onData:Bytes -> Void
}

class PeoteSocket
{
	private var cb:Callbacks;
	
	public var _socket:Socket;
	
	private var _timer:Timer;
	private var stopped:Bool = true;
	
	public function new(callbacks:Callbacks)
	{
		cb = callbacks;
	}

	public function readFromSocket():Void
	{	
		_timer.stop();
		if (stopped) return; // on socket close
		
		var end:Bool = false;		
		var bytesOutput:BytesOutput = new BytesOutput();
		
		while (!end) {
			try {
				bytesOutput.writeByte(_socket.input.readByte());
			}
			catch (unknown : Dynamic)
			{
				end = true;
				if (Std.string(unknown) != "Blocked") {
					stopped = true;
					if (Std.string(unknown) == "Eof") cb.onClose(Std.string(unknown));
					cb.onError("Unknown exception : "+Std.string(unknown));
				}
			}
		}

		if (bytesOutput.length>0) cb.onData(bytesOutput.getBytes());
		
		// start timer again
		_timer = new Timer(60);
		_timer.run = readFromSocket;
	}
	
	public function connect(server:String, port:Int):Void
	{
		_socket = new Socket();
		_socket.setTimeout(5);
		
		try {
			_socket.connect(new Host(server), port);
		}
		catch (unknown : Dynamic)
		{
			if (cb.onConnect != null) cb.onConnect(false, Std.string(unknown));
			return;
		}
		
		_socket.setBlocking(false);
		_socket.setFastSend(true);
		
		if (cb.onConnect != null) cb.onConnect(true, Std.string(_socket.peer()));
		
		if (cb.onData != null)
		{
			stopped = false;
			_timer = new Timer(60);
			_timer.run = readFromSocket;
		}
	}
	
	public function close():Void
	{	
		stopped = true;
		_socket.close();
	}
	
	public function writeByte(b:Int):Void
	{
		var end:Bool = false;
		while (!end) {
			try {
				_socket.output.writeByte(b);
				//_socket.output.writeByte(b & 0xFF); // like _socket.output.writeInt8(b);
				end = true;
			}
			catch (unknown : Dynamic)
			{
				cb.onError("writeByte exception: "+Std.string(unknown));
				if (stopped) return; // on socket close
			}
		}
	}
	
	public function writeBytes(bytes:Bytes):Void
	{	
		var end:Bool = false;
		while (!end) {
			try {
				_socket.output.write(bytes);
				end = true;
			}
			catch (unknown : Dynamic)
			{
				cb.onError("writeBytes exception: " + Std.string(unknown));
				if (stopped) return; // on socket close
			}
		}
	}
	
	public function writeFullBytes(bytes:Bytes, pos:Int, len:Int):Void
	{	
		var end:Bool = false;
		while (!end) {
			try {
				_socket.output.writeFullBytes(bytes, pos, len);
				end = true;
			}
			catch (unknown : Dynamic)
			{
				cb.onError("writeFullBytes exception: " + Std.string(unknown));
				if (stopped) return; // on socket close
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