package peote.io;

abstract UInt16(Int) to Int {
	inline public function new(i:Int) {
		#if debugPeoteIO
		if (i < 0 || i > 0xFFFF) throw('Error: Int $i did not fit into UInt16');
		#end
		this = i;
	}
	@:from static public function fromInt(i:Int) {
		return new UInt16(i);
	}
}