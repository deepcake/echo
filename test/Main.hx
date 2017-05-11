package;

import haxe.unit.TestRunner;

/**
 * ...
 * @author https://github.com/wimcake
 */
class Main {

	static public function main() {
		var r = new TestRunner();

		r.add(new TestSignal());
		r.add(new TestComponent());
		r.add(new TestComponentTypes());
		r.add(new TestView());
		r.add(new TestSystem());
		r.add(new TestSmoke());
		r.add(new TestPerfomance());

		var ret = r.run();

		#if sys
		Sys.exit(ret ? 0 : 1);
		#end
	}

}
