package;

import echo.*;
import haxe.Timer;
import haxe.unit.TestCase;

/**
 * ...
 * @author octocake1
 */
class TestPerfomance extends TestCase {
	
	
	static public var BOARD = '';
	

	public function new() super();
	
	
	public function test1() {
		var ch = new Echo();
		ch.addSystem(new Sys());
		
		var ids = [ for (i in 0...10000) ch.id() ];
		
		
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
		
		
		assertTrue(true);
	}
	
}

class Sys extends System {
	
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
		TestPerfomance.BOARD = '';
		for (v in v1) TestPerfomance.BOARD += 'a';
		for (v in v2) TestPerfomance.BOARD += 'b';
		for (v in v3) TestPerfomance.BOARD += 'c';
		for (v in v4) TestPerfomance.BOARD += 'd';
		for (v in v5) TestPerfomance.BOARD += 'e';
		for (v in v6) TestPerfomance.BOARD += 'f';
		for (v in v7) TestPerfomance.BOARD += 'j';
		for (v in v8) TestPerfomance.BOARD += 'h';
		for (v in v9) TestPerfomance.BOARD += 'i';
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