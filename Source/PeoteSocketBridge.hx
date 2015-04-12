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

import de.peote.socket.flash.bridge.PeoteSocket;

class PeoteSocketBridge {
	
    public static var peoteSocket:Map<String, PeoteSocket>;
    public static function CAN_I_HAS_PEOTESOCKET() { return true; }

	public function new()
	{
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
				if (window.PeoteSocket) return;
				
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
						window.PeoteSocket._bridge.writeBytes(this._instance, data);
					},
					flush: function() {
						window.PeoteSocket._bridge.flush(this._instance);
					},
				});
				window.PeoteSocket._instances = [];
				
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
		
        if (flash.Lib.current.loaderInfo.parameters.onloadcallback != null)
            ExternalInterface.call(flash.Lib.current.loaderInfo.parameters.onloadcallback);
		else ExternalInterface.call("PeoteSocketBridge");
	}
	
    public static function connect(id:String, server:String, port:Int) {
        var p:PeoteSocket = peoteSocket.get(id);
        if (p != null)  {
           p.connect(server, port);
        } else {
            p = new PeoteSocket(id);	
			p.connect(server, port);
            peoteSocket.set(id, p);
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
	
    public static function writeBytes(id:String, data:ByteArray) {
        var p:PeoteSocket = peoteSocket.get(id);
        if (p != null) p.writeBytes(data);
    }
	
    public static function flush(id:String) {
        var p:PeoteSocket = peoteSocket.get(id);
        if (p != null) p.flush();
    }
	

	
}