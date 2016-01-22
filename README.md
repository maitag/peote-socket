### PeoteSocket - Raw Socket Client Library

This Library is written in [Haxe](http://haxe.org). Uses [OpenFl/Lime](http://www.openfl.org/documentation/setup/install-haxe/)
to run on multiple hardware devices.

Simple Socket-API for haxe/limes multiple targets (native, html5, flash)
and gives small lib to use from javascript directly (over raw-socket-swf bridge).

If using this for web -> look into samples inside html5-test folder.
There is some peoteSocketBridge.swf embed, that wrapps around flash-raw-sockets.
You also need some kind of serversided xml-service, to allow
that flashplayer to connect ports. (take care of -> "valid" flash_policy.xml format,
that really sucks!;)

####How To Use:
```
peoteSocket = new PeoteSocket( {
			onConnect: function(connected, msg) {
				 trace("onConnect:"+connected+" - "+msg);
			},
			onClose: function(msg) {
				 trace("onClose:"+msg);
			},
			onError: function(msg) {
				 trace("onError:"+msg);
			},
			onData: function(data) {
			  trace("onData:" + data);
			}
});
peoteSocket.connect("192.168.1.1", 23);
```
onData-Handler for using in haxe has some hint (yet) with
function argument-type, you can wrapp around like that:
```
#if js
	public function onData(data:Array<Int>):Void {
		var bytes:Bytes = Bytes.ofData(new BytesData(data.length));
		for (i in 0...data.length) bytes.set(i, data[i]);
		// use bytes ...
	}
#else
	public function onData(bytes:Bytes):Void {
		// use bytes ...
	}
#end
```
