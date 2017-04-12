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
	
	
	public function new() super();
	
	
	override public function setup() {
		ch = new Echo();
	}
	
	public function test1() {
		var ids = [];
		
		for (v in 'ABCDE'.split('')) {
			var e = ch.id();
			ch.setComponent(e, new Name(v));
			ids.push(e);
		}
		this.assertEquals(ch.entities.length, 5);
		
		
		ch.removeComponent(ids[1], Name);
		this.assertEquals(ch.entities.length, 5);
		this.assertEquals(null, ch.getComponent(ids[1], Name));
		
		
		ch.remove(ids[1]);
		this.assertEquals(ch.entities.length, 4);
		this.assertEquals(null, ch.getComponent(ids[1], Name));
		
		
		ch.remove(ids[3]);
		this.assertEquals(ch.entities.length, 3);
		this.assertEquals(null, ch.getComponent(ids[3], Name));
		
		
		ch.removeComponent(ids[3], Name);
		this.assertEquals(ch.entities.length, 3);
		this.assertEquals(null, ch.getComponent(ids[3], Name));
		
		
		var c1 = ch.getComponent(ids[0], Name);
		var c2 = ch.getComponent(ids[2], Name);
		var c3 = ch.getComponent(ids[4], Name);
		assertEquals('ACE', c1.val + c2.val + c3.val);
		assertEquals('ACE', ch.getComponent(ids[0], Name).val + ch.getComponent(ids[2], Name).val + ch.getComponent(ids[4], Name).val);
		
		
		var r1 = ids.map(function(i) if (ch.getComponent(i, Name) != null) return ch.getComponent(i, Name).val; else return '').join('');
		assertEquals('ACE', r1);
		
		
		ch.setComponent(ids[0], new Name('X'));
		ch.getComponent(ids[2], Name).val = 'X';
		ch.setComponent(ids[4], new Name('X'));
		var r2 = ids.map(function(i) if (ch.getComponent(i, Name) != null) return ch.getComponent(i, Name).val; else return '').join('');
		assertEquals('XXX', r2);
	}
	
}