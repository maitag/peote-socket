package de.peote.io;

/**
 * ...
 * @author Sylvio Sell
 */

#if js
	typedef PeoteBytes = Array<Int>;
#else
	typedef PeoteBytes = haxe.io.Bytes;
#end