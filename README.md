# PeoteSocket - Raw TCP Socket Client Library

This Library is written in [Haxe](http://haxe.org) to provide simple Socket-API  
for multiple targets (cpp, neko, html5, flash, android). 

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


## Proxy for html5:

For html5 target you can set a proxy-address before creating a new PeoteSocket:
```
peoteSocket.setProxy(<server>, <Port>)
```

On server side there is [peote-proxy](https://github.com/maitag/peote-proxy) to wrap websockets around raw-tcp.  


## TODO:
- better error-handling
- maxpayload settings for websockets
- more tests and samples