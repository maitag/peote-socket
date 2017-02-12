package peote.bridge;
import peote.bridge.js.PeoteSocketBridge;
/**
 * ...
 * @author Sylvio Sell
 */

typedef Proxys = {
	?proxyServerWS:String,
	?proxyPortWS:Int,
	
	?proxyServerSWF:String,
	?proxyPortSWF:Int
}
typedef Param = {
	onload:Void->Void,
	?onfail:Void->Void,
	?prefareWebsockets:Bool,
	?proxys:Proxys
}

#if js
typedef PeoteSocketBridge = peote.bridge.js.PeoteSocketBridge;
#end

#if flash
class PeoteSocketBridge
{
	public static var proxys:Proxys;
	public static function load( param:Param ):Void
	{
		proxys = param.proxys;
		param.onload();
	}
}
#end

#if cpp
class PeoteSocketBridge
{
	public static function load( param:Param ):Void
	{
		param.onload();
	}
}
#end


