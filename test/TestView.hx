package;

import echo.Echo;
import echo.View;
import haxe.unit.TestCase;

/**
 * ...
 * @author https://github.com/wimcake
 */
class TestView extends TestCase {


	static public var ACTUAL = '';

	var ch:Echo;


	public function new() super();


	override public function setup() {
		ch = new Echo();
		ACTUAL = '';
	}


	public function test_mapping() {
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


	public function test_sorting() {
		var viewa = new echo.View<{a:C1}>();
		ch.addView(viewa);

		for (i in 'QWERTYUIOP'.split('')) ch.setComponent(ch.id(), new C1('$i'));

		viewa.entities.sort(function(id1, id2) return ch.getComponent(id1, C1).charCodeAt(0) - ch.getComponent(id2, C1).charCodeAt(0));

		for (va in viewa) ACTUAL += va.a;

		assertEquals('EIOPQRTUWY', ACTUAL);
	}

	public function test_sort_and_remove_component() {
		var viewa = new echo.View<{a:C1}>();
		ch.addView(viewa);
		var ids = [ for (i in 0...10) ch.id() ];
		var letters = 'QWERTYUIOP'.split('');

		for (i in 0...ids.length) ch.setComponent(ids[i], new C1(letters[i]));

		viewa.entities.sort(function(id1, id2) return ch.getComponent(id1, C1).charCodeAt(0) - ch.getComponent(id2, C1).charCodeAt(0));

		ch.removeComponent(ids[0], C1);
		ch.removeComponent(ids[2], C1);

		for (va in viewa) ACTUAL += va.a;

		assertEquals('IOPRTUWY', ACTUAL);
	}

	public function test_sort_and_poll_entity() {
		var viewa = new echo.View<{a:C1}>();
		ch.addView(viewa);
		var ids = [ for (i in 0...10) ch.id() ];
		var letters = 'QWERTYUIOP'.split('');

		for (i in 0...ids.length) ch.setComponent(ids[i], new C1(letters[i]));

		viewa.entities.sort(function(id1, id2) return ch.getComponent(id1, C1).charCodeAt(0) - ch.getComponent(id2, C1).charCodeAt(0));

		ch.poll(ids[0]);
		ch.poll(ids[2]);

		for (va in viewa) ACTUAL += va.a;

		assertEquals('IOPRTUWY', ACTUAL);
	}

	public function test_sort_and_remove_entity() {
		var viewa = new echo.View<{a:C1}>();
		ch.addView(viewa);
		var ids = [ for (i in 0...10) ch.id() ];
		var letters = 'QWERTYUIOP'.split('');

		for (i in 0...ids.length) ch.setComponent(ids[i], new C1(letters[i]));

		viewa.entities.sort(function(id1, id2) return ch.getComponent(id1, C1).charCodeAt(0) - ch.getComponent(id2, C1).charCodeAt(0));

		ch.remove(ids[0]);
		ch.remove(ids[2]);

		for (va in viewa) ACTUAL += va.a;

		assertEquals('IOPRTUWY', ACTUAL);
	}


	public function test_remove_component() {
		var viewa = new echo.View<{a:C1}>();
		ch.addView(viewa);
		var ids = [ for(i in 0...10) ch.id() ];
		for (id in ids) ch.setComponent(id, new C1('A'));

		for (id in ids) ch.removeComponent(id, C1);

		assertEquals(0, viewa.entities.length);
	}

	public function test_poll_entity() {
		var viewa = new echo.View<{a:C1}>();
		ch.addView(viewa);
		var ids = [ for(i in 0...10) ch.id() ];
		for (id in ids) ch.setComponent(id, new C1('A'));

		for (id in ids) ch.poll(id);

		assertEquals(0, viewa.entities.length);

		for (id in ids) ch.add(id);

		assertEquals(10, viewa.entities.length);
	}

	public function test_remove_entity() {
		var viewa = new echo.View<{a:C1}>();
		ch.addView(viewa);
		var ids = [ for(i in 0...10) ch.id() ];
		for (id in ids) ch.setComponent(id, new C1('A'));

		for (id in ids) ch.remove(id);

		assertEquals(0, viewa.entities.length);

		for (id in ids) ch.add(id);

		assertEquals(0, viewa.entities.length);
	}

	public function test_remove_view() {
		var viewa = new echo.View<{a:C1}>();
		ch.addView(viewa);
		var ids = [ for(i in 0...10) ch.id() ];
		for (id in ids) ch.setComponent(id, new C1('A'));

		ch.removeView(viewa);

		assertEquals(10, ch.entities.length);
		assertEquals(0, viewa.entities.length);

		ch.addView(viewa);

		assertEquals(10, ch.entities.length);
		assertEquals(10, viewa.entities.length);
	}


	public function test_delayed_add() {
		var ab = new echo.View<{a:C1, b:C2}>();
		ch.addView(ab);

		var cache = [ for (i in 0...10) ch.next() ];
		for (id in cache) ch.setComponent(id, new C1('A'), new C2('A'));

		assertEquals(0, ch.entities.length);
		assertEquals(0, ab.entities.length);

		for (id in cache) ch.add(id);

		assertEquals(10, ch.entities.length);
		assertEquals(10, ab.entities.length);
	}


	public function test_onadd() {
		var view = new echo.View<{a:C1}>();
		ch.addView(view);

		view.onAdded.add(function(i) ACTUAL += ch.getComponent(i, C1));

		for (i in 'QWERTY'.split('')) ch.setComponent(ch.id(), new C1('$i'));

		assertEquals('QWERTY', ACTUAL);
	}

	public function test_onremove_remove_component() {
		var view = new echo.View<{a:C1}>();
		ch.addView(view);

		view.onRemoved.add(function(i) ACTUAL += ch.getComponent(i, C1));

		var ids = [];
		for (i in 'QWERTY'.split('')) {
			var id = ch.id();
			ids.push(id);
			ch.setComponent(id, new C1('$i'));
		}

		assertEquals('', ACTUAL);

		for (id in ids) ch.removeComponent(id, C1);

		assertEquals('QWERTY', ACTUAL);
	}

	public function test_onremove_poll_entity() {
		var view = new echo.View<{a:C1}>();
		ch.addView(view);

		view.onRemoved.add(function(i) ACTUAL += ch.getComponent(i, C1));

		var ids = [];
		for (i in 'QWERTY'.split('')) {
			var id = ch.id();
			ids.push(id);
			ch.setComponent(id, new C1('$i'));
		}

		assertEquals('', ACTUAL);

		for (id in ids) ch.poll(id);

		assertEquals('QWERTY', ACTUAL);
	}

	public function test_onremove_remove_entity() {
		var view = new echo.View<{a:C1}>();
		ch.addView(view);

		view.onRemoved.add(function(i) ACTUAL += ch.getComponent(i, C1));

		var ids = [];
		for (i in 'QWERTY'.split('')) {
			var id = ch.id();
			ids.push(id);
			ch.setComponent(id, new C1('$i'));
		}

		assertEquals('', ACTUAL);

		for (id in ids) ch.remove(id);

		assertEquals('QWERTY', ACTUAL);
	}

	public function test_view_define() {
		var v1 = ch.defineView({ a:C1 });
		var v2:View<{ a:C1 }> = cast ch.defineView({ a:C1 });

		assertEquals(1, ch.views.length);
		assertEquals(v1, v2);
	}

	public function test_view_get() {
		var v0 = ch.defineView({ a:C1 });

		var v1 = ch.getView(C1);
		var v2:View<{ a:C1 }> = cast ch.getView(C1);

		assertEquals(v0, v1);
		assertEquals(v0, v2);
	}

	public function test_view_get_null() {
		var v1 = ch.getView(C1);
		var v2:View<{ a:C1 }> = cast ch.getView(C1);

		assertEquals(null, v1);
		assertEquals(null, v2);
	}


	public function test_prevent_view_duplicates() {
		ch.defineView({ a:C1, b:C2 });
		ch.defineView({ a:C1, b:C2 });
		ch.defineView({ b:C2, a:C1 });

		for (i in 0...10) ch.setComponent(ch.id(), new C1('$i'), new C2('$i'));

		assertEquals(1, ch.views.length);
		assertEquals(10, ch.entities.length);
		assertEquals(10, ch.getView(C1, C2).entities.length);
		assertEquals(10, ch.getView(C2, C1).entities.length);
	}

}

@:forward(charCodeAt)
abstract C1(String) {
	public function new(s:String = '') this = s;
}

abstract C2(String) {
	public function new(s:String = '') this = s;
}

abstract C3(String) {
	public function new(s:String = '') this = s;
}
