package;

import echo.Echo;
import echo.View;
import echo.System;
import haxe.unit.TestCase;

/**
 * ...
 * @author octocake1
 */
class TestView extends TestCase {
	
	
	static public var ACTUAL = '';
	
	var ch:Echo;
	
	
	public function new() super();
	
	
	override public function setup() {
		ch = new Echo();
		ACTUAL = '';
	}
	
	public function test1() {
		var viewabc = new echo.View<{a:C1, b:C2, c:C3}>();
		var viewa = new echo.View<{a:C1}>();
		var viewb = new echo.View<{b:C2}>();
		var viewc = new echo.View<{c:C3}>();
		ch.addView(viewabc);
		ch.addView(viewa);
		ch.addView(viewb);
		ch.addView(viewc);
		
		for (i in 0...100) {
			var id = ch.id();
			ch.setComponent(id, new C1());
			if (i % 2 == 0) ch.setComponent(id, new C2());
			if (i % 5 == 0) ch.setComponent(id, new C3());
		}
		
		assertEquals(100, viewa.entities.length);
		assertEquals(50, viewb.entities.length);
		assertEquals(20, viewc.entities.length);
		assertEquals(10, viewabc.entities.length);
	}
	
	public function test2() {
		var viewa = new echo.View<{a:C1}>();
		ch.addView(viewa);
		
		for (i in 'ABCDE'.split('')) {
			var id = ch.id();
			ch.setComponent(id, new C1('$i'));
		}
		
		for (va in viewa) {
			ACTUAL += va.a;
		}
		
		assertEquals('ABCDE', ACTUAL);
	}
	
}

abstract C1(String) {
	public function new(s:String = '') this = s;
}

abstract C2(String) {
	public function new(s:String = '') this = s;
}

abstract C3(String) {
	public function new(s:String = '') this = s;
}