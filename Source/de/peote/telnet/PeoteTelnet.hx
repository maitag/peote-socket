package de.peote.telnet;

/**
 * ported old as3 code from 2008
 * MaiMud-flashclient for >telnet mud.tubmud.de 7680
 * @author Sylvio Sell - long live haxe :)=
 */

import haxe.remoting.FlashJsConnection;
import lime.utils.ByteArray;

import de.peote.socket.PeoteSocket;

class PeoteTelnet
{

	static var CR:Int 	= 13;	// Carriage Return (CR)
	static var WILL:Int = 0xFB;	// 251 - WILL (option code)
	static var WONT:Int = 0xFC;	// 252 - WON'T (option code)
	static var DO:Int   = 0xFD;	// 253 - DO (option code)
	static var DONT:Int = 0xFE;	// 254 - DON'T (option code)
	static var IAC:Int  = 0xFF;	// 255 - Interpret as Command (IAC)
	static var SB:Int 	= 0xFA;	// 250 - SB
	static var SE:Int 	= 0xF0;	// 240 - SE

	var state:Int = 0;
	var peoteSocket:PeoteSocket;
	
	var breite:Int = 107;
	var hoehe:Int = 46;

	var input:ByteArray;
	
	public function new(peoteSocket) 
	{
		this.peoteSocket = peoteSocket;
		input = new ByteArray();
	}
	
	public function parseTelnetData(myBA:ByteArray):Void
	{
		// zuerst den verbliebenen unverarbeiteten input mit den neuen socket-daten ergaenzen
		// myBA.position = 0;
		if (input.bytesAvailable == 0) { input.clear();}
		var oldpos:Int = input.position;
		try { input.writeBytes(myBA); } catch (unknown : Dynamic) { trace("ERROR: input.writeBytes(myBa) :"+ unknown); }
		input.position = oldpos;
		
		
		while (input.bytesAvailable > 0)
		{
			var b:Int = input.readUnsignedByte();
			//trace(b, input.bytesAvailable );
			switch (state)
			{
				case 0 :
					// If the current byte is the "Interpret as Command" code, set the state to 1.
					if (b == IAC)
					{
						state = 1;
						trace("\nRCV: IAC");
					}
					else
					{
						if (b != CR) trace( String.fromCharCode(b) );
					}

				case 1 :// nach jedem IAC vom Server
					if (b == WILL)
					{
						state = 2;
						trace(", WILL");
					}
					else if (b == DO)
					{
						state = 3;
						trace(", DO");
					}
					else if (b == WONT)
					{
						state = 0;
						trace(", WONT");
					}
					else
					{
						state = 0;
						trace(", "+b);
					}

				case 2 :// nach jedem WILL vom Server
					trace(", "+b);
					
					if (b == 1)
					{
						//trace("(server will ECHO)");
						//trace("\nSND: IAC,DO,ECHO (JA, erstmal zusagen ;)");
						//peoteSocket.writeByte(IAC);peoteSocket.writeByte(DO);peoteSocket.writeByte(1);peoteSocket.flush();
						trace("\nSND: IAC,WONT,ECHO  (nein , KEIN ECHO HIER)");
						peoteSocket.writeByte(IAC);peoteSocket.writeByte(WONT);peoteSocket.writeByte(b);peoteSocket.flush();
					}
					/*else if (b == 25)
					{
						trace("(server will EOR)");
						trace("\nSND: IAC,DO,EOR (JA, erstmal zusagen ;)");
						peoteSocket.writeByte(IAC);peoteSocket.writeByte(DO);peoteSocket.writeByte(1);peoteSocket.flush();
					}*/
					else
					{
						trace("\nSND: IAC,WONT,"+b+"  (nein , erstmal nix geben ;)");
						peoteSocket.writeByte(IAC);peoteSocket.writeByte(WONT);peoteSocket.writeByte(b);peoteSocket.flush();
					}
					state = 0;

				case 3 :// nach jedem DO vom Server
					// NAWS
					if (b == 31)
					{
						// Screen-Size aendern
						trace(", NAWS (window size)");
						trace("\nSND: IAC,WILL,NAWS (JA, window size aendern ist ne coole Idee ;)");
						peoteSocket.writeByte(IAC);
						peoteSocket.writeByte(WILL);
						peoteSocket.writeByte(b);
						peoteSocket.flush();
						
						trace("\nSND: IAC,SB,NAWS,0,80,0,40,IAC,SE (window size zum server senden)");
						peoteSocket.writeByte(IAC);
						peoteSocket.writeByte(SB);
						peoteSocket.writeByte(31);
						peoteSocket.writeByte(0);
						peoteSocket.writeByte(breite);
						peoteSocket.writeByte(0);
						peoteSocket.writeByte(hoehe);
						peoteSocket.writeByte(IAC);
						peoteSocket.writeByte(SE);
						peoteSocket.flush();
					}
					/*else if (b == 25)
					{
						trace("\nSND: IAC,DO,EOR (END OF RECORD )");
						peoteSocket.writeByte(IAC);
						peoteSocket.writeByte(DO);
						peoteSocket.writeByte(b);
						peoteSocket.flush();
					}*/
					else
					{
						// Ablehnen
						trace(", "+b);
						trace("\nSND: IAC,WONT,"+b);
						peoteSocket.writeByte(IAC);
						peoteSocket.writeByte(WONT);
						peoteSocket.writeByte(b);
						peoteSocket.flush();
					}
					state = 0;
					
			} // end switch states
		} // end while

	} // end parseTelnetData

	
}