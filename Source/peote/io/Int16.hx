package peote.io;

abstract Int16(Int) to Int {
	
	public static inline var MIN:Int = -0x8000;
	public static inline var MAX:Int = 0x7FFF;

	inline public function new(i:Int) 
	{
		#if restrictPeoteIO			
			this = if (i < MIN) MIN else if (i > MAX) MAX else i;			
		#elseif debugPeoteIO			
			if (i < MIN || i > MAX) throw('Error: Int $i did not fit into Int16');
			this = i;			
		#else			
			this = i;			
		#end
	}
	
	@:from static public inline function fromInt(i:Int) return new Int16(i);
	
	#if restrictPeoteIO	
		inline function _max(v):Byte return (v > MAX) ? MAX : v;
		inline function _min(v):Byte return (v < MIN) ? MIN : v;
		inline function _maxMin(v):Byte return if (v > MAX) MAX else if (v < MIN) MIN else v;
		inline function _minMax(v):Byte return if (v < MIN) MIN else if (v > MAX) MAX else v;
		
		//@:op(A + B) inline function add  (v):Byte return _maxMin(this + v);
		//@:op(A - B) inline function subtr(v):Byte return _minMax(this - v);
		@:op(++A) inline function inc()  return this = _max(this + 1);
		@:op(--A) inline function dec()  return this = _min(this - 1);
		@:op(A++) inline function incp() { var t = this; this = _max(this + 1); return t; }
		@:op(A--) inline function decp() { var t = this; this = _min(this - 1); return t; }	
	#end
}