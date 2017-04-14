package;

import data.Name;
import echo.Echo;
import haxe.unit.TestCase;

using StringTools;
using Lambda;

/**
 * ...
 * @author octocake1
 */
class TestComponent extends TestCase {
	

	var ch:Echo;
	var ids:Array<Int>;
	
	
	public function new() super();
	
	
	override public function setup() {
		ch = new Echo();
		ids = [];
		
		for (v in '01234'.split('')) {
			var e = ch.id();
			ch.setComponent(e, v);
			ids.push(e);
		}
	}
	
	public function test1() {
		var c0 = ch.getComponent(ids[0], String);
		var c1 = ch.getComponent(ids[1], String);
		var c2 = ch.getComponent(ids[2], String);
		var c3 = ch.getComponent(ids[3], String);
		var c4 = ch.getComponent(ids[4], String);
		var act = c0 + c1 + c2 + c3 + c4;
		
		assertEquals('01234', act);
	}
	
	public function test2() {
		ch.setComponent(ids[0], 'A');
		ch.setComponent(ids[2], 'A');
		ch.setComponent(ids[4], 'A');
		
		var c0 = ch.getComponent(ids[0], String);
		var c1 = ch.getComponent(ids[1], String);
		var c2 = ch.getComponent(ids[2], String);
		var c3 = ch.getComponent(ids[3], String);
		var c4 = ch.getComponent(ids[4], String);
		var act = c0 + c1 + c2 + c3 + c4;
		
		assertEquals('A1A3A', act);
	}
	
	public function test3() {
		ch.removeComponent(ids[0], String);
		ch.removeComponent(ids[2], String);
		ch.removeComponent(ids[4], String);
		
		var c0 = ch.getComponent(ids[0], String);
		var c1 = ch.getComponent(ids[1], String);
		var c2 = ch.getComponent(ids[2], String);
		var c3 = ch.getComponent(ids[3], String);
		var c4 = ch.getComponent(ids[4], String);
		
		assertEquals(5, ch.entities.length);
		assertEquals(null, ch.getComponent(ids[0], String));
		assertEquals('1', ch.getComponent(ids[1], String));
		assertEquals(null, ch.getComponent(ids[2], String));
		assertEquals('3', ch.getComponent(ids[3], String));
		assertEquals(null, ch.getComponent(ids[4], String));
	}
	
	public function test4() {
		ch.remove(ids[0]);
		ch.remove(ids[2]);
		ch.remove(ids[4]);
		
		var c0 = ch.getComponent(ids[0], String);
		var c1 = ch.getComponent(ids[1], String);
		var c2 = ch.getComponent(ids[2], String);
		var c3 = ch.getComponent(ids[3], String);
		var c4 = ch.getComponent(ids[4], String);
		
		assertEquals(2, ch.entities.length);
		assertEquals(null, ch.getComponent(ids[0], String));
		assertEquals('1', ch.getComponent(ids[1], String));
		assertEquals(null, ch.getComponent(ids[2], String));
		assertEquals('3', ch.getComponent(ids[3], String));
		assertEquals(null, ch.getComponent(ids[4], String));
	}
	
	public function test5() {
		ch.removeComponent(ids[1], String);
		ch.removeComponent(ids[2], String);
		ch.removeComponent(ids[3], String);
		
		var act = ch.entities.map(function(i) if (ch.getComponent(i, String) != null) return ch.getComponent(i, String); else return 'A').join('');
		
		assertEquals('0AAA4', act);
	}
	
	public function test6() {
		assertEquals(null, ch.getComponent(ids[0], Name));
		assertEquals(null, ch.getComponent(ids[1], Name));
		assertEquals(null, ch.getComponent(ids[2], Name));
		assertEquals(null, ch.getComponent(ids[3], Name));
		assertEquals(null, ch.getComponent(ids[4], Name));
	}
	
	public function test7() {
		for (id in ids) ch.setComponent(id, new Name('$id'));
		
		assertEquals(5, ch.entities.length);
		
		assertEquals('${ids[0]}', ch.getComponent(ids[0], Name).val);
		assertEquals('${ids[1]}', ch.getComponent(ids[1], Name).val);
		assertEquals('${ids[2]}', ch.getComponent(ids[2], Name).val);
		assertEquals('${ids[3]}', ch.getComponent(ids[3], Name).val);
		assertEquals('${ids[4]}', ch.getComponent(ids[4], Name).val);
	}
	
	public function test8() {
		for (id in ids) ch.setComponent(id, new Name('A'), 'B');
		
		assertEquals(5, ch.entities.length);
		
		assertEquals('A', ch.getComponent(ids[0], Name).val);
		assertEquals('A', ch.getComponent(ids[1], Name).val);
		assertEquals('A', ch.getComponent(ids[2], Name).val);
		assertEquals('A', ch.getComponent(ids[3], Name).val);
		assertEquals('A', ch.getComponent(ids[4], Name).val);
		
		assertEquals('B', ch.getComponent(ids[0], String));
		assertEquals('B', ch.getComponent(ids[1], String));
		assertEquals('B', ch.getComponent(ids[2], String));
		assertEquals('B', ch.getComponent(ids[3], String));
		assertEquals('B', ch.getComponent(ids[4], String));
	}
	
	public function test9() {
		for (id in ids) ch.setComponent(id, new Name('A'));
		
		var c0 = ch.getComponent(ids[0], Name);
		var c1 = ch.getComponent(ids[1], Name);
		var c2 = ch.getComponent(ids[2], Name);
		var c3 = ch.getComponent(ids[3], Name);
		var c4 = ch.getComponent(ids[4], Name);
		
		c0.val = '+';
		c2.val = '+';
		c4.val = '+';
		
		var act = ch.entities.map(function(i) return ch.getComponent(i, Name).val).join('');
		
		assertEquals('+A+A+', act); 
	}
	
	public function test10() {
		ch.setComponent(ids[0], new Name('A'), 'A');
		ch.removeComponent(ids[0], String);
		ch.setComponent(ids[0], '!');
		
		assertEquals('!', ch.getComponent(ids[0], String));
		assertEquals('A', ch.getComponent(ids[0], Name).val);
	}
	
	public function test11() {
		ch.setComponent(ids[0], new Name('A'), 'A');
		ch.remove(ids[0]);
		ch.setComponent(ids[0], '!');
		
		assertEquals('!', ch.getComponent(ids[0], String));
		assertEquals(null, ch.getComponent(ids[0], Name));
	}
	
	public function test12() {
		var name = new Name('A');
		ch.setComponent(ids[0], name);
		ch.setComponent(ids[1], name);
		
		assertEquals(true, ch.getComponent(ids[0], Name) == ch.getComponent(ids[1], Name));
	}
	
	public function test13() {
		var ch = new Echo();
		ch.setComponent(ch.id()); // empty
		
		assertEquals(1, ch.entities.length);
	}
}