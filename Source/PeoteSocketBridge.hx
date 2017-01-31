package;
/*        o-o     o-o  o-o-o   o-o     
 *       o   o   o        o       o    
 *      o-o-o   o-o        o     o-o   
 *     o       o     (o)    o       o  
 *    o       o-o    / \     o     o-o 
 *   o             (semmi)            o
 *  o         (only compile this)      o
 * o        (to good old open flash)    o
 */       /*(play and wrapp around)*/  //o
import flash.external.ExternalInterface;//o
import flash.utils.ByteArray;
import haxe.io.Bytes;

import de.peote.socket.flash.bridge.PeoteSocket;

class PeoteSocketBridge {
	
    public static var peoteSocket:Map<String, PeoteSocket>;
    public static function CAN_I_HAS_PEOTESOCKET() { return true; }

	static var proxyServer:String;
	static var proxyPort:Int = 0;
	
	static public function main()
	{
		var onLoadCallback:String = flash.Lib.current.loaderInfo.parameters.onloadcallback;
		proxyServer = flash.Lib.current.loaderInfo.parameters.proxyserver;
		if (flash.Lib.current.loaderInfo.parameters.proxyport != null)
		{
			proxyPort = Std.parseInt(flash.Lib.current.loaderInfo.parameters.proxyport);			
		}
		//ExternalInterface.call("console.log","please debug me ;)");
		
		peoteSocket = new Map<String, PeoteSocket>();
       
		// js oop-kung-fu like here: http://ionel-whatever-code.googlecode.com/svn/trunk/HaxeSocketBridge/
		ExternalInterface.addCallback("connect", connect);
		ExternalInterface.addCallback("close", close);
        ExternalInterface.addCallback("writeByte", writeByte); 
        ExternalInterface.addCallback("writeBytes", writeBytes); 
        ExternalInterface.addCallback("flush", flush); 
		
        ExternalInterface.addCallback("CAN_I_HAS_PEOTESOCKET", CAN_I_HAS_PEOTESOCKET);
		ExternalInterface.call(
		// -----------------------------------------------------------------------
		// javascript code -------------------------------------------------------
			"(function(){
				
				var Class = function(properties){
					var klass = function(event_handlers){ 
						for (var p in event_handlers) {
							if (event_handlers.hasOwnProperty(p)) {
								this[p] = event_handlers[p];
							}
						}
						return this.init.apply(this);
					};
					klass.prototype = properties;
					klass.constructor = arguments.callee;
					return klass;
				};
				
				window.PeoteSocket = new Class({
					init: function() {
						this._instance = ''+window.PeoteSocket._instances.length;
						window.PeoteSocket._instances.push(this);
					},
					connect: function(host, port) {
						window.PeoteSocket._bridge.connect(this._instance, host, port);
					},
					close: function() {
						window.PeoteSocket._bridge.close(this._instance);
					},
					writeByte: function(byte) {
						window.PeoteSocket._bridge.writeByte(this._instance, byte);
					},
					writeBytes: function(data) {
						window.PeoteSocket._bridge.writeBytes(this._instance, window.PeoteSocketTool.fromBytes(data));
					},
					flush: function() {
						window.PeoteSocket._bridge.flush(this._instance);
					}					
				});
				
				window.PeoteSocket._instances = [];
				
				// TODO: optimize here to give embed-element-id by flash.Lib.current.loaderInfo.parameters.elementid
				var f = function(tag){
					var elems = document.getElementsByTagName(tag);
					for (var i = 0; i < elems.length; i++)
						if (elems[i].CAN_I_HAS_PEOTESOCKET) return elems[i];
				};
				window.PeoteSocket._bridge = f('embed') || f('object');
			})"
		// end javascript code ---------------------------------------------------
		// -----------------------------------------------------------------------
		);
		
        if (onLoadCallback != null)
            ExternalInterface.call(onLoadCallback);
		else ExternalInterface.call("PeoteSocketBridge");
	}
	
    public static function connect(id:String, server:String, port:Int) {
        var p:PeoteSocket = peoteSocket.get(id);
        var _server:String = (proxyServer != null) ? proxyServer : server;
        var _port:Int = (proxyPort != 0) ? proxyPort : port;
		
		if (p != null)  {
           p.connect(_server, _port);
        } else {
            p = new PeoteSocket(id);	
			p.connect(_server, _port);
            peoteSocket.set(id, p);
        }
		// for proxys send adress to forward
		if (_server != server || _port != port)
		{
			p.setForward(server,port);
		}

    }
	
    public static function close(id:String) {
        var p:PeoteSocket = peoteSocket.get(id);
        if (p != null) p.close();
    }
	
    public static function writeByte(id:String, byte:Int) {
        var p:PeoteSocket = peoteSocket.get(id);
        if (p != null) p.writeByte(byte);
    }
	
    public static function writeBytes(id:String, data:Array<Int>) {
        var p:PeoteSocket = peoteSocket.get(id);
		if (p != null)
		{
			var ba:ByteArray = new ByteArray();
			for (i in 0...data.length) ba.writeByte(data[i]);
			p.writeBytes(Bytes.ofData(ba));
		}
    }
	
    public static function flush(id:String) {
        var p:PeoteSocket = peoteSocket.get(id);
        if (p != null) p.flush();
    }
	
}