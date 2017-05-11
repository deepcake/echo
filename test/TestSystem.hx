package;

import echo.Echo;
import echo.System;
import haxe.unit.TestCase;

/**
 * ...
 * @author https://github.com/wimcake
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
		var ss = new SomeSystem();
		ch.addSystem(ss);

		assertEquals('A', SomeSystem.STATIC_ACTUAL);

		ch.update(0);
		assertEquals('AU', SomeSystem.STATIC_ACTUAL);

		ch.removeSystem(ss);
		assertEquals('AUD', SomeSystem.STATIC_ACTUAL);

		ch.update(0);
		assertEquals('AUD', SomeSystem.STATIC_ACTUAL);
	}

	public function test_meta_view_skip() {
		ch.addSystem(new SA());
		ch.addSystem(new SB());

		assertEquals(2, ch.views.length);
	}

	public function test_meta_onadd_onrem() {
		ch.addSystem(new MetaAddRemSystem());
		var id = ch.id();

		ch.setComponent(id, new CA(), new CB());

		assertEquals('A!B!', MetaAddRemSystem.STATIC_ACTUAL);

		ch.removeComponent(id, CA);
		ch.removeComponent(id, CB);

		assertEquals('A!B!!A!B', MetaAddRemSystem.STATIC_ACTUAL);
	}

	public function test_meta_onadd_onrem_order() {
		ch.addSystem(new MetaAddRemOrderSystem());
		ch.setComponent(ch.id(), new CA(), new CB());

		ch.removeComponent(ch.last(), CA);
		ch.removeComponent(ch.last(), CB);

		assertEquals('A0!A1!B0!B1!!A0!A1!B0!B1', MetaAddRemOrderSystem.STATIC_ACTUAL);
	}

	public function test_meta_oneach1() {
		ch.addSystem(new MetaEachSystem1());
		ch.setComponent(ch.id(), new CA('A'), new CB('B'));
		ch.setComponent(ch.id(), new CA('#'), new CB('%'));
		ch.update(0);

		assertEquals(1, ch.views.length);
		assertEquals('AB#%!', MetaEachSystem1.STATIC_ACTUAL);
	}

	public function test_meta_oneach2() {
		ch.addSystem(new MetaEachSystem2());
		ch.setComponent(ch.id(), new CA('A'), new CB('B'));
		ch.setComponent(ch.id(), new CA('#'), new CB('%'));
		ch.update(0);

		assertEquals(2, ch.views.length);
		assertEquals('AB!#%!', MetaEachSystem2.STATIC_ACTUAL);
	}

	public function test_meta_oneach3() {
		ch.addSystem(new MetaEachSystem3());
		ch.setComponent(ch.id(), new CA('A'), new CB('B'));
		ch.setComponent(ch.id(), new CA('#'), new CB('%'));
		ch.update(0);

		assertEquals(2, ch.views.length);
		assertEquals('A#B%!', MetaEachSystem3.STATIC_ACTUAL);
	}

}

class MetaAddRemSystem extends System {
	static public var STATIC_ACTUAL = '';
	public function new() STATIC_ACTUAL = '';

	@v var viewa = new echo.View<{a:CA}>();
	@v var viewb = new echo.View<{b:CB}>();

	@onadd("viewa") function onadda(id:Int) STATIC_ACTUAL += 'A!';
	@onrem("viewa") function onrema(id:Int) STATIC_ACTUAL += '!A';

	@onadd(1) function onaddb(id:Int) STATIC_ACTUAL += 'B!';
	@onrem(1) function onremb(id:Int) STATIC_ACTUAL += '!B';
}

class MetaAddRemOrderSystem extends System {
	static public var STATIC_ACTUAL = '';
	public function new() STATIC_ACTUAL = '';

	@v var viewa = new echo.View<{a:CA}>();
	@v var viewb = new echo.View<{b:CB}>();

	@onadd("viewb") function onaddb0(id:Int) STATIC_ACTUAL += 'B0!';
	@onrem("viewb") function onremb0(id:Int) STATIC_ACTUAL += '!B0';

	@onadd("viewb") function onaddb1(id:Int) STATIC_ACTUAL += 'B1!';
	@onrem("viewb") function onremb1(id:Int) STATIC_ACTUAL += '!B1';

	@a function onadda0(id:Int) STATIC_ACTUAL += 'A0!';
	@a function onadda1(id:Int) STATIC_ACTUAL += 'A1!';

	@r function onrema0(id:Int) STATIC_ACTUAL += '!A0';
	@r function onrema1(id:Int) STATIC_ACTUAL += '!A1';
}


class MetaEachSystem1 extends System {
	static public var STATIC_ACTUAL = '';
	public function new() STATIC_ACTUAL = '';

	@oneach function oneach(a:CA, b:CB) STATIC_ACTUAL += a.val + b.val;

	override public function update(dt:Float) STATIC_ACTUAL += '!';
}

class MetaEachSystem2 extends System {
	static public var STATIC_ACTUAL = '';
	public function new() STATIC_ACTUAL = '';

	@oneach function oneach(b:CB, a:CA) STATIC_ACTUAL += a.val + b.val + '!';

	var viewa = new echo.View<{a:CA}>();
}

class MetaEachSystem3 extends System {
	static public var STATIC_ACTUAL = '';
	public function new() STATIC_ACTUAL = '';

	@oneach function oneach1(a:CA) STATIC_ACTUAL += a.val;
	@oneach function oneach2(b:CB) STATIC_ACTUAL += b.val;

	override public function update(dt:Float) STATIC_ACTUAL += '!';
}


class SomeSystem extends System {
	static public var STATIC_ACTUAL = '';
	override public function onactivate() {
		STATIC_ACTUAL += 'A';
	}
	override public function ondeactivate() {
		STATIC_ACTUAL += 'D';
	}
	override public function update(dt:Float) {
		STATIC_ACTUAL += 'U';
	}
}

class SA extends System {
	var view1 = new echo.View<{a:CA}>();
	@skip var view2 = new echo.View<{b:CB}>();
	@skip var view3 = new echo.View<{c:CC}>();
}

class SB extends System {
	var view1 = new echo.View<{a:CA}>();
	@view var view2 = new echo.View<{b:CB}>();
	var view3 = new echo.View<{c:CC}>();
}

class SAB extends System {
	var viewab = new echo.View<{a:CA, b:CB}>();
	var viewa = new echo.View<{a:CA}>();
	var viewb = new echo.View<{b:CB}>();
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
