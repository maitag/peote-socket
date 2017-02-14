package peote.bridge.js;
/**
 * ...
 * @author Sylvio Sell
 */


#if js

import haxe.Timer;

import js.Browser;
import js.swfobject.SWFObject;


typedef Proxys = {
	?proxyServerWS:String,
	?proxyPortWS:Int,
	
	?proxyServerSWF:String,
	?proxyPortSWF:Int
}


typedef Param = {
	onload:Void->Void,
	?onfail:Void->Void,
	?prefereWebsockets:Bool,
	?proxys:Proxys
}


#if expose_js
@:keep
@:expose("PeoteSocketBridge")
#end
class PeoteSocketBridge
{
	#if expose_js static function main() {}#end

	public static var proxys:Proxys;
	
	public static var onload: Void->Void;
	public static var onfail: Void->Void;
	
	
	static var checkedSWF:Bool = false;
	static var wsCheckedAlready :Bool = false;
	
	static var swfBridgeReady:Bool = false;
	
	static var isLoaded:Bool = false;
	
	public static function load( param:Param ):Void
	{
		if (isLoaded) {
			onload(); // already loaded
		}
		else {
			proxys = param.proxys;
			onload = param.onload;
			onfail = param.onfail;
			if (param.prefereWebsockets) loadWS() else loadSWF();
		}
	}
	
	public static function loadSWF():Void
	{
		if (checkedSWF) return;
		checkedSWF = true;
		// try to load peoteSocketBridge swf
		trace("SWFObject.version:" + SWFObject.version);
		trace("FlashPlayerVersion:" + SWFObject.getFlashPlayerVersion());
		if (SWFObject.hasFlashPlayerVersion("11.2.0"))
		{
			//SWFObject.switchOffAutoHideShow();
			
			SWFObject.addDomLoadEvent( function() {
			//SWFObject.addLoadEvent( function() {
				
				// create html element to embed swf
				var div = Browser.document.createElement("div");
				//div.style.visibility = "hidden";
				Browser.document.body.appendChild(div);
				var id = div.id = "PeoteSocketBridge";
				//SWFObject.createCSS("html", "height:100%;");
				//SWFObject.createCSS("body", "margin:0; padding:0; overflow:hidden; height:100%;");
				//SWFObject.createCSS("#"+id, "visibility:hidden;");
				
				// load swf PeotesocketBridge
				var attributes = { data:"peoteSocketBridge.swf", width:"1", height:"1" };
				var params = {
					//"flashvars": "onloadcallback=PeoteSocketBridge", // <- is default
					"flashvars": "onloadcallback=peote.bridge.js.PeoteSocketBridge.peoteSocketBridgeAvailable",
					"menu": "false",
					"scale": "noScale",
					"allowScriptAccess": "always", //"sameDomain" works to
					"allowNetworking": "true",
					"bgcolor": "#000000"
				};
				if (proxys != null)
				{
					if (proxys.proxyServerSWF != null)
					{
						params.flashvars += "&proxyserver=" + proxys.proxyServerSWF;
					}
					if (proxys.proxyPortSWF != null)
					{
						params.flashvars += "&proxyport=" + proxys.proxyPortSWF;
					}
				}
				var myObject = SWFObject.createSWF(attributes, params, id); //SWFObject.embedSWF(
				myObject.style.position = "absolute";
				//myObject.style.visibility = "hidden"; // ups .. did NOT work on Microsofts Internet-Explorer 10 !!!!!!!!!

				trace("try to embed peoteSocketBridge...");
				// TODO: check myObject and TimerOut to prevent Error in embedding flash or external-interface
				var timer = new Timer(6000);
				timer.run = function()
				{
					timer.stop();
					if (!swfBridgeReady)
					{
						SWFObject.removeSWF(id);
						trace("could not load peoteSocketBridge.swf");
						loadWS();
					}
				}
				
			});
		}
		else
		{
			trace("no flashplayer found");
			loadWS();
		}
	}
	
	public static function loadWS():Void
	{
		if (wsCheckedAlready) {
			onfail(); // if checking twice both not available
		}
		else {
			wsCheckedAlready = true;
		
			trace("check for websocket support");
			var supported:Bool = untyped __js__("('WebSocket' in window || 'MozWebSocket' in window)");
			if (supported) {
				trace("Websockets available");
				isLoaded = true;
				onload();
			}
			else {
				trace("Websockets  not available");
				loadSWF(); // try SWF-wrapper
			}
		}
	}
	
	//@:keep @:expose("PeoteSocketBridge") public static function peoteSocketBridgeAvailable():Void {
	@:keep @:expose public static function peoteSocketBridgeAvailable():Void {
		swfBridgeReady = true;
		trace("swf-bridge is READY");
		isLoaded = true;
		onload();
	}

}

#end
