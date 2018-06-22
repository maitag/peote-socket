package peote.io;

abstract Byte(Int) to Int {
	inline public function new(i:Int) {
		#if debugPeoteIO
		if (i < 0 || i > 0xFF) throw('Error: Int $i did not fit into Byte');
		#end
		this = i;
	}
	@:from static public function fromInt(i:Int) {
		return new Byte(i);
	}
}