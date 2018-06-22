package peote.io;

abstract Int32(Int) from Int to Int {
	inline public function new(i:Int) {
		this = i;
	}
	@:from static public function fromFloat(f:Float) {
		#if debugPeoteIO
		if (f < -2147483648 || f > 2147483647) throw('Error: Float $f did not fit into Int32');
		#end
		return new Int32(Std.int(f));
	}
}