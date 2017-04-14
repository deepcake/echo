package;

import echo.*;
import haxe.Timer;
import haxe.unit.TestCase;

/**
 * ...
 * @author octocake1
 */
class TestPerfomance extends TestCase {
	
	
	static public inline var COUNT = 10000;
	static public var ACTUAL = 0;
	
	
	public function new() super();
	
	
	public function test1() {
		var ch = new Echo();
		ch.addSystem(new Sys1());
		
		var ids = [ for (i in 0...COUNT) ch.id() ];
		
		
		trace('');
		
		var time = Date.now().getTime();
		for (i in ids) ch.setComponent(i, new A());
		trace('A :: ${Date.now().getTime() - time} ms');
		
		var time = Date.now().getTime();
		for (i in ids) ch.setComponent(i, new B());
		trace('B :: ${Date.now().getTime() - time} ms');
		
		var time = Date.now().getTime();
		for (i in ids) ch.setComponent(i, new C());
		trace('C :: ${Date.now().getTime() - time} ms');
		
		var time = Date.now().getTime();
		for (i in ids) ch.setComponent(i, new D());
		trace('D :: ${Date.now().getTime() - time} ms');
		
		var time = Date.now().getTime();
		for (i in ids) ch.setComponent(i, new E());
		trace('E :: ${Date.now().getTime() - time} ms');
		
		var time = Date.now().getTime();
		for (i in ids) ch.setComponent(i, new F());
		trace('F :: ${Date.now().getTime() - time} ms');
		
		var time = Date.now().getTime();
		for (i in ids) ch.setComponent(i, new G());
		trace('G :: ${Date.now().getTime() - time} ms');
		
		var time = Date.now().getTime();
		for (i in ids) ch.setComponent(i, new H());
		trace('H :: ${Date.now().getTime() - time} ms');
		
		var time = Date.now().getTime();
		for (i in ids) ch.setComponent(i, new I());
		trace('I :: ${Date.now().getTime() - time} ms');
		
		
		var time = Date.now().getTime();
		ch.update(0);
		trace('update :: ${Date.now().getTime() - time} ms');
		
		
		assertEquals(COUNT * 9, TestPerfomance.ACTUAL);
	}
	
}

class Sys1 extends System {
	
	var v1 = new echo.GenericView<{a:A}>();
	var v2 = new echo.GenericView<{a:A, b:B}>();
	var v3 = new echo.GenericView<{a:A, b:B, c:C}>();
	var v4 = new echo.GenericView<{a:A, b:B, c:C, d:D}>();
	var v5 = new echo.GenericView<{a:A, b:B, c:C, d:D, e:E}>();
	var v6 = new echo.GenericView<{a:A, b:B, c:C, d:D, e:E, f:F}>();
	var v7 = new echo.GenericView<{a:A, b:B, c:C, d:D, e:E, f:F, g:G}>();
	var v8 = new echo.GenericView<{a:A, b:B, c:C, d:D, e:E, f:F, g:G, h:H}>();
	var v9 = new echo.GenericView<{a:A, b:B, c:C, d:D, e:E, f:F, g:G, h:H, i:I}>();
	
	override public function update(dt:Float) {
		TestPerfomance.ACTUAL = 0;
		for (v in v1) TestPerfomance.ACTUAL += 1;
		for (v in v2) TestPerfomance.ACTUAL += 1;
		for (v in v3) TestPerfomance.ACTUAL += 1;
		for (v in v4) TestPerfomance.ACTUAL += 1;
		for (v in v5) TestPerfomance.ACTUAL += 1;
		for (v in v6) TestPerfomance.ACTUAL += 1;
		for (v in v7) TestPerfomance.ACTUAL += 1;
		for (v in v8) TestPerfomance.ACTUAL += 1;
		for (v in v9) TestPerfomance.ACTUAL += 1;
	}
}

class A {
	public function new() {}
}
class B {
	public function new() {}
}
class C {
	public function new() {}
}
class D {
	public function new() {}
}
class E {
	public function new() {}
}
class F {
	public function new() {}
}
class G {
	public function new() {}
}
class H {
	public function new() {}
}
class I {
	public function new() {}
}