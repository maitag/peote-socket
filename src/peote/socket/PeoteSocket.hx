package peote.socket;

/**
 * /\/\/\  ~^
 * @author Sylvio Sell - maitag
**/

#if cpp
	typedef PeoteSocket = peote.socket.cpp.PeoteSocket;
#elseif neko
	typedef PeoteSocket = peote.socket.neko.PeoteSocket;
#elseif hl
	typedef PeoteSocket = peote.socket.neko.PeoteSocket;
#elseif html5
	typedef PeoteSocket = peote.socket.html5.PeoteSocket;
#elseif js
	// TODO: node.js maybe need some special one here:
	typedef PeoteSocket = peote.socket.html5.PeoteSocket;
#elseif flash
	typedef PeoteSocket = peote.socket.flash.PeoteSocket;
#else
	// other targets not supported yet
#end
