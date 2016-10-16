package de.peote.io;

/**
 * ...
 * @author Sylvio Sell
 */


#if js
	//import js.html.Uint8Array;
	//typedef PeoteBytes = Uint8Array;
	
	typedef PeoteBytes = Array<Int>;
#else
	typedef PeoteBytes = haxe.io.Bytes;
#end