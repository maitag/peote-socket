package peote.telnet;

/**
 * ported old as3 code from 2008
 * MaiMud-flashclient for >telnet mud.tubmud.de 7680
 * @author Sylvio Sell - long live haxe :)=
 */

import haxe.io.Bytes;

import peote.socket.PeoteSocket;
import peote.io.PeoteBytesInput;

class PeoteTelnet
{

	static var WILL:Int = 0xFB;	// 251 - WILL (option code)
	static var WONT:Int = 0xFC;	// 252 - WON'T (option code)
	static var DO:Int   = 0xFD;	// 253 - DO (option code)
	static var DONT:Int = 0xFE;	// 254 - DON'T (option code)
	static var IAC:Int  = 0xFF;	// 255 - Interpret as Command (IAC)
	static var SB:Int 	= 0xFA;	// 250 - SB
	static var SE:Int 	= 0xF0;	// 241 - SE
	static var NOP:Int =  0xF1;	// 0   - NOP (no operation)
	
	static var ECHO:Int = 1;			// http://www.pcmicro.com/netfoss/RFC857.html
	static var TERMINALTYPE:Int = 24;	// https://tools.ietf.org/html/rfc884
	static var EOR:Int = 25;			// End of Record
	static var NAWS:Int = 31;			// Negotiate About Window Size: http://www.ietf.org/rfc/rfc1073.txt

	var state:Int = 0;
	var peoteSocket:PeoteSocket;
	
	var width:Int;
	var height:Int;


	var negotiate_data:Array<Int>;
	#if debugtelnet var debug:String = ""; #end
	
	public function new(peoteSocket, width:Int=107, height:Int=46)
	{
		this.peoteSocket = peoteSocket;
		this.width = width;
		this.height = height;
	}
	
	public inline function writeByte(b:Int):Void
	{
		peoteSocket.writeByte(b);
		peoteSocket.flush();
	}
	
	public inline function writeBytes(bytes:Bytes):Void
	{
		peoteSocket.writeBytes(bytes);
		peoteSocket.flush();
	}
	
