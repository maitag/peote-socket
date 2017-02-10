haxe peoteSocketBridge.hxml

copy Export\flash\release\bin\peoteSocketBridge.swf js-lib-test\
copy dependencies\swfobject-2.3.js js-lib-test\

haxe -cp Source -js js-lib-test/PeoteSocket.js -main peote.socket.PeoteSocket -D expose_js -D js-flatten -dce full

pause