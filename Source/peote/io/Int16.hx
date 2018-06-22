package peote.io;

abstract Int16(Int) to Int {
	inline public function new(i:Int) {
		#if debugPeoteIO
		if (i < -0x8000 || i > 0x7FFF) throw('Error: Int $i did not fit into Int16');
		#end
		this = i;
	}
	@:from static public function fromInt(i:Int) {
		return new Int16(i);
	}
}