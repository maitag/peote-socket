haxe peoteSocketBridge.hxml

copy Export\flash\release\bin\peoteSocketBridge.swf html5-test\
copy dependencies\swfobject-2.3.js html5-test\

haxe -cp Source -js js-lib-test/PeoteSocket.js -main de.peote.socket.PeoteSocket -D expose_js -D js-flatten -dce full

pause