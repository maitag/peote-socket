# PeoteSocket - Raw TCP Socket Client Library

This Library is written in [Haxe](http://haxe.org) to provide simple Socket-API  
for multiple targets (cpp, neko, html5, flash, android). 

Inside webbrowser it gives fallback-support (websocket or swf-socket-bridge) and  
on server side there is [peote-proxy](https://github.com/maitag/peote-proxy) to wrap around raw-tcp.  

## Installation:
```
haxelib git peote-socket https://github.com/maitag/peote-socket
```


## How To Use:
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
peoteSocket.connect("mud.tubmud.de", 7680);
```


## Fallback and proxys for html5:

To get swf/websocket fallback support for html5-targets,  
build the dependence `peoteSocketBridge.swf` first:  
```
haxe peoteSocketBridge.hxml
```

For html5 or flash-targets you can set a proxy-address before creating a new PeoteSocket,  
cpp-targets will ignore this and calls the onload-callback directly.  
```
PeoteSocketBridge.load( {
	onload: openSocket,      // callback if swfbridges is loaded or websockets available
	preferWebsockets: true,  // trying websockets first and fallback to flash
	proxys: {
		proxyServerWS:"localhost",  // proxy for websocket
		proxyPortWS  : 3211,
		
		proxyServerSWF:"localhost", // proxy for peoteSocketBridge.swf
		proxyPortSWF  :3211,
	},
	onfail: function() { trace("Browser doesn't support flash-raw-sockets or websockets"); }
});


function openSocket() { 
	peoteSocket = new PeoteSocket({
	...
}

```


## Use as Javascript Library:

To use with Javascript inside Webbrowser, you can run `build-js-lib.bat` to build  
a standalone `PeoteSocket.js` library. Look inside the `js-lib/` folder for a sample.  


## TODO:
- better error-handling
- more tests and samples