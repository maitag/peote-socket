### PeoteSocket - Raw Socket Client Library

This Library is written in [Haxe](http://haxe.org) to provide simple Socket-API  
for multiple targets (cpp, java, html5, flash). 

Inside webbrowser it gives fallback-support (websocket or swf-socket-bridge) and  
on server side there is [peote-proxy](https://github.com/maitag/peote-proxy) to wrap around raw-tcp.  

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
peoteSocket.connect("mud.tubmud.de", 7680);
```
  
  
For html5 or flash-targets you can set proxy-address before creating new PeoteSocket  
( for cpp this will be ignored and calls onload-callback directly ):  
```
PeoteSocketBridge.load( {
	onload: openSocket,       // callback if swfbridges is loaded or websockets available
	prefareWebsockets: true,  // trying websockets first and fallback to flash
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

####TODO:
- better error-handling
- more tests scripts for peote-proxy
- updating telnet/mud-client