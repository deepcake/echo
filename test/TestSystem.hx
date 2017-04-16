package;

import echo.Echo;
import echo.System;
import haxe.unit.TestCase;

/**
 * ...
 * @author octocake1
 */
class TestSystem extends TestCase {	
	
	
	var ch:Echo;
	
	
	public function new() super();
	
	
	override public function setup() {
		ch = new Echo();
		SomeSystem.STATIC_ACTUAL = '';
	}
	
	public function test1() {
		ch.addSystem(new SA());
		ch.addSystem(new SB());
		ch.addSystem(new SAB());
		
		assertEquals(3, ch.systems.length); 
		assertEquals(5, ch.views.length); 
	}
	
	public function test2() {
		var ss = new SomeSystem('');
		ch.addSystem(ss);
		
		assertEquals('A', SomeSystem.STATIC_ACTUAL);
		
		ch.update(0);
		assertEquals('AU', SomeSystem.STATIC_ACTUAL);
		
		ch.removeSystem(ss);
		assertEquals('AUD', SomeSystem.STATIC_ACTUAL);
		
		ch.update(0);
		assertEquals('AUD', SomeSystem.STATIC_ACTUAL);
	}
	
	public function test3() {
		var s1 = new SomeSystem('1');
		var s2 = new SomeSystem('2');
		ch.addSystem(s1);
		ch.addSystem(s2);
		
		assertEquals('A1A2', SomeSystem.STATIC_ACTUAL);
		
		ch.update(0);
		
		assertEquals('A1A2U1U2', SomeSystem.STATIC_ACTUAL);
		
		ch.removeSystem(s2);
		
		assertEquals('A1A2U1U2D2', SomeSystem.STATIC_ACTUAL);
		
		ch.update(0);
		
		assertEquals('A1A2U1U2D2U1', SomeSystem.STATIC_ACTUAL);
	}
	
}

class SomeSystem extends System {
	static public var STATIC_ACTUAL = '';
	@skip public var val = '';
	public function new(v:String) {
		val = v;
	}
	override public function onactivate() {
		STATIC_ACTUAL += 'A' + val;
	}
	override public function ondeactivate() {
		STATIC_ACTUAL += 'D' + val;
	}
	override public function update(dt:Float) {
		STATIC_ACTUAL += 'U' + val;
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