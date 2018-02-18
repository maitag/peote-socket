package test;

import haxe.io.Bytes;
import haxe.Timer;
import peote.socket.PeoteSocket;

/**
 * by Sylvio Sell - Rostock 2018
 */

class Stress
{

	var host:String;
	var port:Int;
	
	var minBytes:Int;
	var maxBytes:Int;
	
	var delayTime:Int;
	
	var verbose:Bool;
	var stopOnError:Bool;

	var sendCounter:Int = 0;
	var recieveCounter:Int = 0;
	
	var sendedLength:Int = 0;
	var recievedLength:Int = 0;
	
	var log:String->Void;
	
	var peoteSocket:PeoteSocket;
	
	public function new(host:String, port:Int, log:String->Void,
						minBytes:Int, maxBytes:Int,
						delayTime:Int=0, verbose:Bool = true, stopOnError:Bool = false ) 
	{
		this.host = host;
		this.port = port;
		this.log = log;
		this.minBytes = minBytes;
		this.maxBytes = maxBytes;
		this.delayTime = delayTime;
		this.verbose = verbose;
		this.stopOnError = stopOnError;
		
		peoteSocket = new PeoteSocket( { 
				onConnect: function(connected:Bool, msg:String) {
					trace("onConnect:" + connected + " - " + msg);
					sendRandomBytes();
				},
				onClose: function(msg:String) {
					trace("onClose:"+msg);
				},
				onError: function(msg:String) {
					trace("onError:"+msg);
				},
				onData: function(bytes:Bytes ) {
					var consistent:Bool = true;
					for (i in 0...bytes.length) {
						if (bytes.get(i) != recieveCounter) {
							consistent = false; break;
						} else recieveCounter = (recieveCounter + 1) % 256;
					}
					
					if ( consistent ) {
						recievedLength += bytes.length;
						if (recievedLength >= sendedLength) {
							if (verbose) log('$recievedLength Bytes recieved');
							recievedLength -= sendedLength;
							sendRandomBytes();
						}
					}
					else log('ERROR: recieve data (${bytes.length} Bytes) not consistent');
					
				}
		});
		peoteSocket.connect(host, port);

	}

	public function sendRandomBytes():Void {
		var len:Int = Std.int(minBytes + Math.random() * (1 + maxBytes - minBytes));
		var bytes:Bytes = Bytes.alloc(len);
		
		for (i in 0...len) {
			bytes.set(i, sendCounter);
			sendCounter = (sendCounter + 1) % 256;
		}
		
		if (verbose) log('Send ${bytes.length} Bytes');
		sendedLength = len;
		
		peoteSocket.writeBytes( bytes );
		//peoteSocket.flush();
	}

}