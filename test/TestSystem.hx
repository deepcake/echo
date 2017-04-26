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
	
	
	public function test_build() {
		ch.addSystem(new SA());
		ch.addSystem(new SB());
		ch.addSystem(new SAB());
		
		assertEquals(3, ch.systems.length); 
		assertEquals(5, ch.views.length); 
	}
	
	public function test_lifecycle() {
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

	public function test_meta() {
		ch.addSystem(new MetaSystem());
		assertEquals(1, ch.systems.length); 
	}
	
}

class MetaSystem extends System {
	@v var viewa = new echo.View<{a:CA}>();
	//@v var viewb = new echo.View<{b:CB}>();
	@onadd("viewa") function onadda(id:Int) trace('A!');
	@onrem("viewa") function onrema(id:Int) trace('!A');
	//@onadd(1) function onaddb(id:Int) trace('B!');
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
	var view = new echo.View<{a:CA}>();
	override public function update(dt:Float) {
		for (c in view) {
			TestView.ACTUAL += c.a.val;
		}
	}
}

class SB extends System {
	var view = new echo.View<{b:CB}>();
	override public function update(dt:Float) {
		for (c in view) {
			TestView.ACTUAL += c.b.val;
		}
	}
}

class SAB extends System {
	var viewab = new echo.View<{a:CA, b:CB}>();
	var viewa = new echo.View<{a:CA}>();
	var viewb = new echo.View<{b:CB}>();
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