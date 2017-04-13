package;

import haxe.unit.TestCase;
import echo.*;

/**
 * ...
 * @author octocake1
 */
class TestSmoke extends TestCase {

	static public var BOARD:String = '';

	public function new() super();
	
	
	override public function setup():Void {
		BOARD = '';
	}
	
	
	public function test1() { // views
		var ch = new Echo();
		ch.addSystem(new SA());
		ch.addSystem(new SB());
		
		var i1 = ch.id();
		var i2 = ch.id();
		var i3 = ch.id();
		
		ch.setComponent(i1, new CA());
		ch.setComponent(i2, new CA(), new CB());
		ch.setComponent(i3, new CB());
		ch.update(0);
		
		assertEquals('AABB', BOARD);
		
		
		ch.setComponent(i1, new CB('b'));
		ch.removeComponent(i2, CA);
		ch.removeComponent(i2, CB);
		ch.setComponent(i3, new CA('a'));
		ch.update(0);
		
		assertEquals('AABBAaBb', BOARD);
	}
	
	
	public function test2() { // systems
		var ch = new Echo();
		
		ch.setComponent(ch.id(), new CA());
		ch.setComponent(ch.id(), new CA(), new CB());
		ch.setComponent(ch.id(), new CB());
		
		var s1 = new SA();
		var s2 = new SB();
		ch.addSystem(s1);
		ch.addSystem(s2);
		ch.update(0);
		assertEquals('AABB', BOARD);
		
		
		ch.removeSystem(s1);
		ch.update(0);
		assertEquals('AABBBB', BOARD);
		
		
		ch.removeSystem(s2);
		ch.addSystem(s1);
		ch.update(0);
		assertEquals('AABBBBAA', BOARD);
	}
	
	
	public function test3() { // complex
		var ch = new Echo();
		var ar = [];
		ch.addSystem(new SAB(ar));
		
		ch.setComponent(ch.id(), new CA('John'), new CB('Hello'));
		ch.setComponent(ch.id(), new CA('Luca'), new CB('Bonjour'));
		ch.setComponent(ch.id(), new CA('Vlad'), new CB('Privet'));
		ch.setComponent(ch.id(), new CA('Hodor'));
		ch.setComponent(ch.id(), new CB('Hodor'));
		
		ch.update(0);
		
		trace('\n' + ar.join('\n'));
		assertEquals(9, ar.length);
		assertEquals('John say Hello to Luca', ar[0]);
		assertEquals('Vlad say Privet to Hodor', ar[8]);
	}
	
	
	public function test4() { // TODO no doublies ?
		var ch = new Echo();
		ch.addSystem(new SA());
		ch.addSystem(new SB());
		ch.addSystem(new SAB([]));
		
		trace('views count: ${ch.views.length} ( TODO: 3!)');
		assertTrue(true);
		//assertEquals(3, ch.views.length); 
	}
	
	
	public function test5() { // view out of system
		var ch = new Echo();
		var view = new echo.GenericView<{a:CA}>();
		ch.addView(view);
		
		ch.setComponent(ch.id(), new CA());
		ch.setComponent(ch.id(), new CA());
		ch.setComponent(ch.id(), new CA());
		
		for (e in view) {
			BOARD += e.a.val;
		}
		
		assertEquals('AAA', BOARD);
	}
	
	
	public function test6() {
		var ch = new Echo();
		var abview = new GenericView<{ a:CA, b:CB }>();
		var aview =  new GenericView<{ a:CA }>();
		
		ch.addView(abview);
		ch.addView(aview);
		
		for (i in 0...20) {
			var id = ch.id();
			ch.setComponent(id, new CA('$i'));
			if (i % 2 == 0) ch.setComponent(id, new CB('$i'));
		}
		
		var s = [ for (i in 0...20) if (i % 2 == 0) '$i' ].join('_');
		
		var abstring = [ for (ab in abview) ab.a.val ].join('_');
		
		assertEquals(s, abstring);
	}
	
	
}

class SA extends System {
	var view = new echo.GenericView<{a:CA}>();
	override public function update(dt:Float) {
		for (c in view) {
			TestSmoke.BOARD += c.a.val;
		}
	}
}

class SB extends System {
	var view = new echo.GenericView<{b:CB}>();
	override public function update(dt:Float) {
		for (c in view) {
			TestSmoke.BOARD += c.b.val;
		}
	}
}

class SAB extends System {
	var viewab = new echo.GenericView<{a:CA, b:CB}>();
	var viewa = new echo.GenericView<{a:CA}>();
	var viewb = new echo.GenericView<{b:CB}>();
	@skip var ar:Array<String>;
	public function new(ar:Array<String>) {
		this.ar = ar;
	}
	override public function update(dt:Float) {
		for (vab in viewab) {
			for (va in viewa) {
				if (vab.a != va.a) ar.push('${vab.a.val} say ${vab.b.val} to ${va.a.val}');
			}
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