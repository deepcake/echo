package;

import echo.Echo;
import echo.GenericView;
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
		ch.addSystem(new SA());
		ch.addSystem(new SB());
		ch.addSystem(new SAB());
		
		assertEquals(5, ch.views.length); 
	}
	
	public function test2() {
		var viewabc = new echo.GenericView<{a:CA, b:CB, c:CC}>();
		var viewa = new echo.GenericView<{a:CA}>();
		var viewb = new echo.GenericView<{b:CB}>();
		var viewc = new echo.GenericView<{c:CC}>();
		ch.addView(viewabc);
		ch.addView(viewa);
		ch.addView(viewb);
		ch.addView(viewc);
		
		for (i in 0...100) {
			var id = ch.id();
			ch.setComponent(id, new CA());
			if (i % 2 == 0) ch.setComponent(id, new CB());
			if (i % 5 == 0) ch.setComponent(id, new CC());
		}
		
		assertEquals(100, viewa.entities.length);
		assertEquals(50, viewb.entities.length);
		assertEquals(20, viewc.entities.length);
		assertEquals(10, viewabc.entities.length);
	}
	
}

class SA extends System {
	var view = new echo.GenericView<{a:CA}>();
	override public function update(dt:Float) {
		for (c in view) {
			TestView.ACTUAL += c.a.val;
		}
	}
}

class SB extends System {
	var view = new echo.GenericView<{b:CB}>();
	override public function update(dt:Float) {
		for (c in view) {
			TestView.ACTUAL += c.b.val;
		}
	}
}

class SAB extends System {
	var viewab = new echo.GenericView<{a:CA, b:CB}>();
	var viewa = new echo.GenericView<{a:CA}>();
	var viewb = new echo.GenericView<{b:CB}>();
	override public function update(dt:Float) {
		for (c in viewab) {
			TestView.ACTUAL += (c.a.val + c.b.val);
		}
	}
}

class CA {
	public var val:String;
	public function new(val:String = 'A') {
		this.val = val;
	}
}

class CB {
	public var val:String;
	public function new(val:String = 'B') {
		this.val = val;
	}
}

class CC {
	public var val:String;
	public function new(val:String = 'C') {
		this.val = val;
	}
}