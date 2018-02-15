package;

using tink.CoreApi;
#if macro
using tink.MacroApi;
#end

import tink.cli.*;
import tink.Cli;


/**
 * simple commandline stresstest of peote-net
 * by Sylvio Sell, Rostock 2018
 * 
 **/
import test.Stress;


class MainCli 
{
	
	static function main()
	{
		var peoteNetTest = new PeoteSocketTest();
		Cli.process(Sys.args(), peoteNetTest).handle(
			function(result:Outcome<Noise, Error>) {
				switch result
				{
					case Success(_): //Sys.exit(0);
					case Failure(e):
						var message = "\nError while parsing commandline parameters: " + e.message;
						if(e.data != null) message += ', ${e.data}';
						Sys.println(message);
						peoteNetTest.doc(); 
						Sys.exit(e.code);
				}
			}
		);
	}
	
}

@:alias(false)
class PeoteSocketTest {
	// ---------------- Commandline Parameters
	/**
		minimum number of random Bytes to send per chunk		
		*
	**/
	@:flag('--minBytes','-min') @:alias(false)
	public var minBytes:Int = 1;
	
	/**
		maximum number of random Bytes to send per chunk		
		*
	**/
	@:flag('--maxBytes','-max') @:alias(false)
	public var maxBytes:Int = 0xFFFFF;
	
	/**
		host/ip of echo-server
		*
	**/
	@:flag('--host', '-o') @:alias(false)
	public var host:String = "localhost";
	
	/**
		port of echo-server
		*
	**/
	@:flag('--port', '-p') @:alias(false)
	public var port:Int = 7680;
	
	/**
		delay time in milliseconds between send of data-chunk
		*
	**/
	@:flag('--delayTime', '-d') @:alias(false)
	public var delayTime:Int = 0;
	
	/**
		 prints out amount of bytes each send/recieve of data-chunk 
		*
	**/
	@:flag('--verbose', '-v') @:alias(false)
	public var verbose:Bool = false;
	
	/**
		stop the client/server on error		
		*
	**/
	@:flag('--stopOnError', '-e') @:alias(false)
	public var stopOnError:Bool = false;
	
	/**
		print this help
	**/
	@:flag('--help','-h') @:alias(false)
	public var help:Bool = false;
	// --------------------------------------
	
	var test:Stress;
	public function new() {}

	/**
		Little tool that for testing stability of peote-socket.
		(https://github.com/maitag/peote-socket)
		
		Before get starting you need to run a echo-server. 
		(https://github.com/maitag/peote-proxy/testing/echoserver.pl)
	**/
	@:defaultCommand
	public function stress(rest:Rest<String>) {
		if (help) doc();
		else {
			//Sys.println('verbose: $verbose');
			//Sys.println('rest: $rest');
			
			test = new Stress(host, port, log, minBytes, maxBytes,
							  delayTime, verbose, stopOnError);
		}
	}
	
	public function log(s:String):Void {
		Sys.println('$s');
		// TODO: using good lib for colored output here
	}
	
	public function doc():Void {
		Sys.println(Cli.getDoc(this));
	}

}
