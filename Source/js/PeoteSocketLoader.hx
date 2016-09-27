package js;
/**
 * ...
 * @author Sylvio Sell
 */
import haxe.Timer;

#if js
import js.Browser;
import js.swfobject.SWFObject;
#end

class PeoteSocketLoader
{
	#if js
	public static var onload:Void->Void;
	public static var onfail:Void->Void;
	
	static var checkedSWF:Bool = false;
	static var checkedWS:Bool  = false;
	
	static var swfBridgeReady:Bool = false;
	#end
	
	public static function load(onload:Void->Void, ?onfail:Void->Void, prefareWebsockets:Bool=false):Void
	{
		#if js
		PeoteSocketLoader.onload = onload;
		PeoteSocketLoader.onfail = onfail;
		
		if (prefareWebsockets) loadWS() else loadSWF();
		#else
		onload(); // no js (natives go throught)
		#end
	}
	
	#if js
	public static function loadSWF():Void
	{
		if (checkedSWF) return;
		checkedSWF = true;
		// try to load peoteSocketBridge swf
		trace("SWFObject.version:" + SWFObject.version);
		trace("FlashPlayerVersion:" + SWFObject.getFlashPlayerVersion());
		if (SWFObject.hasFlashPlayerVersion("11.2.0"))
		{
			SWFObject.switchOffAutoHideShow();
			
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
					"flashvars": "onloadcallback=js.PeoteSocketLoader.peoteSocketBridgeAvailable",
					"menu": "false",
					"scale": "noScale",
					"allowScriptAccess": "always",
					"allowNetworking": "true",
					"bgcolor": "#000000"
				};
				var myObject = SWFObject.createSWF(attributes, params, id);
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
			trace("no flashplayer found, using websocket instead");
			loadWS();
		}
	}
	
	public static function loadWS():Void
	{
		if (checkedWS) return;
		checkedWS = true;
		
		trace("check for websocket support");
		var supported:Bool = untyped __js__("('WebSocket' in window || 'MozWebSocket' in window)");
		if (supported)
		{
			trace("Websockets available");
			onload();
		}
		else loadSWF(); // try SWF-wrapper
	}
	
	//@:keep @:expose("PeoteSocketBridge") public static function peoteSocketBridgeAvailable():Void {
	@:keep @:expose public static function peoteSocketBridgeAvailable():Void {
		swfBridgeReady = true;
		trace("swf-bridge is READY");
		onload();
	}
	#end
	
	
}