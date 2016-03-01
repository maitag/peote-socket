### PeoteSocket - Raw Socket Client Library

This Library is written in [Haxe](http://haxe.org). Uses [OpenFl/Lime](http://www.openfl.org/documentation/setup/install-haxe/)
to run on multiple hardware devices.

Simple Socket-API for haxe/limes multiple targets (native, html5, flash)
and gives small lib to use from javascript directly (over raw-socket-swf bridge).

If using this for web -> look into samples inside html5-test folder.
There is some peoteSocketBridge.swf embed, that wrapps around flash-raw-sockets.
You also need some kind of serversided xml-service, to allow
that flashplayer to connect ports. (take care that flash_policy.xml is "valid" XML-Format !)

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