	public inline function parseTelnetData(input:PeoteBytesInput, remoteInput:Int->Void):Void
	{
		for (i in 0...input.length)
		{
			var b:Int = input.readByte();
			
			switch (state)
			{
				case 0 :
					if (b == IAC)
					{
						state = 1;
						#if debugtelnet debug+="\nRECEIVE: IAC"; #end
					}
					else
					{
						if (b != NOP) remoteInput(b);
					}

				case 1 :// after IAC  --------------------------------------
					if (b == WILL)
					{
						state = 2;
						#if debugtelnet debug+=", WILL"; #end
					}
					else if (b == DO)
					{
						state = 3;
						#if debugtelnet debug+=", DO"; #end
					}
					/*else if (b == DONT)
					{
						state = 4;
						#if debugtelnet debug+=", DONT"; #end
					}*/
					else if (b == SB)
					{
						state = 5;
						negotiate_data = new Array<Int>();
						#if debugtelnet debug += "negotiate start: " ; #end
						#if debugtelnet debug+=", SB"; #end
					}
					/*else if (b == WONT)
					{
						state = 0;
						#if debugtelnet debug+=", WONT"; #end
					}*/
					else
					{
						state = 0;
						#if debugtelnet debug+=", "+b; #end
					}

				case 2 :// -------------------------------------- WILL  --------------------------------------
					if (b == ECHO)
					{
						#if debugtelnet debug+=", ECHO"; #end
						
						//#if debugtelnet debug+="\nSEND: IAC,DO,ECHO"; #end
						//peoteSocket.writeByte(IAC);peoteSocket.writeByte(DO);peoteSocket.writeByte(ECHO);peoteSocket.flush();
						#if debugtelnet debug+="\nSEND: IAC,WONT,ECHO"; #end
						peoteSocket.writeByte(IAC);peoteSocket.writeByte(WONT);peoteSocket.writeByte(ECHO);peoteSocket.flush();
						//#if debugtelnet debug+="\nSEND: IAC,DONT,ECHO"; #end
						//peoteSocket.writeByte(IAC);peoteSocket.writeByte(DONT);peoteSocket.writeByte(ECHO);peoteSocket.flush();
					}
					else if (b == EOR)
					{
						#if debugtelnet debug+=", EOR"; #end
						#if debugtelnet debug+="\nSEND: IAC,DO,EOR"; #end
						peoteSocket.writeByte(IAC);peoteSocket.writeByte(DO);peoteSocket.writeByte(EOR);peoteSocket.flush();
					}
					else
					{
						#if debugtelnet debug+=", "+b; #end
						#if debugtelnet debug+="\nSEND: IAC,WONT,"+b; #end
						peoteSocket.writeByte(IAC);peoteSocket.writeByte(WONT);peoteSocket.writeByte(b);peoteSocket.flush();
					}
					state = 0;

				case 3 :// -------------------------------------- DO  --------------------------------------
					/*if (b == ECHO)
					{
						#if debugtelnet debug += ", ECHO"; #end
						
						#if debugtelnet debug+="\nSEND: IAC,WONT,ECHO"; #end
						peoteSocket.writeByte(IAC);	peoteSocket.writeByte(WONT); peoteSocket.writeByte(b); peoteSocket.flush();						
						//#if debugtelnet debug+="\nSEND: IAC,WILL,ECHO"; #end
						//peoteSocket.writeByte(IAC);	peoteSocket.writeByte(WILL); peoteSocket.writeByte(b); peoteSocket.flush();
						//#if debugtelnet debug+="\nSEND: IAC,DONT,ECHO"; #end
						//peoteSocket.writeByte(IAC);peoteSocket.writeByte(DONT);peoteSocket.writeByte(b);peoteSocket.flush();
					}
					else*/ if (b == TERMINALTYPE)
					{
						#if debugtelnet debug += ", TERMINALTYPE"; #end
						
						#if debugtelnet debug+="\nSEND: IAC,WILL,TERMINALTYPE"; #end
						peoteSocket.writeByte(IAC);peoteSocket.writeByte(WILL);peoteSocket.writeByte(TERMINALTYPE);peoteSocket.flush();
					}
					else if (b == NAWS)
					{
						// Screen-Size aendern
						#if debugtelnet debug+=", NAWS (window size)"; #end
						#if debugtelnet debug+="\nSEND: IAC,WILL,NAWS (window size is cool ;)"; #end
						peoteSocket.writeByte(IAC);	peoteSocket.writeByte(WILL); peoteSocket.writeByte(NAWS); peoteSocket.flush();
						sendNAWS();
					}
					else if (b == EOR)
					{
						#if debugtelnet debug+="\nSEND: IAC,DO,EOR"; #end
						peoteSocket.writeByte(IAC); peoteSocket.writeByte(DO); peoteSocket.writeByte(EOR); peoteSocket.flush();
					}
					else
					{
						#if debugtelnet debug += ", " + b; #end						
						#if debugtelnet debug+="\nSEND: IAC,WONT,"+b; #end
						peoteSocket.writeByte(IAC);	peoteSocket.writeByte(WONT); peoteSocket.writeByte(b); peoteSocket.flush();
						//peoteSocket.writeByte(IAC);	peoteSocket.writeByte(DONT); peoteSocket.writeByte(b); peoteSocket.flush();
					}
					state = 0;
				/*
				case 4 :// -------------------------------------- DONT --------------------------------------
					if (b == ECHO)
					{
						#if debugtelnet debug += ", ECHO"; #end
					}
					else
					{
						#if debugtelnet debug += ", " + b; #end
					}
					state = 0;
				*/	
				case 5 ://  Negotiate --------------------------------------
					if (b == IAC)
					{
						#if debugtelnet debug += ", IAC"; #end
						state = 6;
					}
					else
					{
						#if debugtelnet debug += ", " + b; #end
						negotiate_data.push(b);
					}
					
					
				case 6 ://  Negotiate SE END -----------------------------------
					if (b == SE)
					{
						#if debugtelnet debug += ", SE"; #end
						if (negotiate_data[0] == TERMINALTYPE && negotiate_data[1] == 1)
						{
							#if debugtelnet debug+="\nSEND: IAC,SB, TERMINALTYPE,IS, 65,78,83,73 ,IAC,SE (send 'ansi' terminal type)"; #end
							peoteSocket.writeByte(IAC);	peoteSocket.writeByte(SB); peoteSocket.writeByte(TERMINALTYPE); peoteSocket.writeByte(0);
							peoteSocket.writeByte(65); peoteSocket.writeByte(78); peoteSocket.writeByte(83); peoteSocket.writeByte(73);
							peoteSocket.writeByte(IAC);	peoteSocket.writeByte(SE); peoteSocket.flush();
						}
					}
					else
					{
						#if debugtelnet debug += ", " + b; #end
					}
					
					#if debugtelnet debug += " negotiate end" ; #end
					state = 0;
					
			} // end switch states
		} // end while
		
		#if debugtelnet if (debug!="") { trace(debug); debug=""; } #end
		
	} // end parseTelnetData

	
	public inline function resize(width:Int, height:Int):Void
	{
		this.width = width;
		this.height = height;
		sendNAWS();
	}
	
	public inline function sendNAWS():Void
	{
		#if debugtelnet  debug+="\nSEND: IAC,SB,NAWS,0,"+width+",0,"+height+",IAC,SE (send terminal size)"; #end
		peoteSocket.writeByte(IAC);	peoteSocket.writeByte(SB); peoteSocket.writeByte(NAWS);
		peoteSocket.writeByte(0); peoteSocket.writeByte(width);
		peoteSocket.writeByte(0); peoteSocket.writeByte(height);
		peoteSocket.writeByte(IAC); peoteSocket.writeByte(SE); peoteSocket.flush();
	}
	
}