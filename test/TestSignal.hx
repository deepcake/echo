package;

import echo.utils.Signal;
import haxe.unit.TestCase;

/**
 * ...
 * @author https://github.com/deepcake
 */
class TestSignal extends TestCase {


	public function new() super();


	public function test_build() {
		var s0 = new Signal();
		var s2 = new Signal<Int->Void>();
		var s4 = new Signal<Int->Int->Float->Bool>();

		var actual = false;
		s4.add(function(a, b, c) return (actual = true));
		s4.dispatch(0, 0, 0.0);

		assertEquals(true, actual);
	}

	public function test_lifecycle() {
		var s = new Signal<String->Void>();
		var actual = '';
		var f1 = function(str) actual += str;
		var f2 = function(str) actual += '$str!';

		s.add(function(_) actual = '');

		s.add(f1);
		assertTrue(s.has(f1));

		s.add(f2);

		s.dispatch('A');
		assertEquals('AA!', actual);

		s.remove(f1);
		assertFalse(s.has(f1));

		s.dispatch('A');
		assertEquals('A!', actual);

		s.removeAll();

		s.dispatch('B');
		assertEquals('A!', actual);
	}

}
