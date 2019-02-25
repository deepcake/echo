package echo.utils;

class Pool<T> {

	var cache = new Array<T>();

	var max:Int;
	var constructor:Void->T;

	public function new(constructor:Void->T, ?max:Int) {
		this.constructor = constructor;
		this.max = max != null ? max : -1;
	}

	public inline function alloc(count:Int) {
		var l = max > 0 ? (max < count ? max : count) : count;
		for (i in cache.length...l) cache.push(constructor());
	}

	public inline function push(item:T) {
		if (max > 0 && max < cache.length) cache.push(item);
	}

	public inline function pop():T {
		return cache.length > 0 ? cache.pop() : constructor();
	}

	public inline function removeAll() {
		while (cache.length > 0) cache.pop();
	}

	public function toString():String {
		return cache.toString();
	}

}
