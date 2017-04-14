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
	
	public function test2() {
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