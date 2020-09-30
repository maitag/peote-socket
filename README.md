# PeoteSocket - Raw TCP Socket Client Library

This Library is written in [Haxe](http://haxe.org) to provide simple Socket-API  
for multiple targets (cpp, neko, html5, flash, android). 

On server side there is [peote-proxy](https://github.com/maitag/peote-proxy) to wrap websockets around raw-tcp.  

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


## Use as Javascript Library:

To use with Javascript inside Webbrowser, you can run `build-js-lib.bat` to build  
a standalone `PeoteSocket.js` library. Look inside the `js-lib/` folder for a sample.  


## TODO:
- better error-handling
- more tests and samples