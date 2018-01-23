package peote.bridge;

/**
 * by Sylvio Sell - Rostock 2015
 * 
 */


#if js
typedef PeoteSocketBridge = peote.bridge.js.PeoteSocketBridge;

#elseif flash
class PeoteSocketBridge
{
	public static var proxys:Proxys;
	public static function load( param:Param ):Void
	{
		proxys = param.proxys;
		param.onload();
	}
}

#elseif (cpp || neko)
class PeoteSocketBridge
{
	public static function load( param:Param ):Void
	{
		param.onload();
	}
}

#end


