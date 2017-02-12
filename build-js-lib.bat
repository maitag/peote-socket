haxe peoteSocketBridge.hxml

copy Export\flash\release\bin\peoteSocketBridge.swf js-lib\
copy dependencies\swfobject-2.3.js js-lib\

haxe -cp Source -js js-lib/PeoteSocket.js -main peote.socket.PeoteSocket -D expose_js -D js-flatten -dce full

pause