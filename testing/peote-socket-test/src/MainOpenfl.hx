package;


import openfl.display.Sprite;
import openfl.events.Event;

import ui.OutputText;
import test.Stress;

class MainOpenfl extends Sprite {
	
	var host:String = "localhost";
	var port:Int = 7680;
	
	var logClient:OutputText;
			
	var minBytes:Int = 0x10000;
	var maxBytes:Int = 0x10000; // <- maximum (see may payload also into proxy for websocket)

	var test:Stress;
	
	public function new () {
		
		super ();
		
		logClient = new OutputText(290, 5, 280, 550);
		addChild(logClient);
		
		stage.addEventListener (Event.RESIZE, stageOnResize);
		
		test = new Stress(host, port, log, minBytes, maxBytes );
	}
	
	public function log(s:String):Void {
		logClient.log(s);
	}

	private function stageOnResize (event:Event):Void {
	
		var contentWidth = 574;
		var contentHeight = 560;
		
		var maxScaleX = stage.stageWidth / contentWidth;
		var maxScaleY = stage.stageHeight / contentHeight;
		var scale;
		
		if (maxScaleX < maxScaleY)
			scale = maxScaleX;
		else scale = maxScaleY;
		
		scaleX = scale;
		scaleY = scale;
		x = stage.stageWidth / 2 - (contentWidth * scale) / 2;
		y = stage.stageHeight / 2 - (contentHeight * scale) / 2;
	
	}
}
