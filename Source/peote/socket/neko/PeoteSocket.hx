package peote.socket.neko;

/**
 * @author sylvio sell
 */

import neko.vm.Deque;
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

	public static var OUT_CHUNKSIZE:Int = 512;
	public static var IN_CHUNKSIZE:Int = 256;
	
	var inputbuff:Bytes = Bytes.alloc(IN_CHUNKSIZE);

	public function readFromSocket():Void
	{	
		_timer.stop();
		if (stopped) return; // on socket close
		
		var end:Bool = false;
		while (!end) {
			try {
				var len:Int = _socket.input.readBytes(inputbuff, 0, IN_CHUNKSIZE);
				cb.onData(inputbuff.sub(0, len));
			}
			catch (unknown : Dynamic)
			{
				end = true;
				if (Std.string(unknown) != "Blocked") {
					stopped = true;
					if (Std.string(unknown) == "Eof") cb.onClose(Std.string(unknown));
					else cb.onError("Unknown exception : '" + Std.string(unknown)+"'");
				}
			}
		}
		
		// start timer again
		_timer = new Timer(10);
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
		
		if (cb.onData != null)
		{
			stopped = false;
			_timer = new Timer(0);
			_timer.run = readFromSocket;
		}
		
		if (cb.onConnect != null) cb.onConnect(true, Std.string(_socket.peer()));
		
	}
	
	public function close():Void
	{	
		stopped = true;
		_socket.close();
	}
	
	// --------------------------------
	
	var dque = new Deque<Bytes>();
	var is_writing:Int = 0;
	
	function queue(bytes:Bytes):Void
	{
		dque.add(bytes);
		if (is_writing++ == 0) writeQueue(dque.pop(false), 0, OUT_CHUNKSIZE ); // TODO: overflow!
	}
		
	function writeQueue(bytes:Bytes, pos:Int, len:Int):Void
	{
		var chunksize = len;
		if (pos + len > bytes.length) len = bytes.length - pos;
		
		var retry:Bool = false;
		try {
			len = _socket.output.writeBytes(bytes, pos, len);
		}
		catch (unknown : Dynamic)
		{
			if (Std.string(unknown) != "Blocked") {
				stopped = true;
				if (Std.string(unknown) == "Eof") cb.onClose(Std.string(unknown));
				else cb.onError("Unknown exception : '" + Std.string(unknown)+"'");
			}
			else {					
				retry = true;
				chunksize = Std.int(Math.max(32, chunksize*0.75)); // TODO
			}
		}
		
		if (!stopped) {
			if (retry) {
				Timer.delay(function() { writeQueue(bytes, pos, chunksize); }, 0);
			}
			else if ( pos + len < bytes.length ) {
				Timer.delay(function() { writeQueue(bytes, pos + len, chunksize); }, 0);
			}
			else {
				var b:Bytes = dque.pop(false);
				if (b != null) Timer.delay(function() { writeQueue(b, 0, chunksize); }, 0);
				else is_writing = 0;
			}
		}
	}
	// --------------------------------------------
	
	public function writeByte(b:Int):Void
	{
		var bytes:Bytes = Bytes.alloc(1);
		bytes.set(0, b);
		queue(bytes);
	}

	public function writeBytes(bytes:Bytes):Void
	{
		queue(bytes);
	}
	
	public function writeFullBytes(bytes:Bytes, pos:Int, len:Int):Void
	{
		queue(bytes.sub(pos, len));
	}
	
	public function flush():Void
	{
		_socket.output.flush(); // TODO
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