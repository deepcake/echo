package;

import echo.Echo;
import echo.System;
import haxe.unit.TestCase;

/**
 * ...
 * @author https://github.com/deepcake
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
		ch.addSystem(new SAB('AB'));
		ch.addSystem(new SystemAnonymous());

		assertEquals(4, ch.systems.length);
		assertEquals(3, ch.views.length);
	}

	public function test_build_c_order() {
		ch.addSystem(new SystemABC());
		ch.addSystem(new SystemCBA());
		ch.addSystem(new SystemAnonymousCBA());

		assertEquals(3, ch.systems.length);
		assertEquals(1, ch.views.length);
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

	public function test_meta_onadd_onrem_added_before_entity() {
		ch.addSystem(new MetaAddRemSystem());
		var id = ch.id();

		ch.addComponent(id, new CA(), new CB());

		assertEquals('A!B!', MetaAddRemSystem.STATIC_ACTUAL);

		ch.removeComponent(id, CA);
		ch.removeComponent(id, CB);

		assertEquals('A!B!!A!B', MetaAddRemSystem.STATIC_ACTUAL);
	}

	public function test_meta_onadd_onrem_added_after_entity() {
		var id = ch.id();
		ch.addComponent(id, new CA(), new CB());

		ch.addSystem(new MetaAddRemSystem());

		assertEquals('A!B!', MetaAddRemSystem.STATIC_ACTUAL);

		ch.remove(id);

		assertEquals('A!B!!A!B', MetaAddRemSystem.STATIC_ACTUAL);
	}

	public function test_meta_onadd_onrem_order() {
		ch.addSystem(new MetaAddRemOrderSystem());
		ch.addComponent(ch.id(), new CA(), new CB());

		ch.removeComponent(ch.last(), CA);
		ch.removeComponent(ch.last(), CB);

		assertEquals('A0!A1!B0!B1!!A0!A1!B0!B1', MetaAddRemOrderSystem.STATIC_ACTUAL);
	}

	public function test_meta_oneach1() {
		ch.addSystem(new MetaEachSystemUpdateExistsAlready());
		ch.addComponent(ch.id(), new CA('A'), new CB('B'));
		ch.addComponent(ch.id(), new CA('#'), new CB('%'));
		ch.update(0);

		assertEquals(1, ch.views.length);
		assertEquals('AB#%!', MetaEachSystemUpdateExistsAlready.STATIC_ACTUAL);
	}

	public function test_meta_oneach2() {
		ch.addSystem(new MetaEachSystemViewExistsAlready());
		ch.addComponent(ch.id(), new CA('A'), new CB('B'));
		ch.addComponent(ch.id(), new CA('#'), new CB('%'));
		ch.update(0);

		assertEquals(1, ch.views.length);
		assertEquals('AB!#%!', MetaEachSystemViewExistsAlready.STATIC_ACTUAL);
	}

	public function test_meta_oneach3() {
		ch.addSystem(new MetaEachSystemDifferentView());
		ch.addComponent(ch.id(), new CA('A'), new CB('B'));
		ch.addComponent(ch.id(), new CA('#'), new CB('%'));
		ch.update(0);

		assertEquals(2, ch.views.length);
		assertEquals('A#B%--!', MetaEachSystemDifferentView.STATIC_ACTUAL);
	}

	public function test_meta_oneach4() {
		ch.addSystem(new MetaEachSystem4());
		ch.addComponent(ch.id(), new CA('A'), new CB('B'));
		ch.addComponent(ch.id(), new CA('#'), new CB('%'));
		ch.update(0);

		assertEquals(1, ch.views.length);
		assertEquals('AB!#%!A!B!#!%!', MetaEachSystem4.STATIC_ACTUAL);
	}

	public function test_meta_oneach_delta() {
		ch.addSystem(new MetaEachSystemDelta());
		ch.addComponent(ch.id(), new CA('A'));
		ch.update(0.9);

		assertEquals(1, ch.views.length);
		assertEquals('A_0.9A_0.9_' + ch.last(), MetaEachSystemDelta.STATIC_ACTUAL);
	}

	public function test_meta_oneach_empty() {
		ch.addSystem(new MetaEachSystemEmpty());
		ch.addComponent(ch.id(), new CA('A'));
		ch.update(0);

		assertEquals(1, ch.views.length);
		assertEquals('1A3(0)A5', MetaEachSystemEmpty.STATIC_ACTUAL);
	}

	public function test_view_reuse1() {
		ASystem.STATIC_ACTUAL = '';
		ch.addSystem(new ASystem());
		ch.addSystem(new ASystemReuse());

		ch.addComponent(ch.id(), new CA('A'));
		ch.update(0);

		assertEquals(1, ch.views.length);
		assertEquals('AR', ASystem.STATIC_ACTUAL);
	}

	public function test_view_reuse2() {
		ASystem.STATIC_ACTUAL = '';
		ch.addView(new echo.View<{ a:CA }>());
		ch.getViewByTypes(CA).onAdded.add(function(id) ASystem.STATIC_ACTUAL += '!');
		ch.addSystem(new ASystemReuse());

		ch.addComponent(ch.id(), new CA(''));
		ch.update(0);

		assertEquals(1, ch.views.length);
		assertEquals('!R', ASystem.STATIC_ACTUAL);
	}

	public function test_meta_oneach_type_param() {
		ch.addSystem(new MetaEachSystemTypeParam());
		ch.addComponent(ch.id(), [ 'M' ]);
		ch.update(0);

		assertEquals(1, ch.views.length);
		assertEquals('M', MetaEachSystemTypeParam.STATIC_ACTUAL);
	}


	public function test_meta_skip() {
		ch.addSystem(new MetaSkipSystem());
		ch.addComponent(ch.id(), new CA('A'));
		ch.update(0);

		assertEquals(0, ch.views.length);
		assertEquals('?', MetaSkipSystem.STATIC_ACTUAL);
	}


	public function test_system_get() {
		var s0 = new SA();
		ch.addSystem(s0);

		assertEquals(s0, cast ch.getSystem(SA));
	}

	public function test_system_get_null() {
		assertEquals(null, ch.getSystem(SA));
	}

	public function test_system_has() {
		ch.addSystem(new SA());

		assertTrue(ch.hasSystem(SA));
		assertFalse(ch.hasSystem(SB));
	}

	public function test_system_remove() {
		ch.addSystem(new SA());

		ch.removeSystem(ch.getSystem(SA));

		assertEquals(0, ch.systems.length);
		assertEquals(null, ch.getSystem(SA));
	}

	public function test_system_remove_neg() {
		var s = new SA();

		ch.removeSystem(s);

		assertEquals(0, ch.systems.length);
		assertEquals(null, ch.getSystem(SA));
	}


	public function test_prevent_system_duplicates() {
		ch.addSystem(new SA());
		ch.addSystem(new SA());

		assertEquals(1, ch.systems.length);
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


class MetaSkipSystem extends System {
	static public var STATIC_ACTUAL = '';
	public function new() STATIC_ACTUAL = '';
	@skip @update function oneach1(a:CA) STATIC_ACTUAL += '!';
	@update @skip function oneach2(a:CA) STATIC_ACTUAL += '!';
	@update function onlyupdate() STATIC_ACTUAL += '?';
	@i @onadded @onadd @add @a @some_other_meta_tag function onadd(a:CA) STATIC_ACTUAL += '>';
}


class MetaEachSystemUpdateExistsAlready extends System {
	static public var STATIC_ACTUAL = '';
	public function new() STATIC_ACTUAL = '';

	@update function oneach(a:CA, b:CB) STATIC_ACTUAL += a.val + b.val;

	override public function update(dt:Float) STATIC_ACTUAL += '!';
}

class MetaEachSystemViewExistsAlready extends System {
	static public var STATIC_ACTUAL = '';
	public function new() STATIC_ACTUAL = '';

	@update function oneach(b:CB, a:CA) STATIC_ACTUAL += a.val + b.val + '!';

	var viewab = new echo.View<{a:CA, b:CB}>();
}

class MetaEachSystemDifferentView extends System {
	static public var STATIC_ACTUAL = '';
	public function new() STATIC_ACTUAL = '';

	@update function oneach1(a:CA) STATIC_ACTUAL += a.val;
	@update function oneach2(b:CB) STATIC_ACTUAL += b.val;
	@update function oneach3(b:CB) STATIC_ACTUAL += '-';

	override public function update(dt:Float) STATIC_ACTUAL += '!';
}

class MetaEachSystem4 extends System {
	static public var STATIC_ACTUAL = '';
	public function new() STATIC_ACTUAL = '';

	@update function oneach(b:CB, a:CA) STATIC_ACTUAL += a.val + b.val + '!';

	override public function update(dt:Float) {
		for (ab in viewab) STATIC_ACTUAL += ab.a.val + '!' + ab.b.val + '!';
	}

	var viewab:echo.View<{a:CA, b:CB}>;
}

class MetaEachSystemDelta extends System {
	static public var STATIC_ACTUAL = '';
	public function new() STATIC_ACTUAL = '';

	@update function oneach1(dt:Float, a:CA) STATIC_ACTUAL += a.val + '_$dt';
	@update function oneach2(a:CA, deltaTime:Float, entityId:Int) STATIC_ACTUAL += a.val + '_$deltaTime' + '_$entityId';
}

class MetaEachSystemEmpty extends System {
	static public var STATIC_ACTUAL = '';
	public function new() STATIC_ACTUAL = '';

	@u function act1() STATIC_ACTUAL += '1';
	@u function act2(a:CA) STATIC_ACTUAL += a.val;
	@u function act3(dt:Float) STATIC_ACTUAL += '3($dt)';
	@u inline function act4(a:CA) STATIC_ACTUAL += a.val;
	@u inline function act5() STATIC_ACTUAL += '5';
}

class MetaEachSystemTypeParam extends System {
	static public var STATIC_ACTUAL = '';
	public function new() STATIC_ACTUAL = '';

	@update function oneach(a:Array<String>) STATIC_ACTUAL += a[0];
}


class ASystem extends System {
	static public var STATIC_ACTUAL = '';
	var view:echo.View<{ a:CA }>;
	@a function addA(id:Int) {
		ASystem.STATIC_ACTUAL += 'A';
	}
}
class ASystemReuse extends System {
	var view:echo.View<{ a:CA }>;
	@a function addA(id:Int) {
		ASystem.STATIC_ACTUAL += 'R';
	}
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
	@i var view1 = new echo.View<{a:CA}>();
	var view2 = new echo.View<{b:CB}>();
	@i var view3 = new echo.View<{c:CC}>();
}

class SAB extends System {
	var v:String;
	public function new(v:String) {
		this.v = v;
	}
	var viewab = new echo.View<{a:CA, b:CB}>();
	var viewa = new echo.View<{a:CA}>();
	var viewb = new echo.View<{b:CB}>();
}

typedef AnonymousA = { var a:CA; };
typedef AnonymousAB = { > AnonymousA, var b:CB; };
class SystemAnonymous extends System {
	var view1:echo.View<AnonymousA>;
	var view2:echo.View<AnonymousAB>;
}

class SystemABC extends System {
	var viewabc:echo.View<{a:CA, b:CB, c:CC}>;
}

class SystemCBA extends System {
	var viewabc:echo.View<{c:CC, b:CB, a:CA}>;
}

typedef AnonymousCBA = {c:CC, b:CB, a:CA};
class SystemAnonymousCBA extends System {
	var viewabc:echo.View<AnonymousCBA>;
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
