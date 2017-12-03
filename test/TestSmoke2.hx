package;

import data.Greeting;
import data.Name;
import haxe.unit.TestCase;
import echo.*;

/**
 * ...
 * @author https://github.com/wimcake
 */
class TestSmoke2 extends TestCase {


	var ch:Echo;


	public function new() super();


	override public function setup() {
		ch = new Echo();
		for (i in 'xy'.split('')) ch.addComponent(ch.id(), new Name(i));
	}

	public function test_workflow1() {
		ch.addSystem(new SmokeSystem());
		ch.update(0);
		for (i in ch.entities) ch.remove(i);
		ch.update(0);

		assertEquals('!x!yAxAyBxBy;x!y!;', SmokeSystem.OUT);
	}

	public function test_workflow2() {
		ch.addSystem(new SmokeSystem2());
		ch.update(0);
		for (i in ch.entities) ch.remove(i);
		ch.update(0);

		assertEquals('++>AA<BBK--><K', SmokeSystem2.OUT);
	}

	public function test_workflow3() {
		ch.addSystem(new SmokeSystem3());
		ch.update(0);
		for (i in ch.entities) ch.remove(i);
		ch.update(0);

		assertEquals('+,+,+(x),+(y),A,A,', SmokeSystem3.OUT);
	}


	public function test_remove_component_from_iteration_cycle() {
		ch.addSystem(new RemoveComponentFromIterationCycleSystem());
		assertEquals(10, RemoveComponentFromIterationCycleSystem.viewab.entities.length);
		ch.update(1);

		assertEquals(0, RemoveComponentFromIterationCycleSystem.viewab.entities.length);
	}

	public function test_remove_component_from_meta_iteration_cycle() {
		ch.addSystem(new RemoveComponentFromMetaIterationCycleSystem());
		assertEquals(10, RemoveComponentFromMetaIterationCycleSystem.viewab.entities.length);
		ch.update(1);

		assertEquals(0, RemoveComponentFromMetaIterationCycleSystem.viewab.entities.length);
	}


	public function test_stats() {
		ch.addSystem(new SmokeSystem());
		
		assertEquals('Echo ( 1 ) { 1 } [ 2 ]', ch.toString());
		assertEquals('Echo ( 1 ) { 1 } [ 2 ]', '$ch');
	}


}

class SmokeSystem extends System {

	static public var OUT = '';
	public function new() OUT = '';

	@u function action1(name:Name) {
		OUT += 'A' + name.val;
	}

	@u function action2(name:Name) {
		OUT += 'B' + name.val;
	}

	override public function update(dt:Float) {
		OUT += ';';
	}

	@a function onadd(id:Int) {
		OUT += '!' + echo.getComponent(id, Name).val;
	}

	@r function onrem(id:Int) {
		OUT += echo.getComponent(id, Name).val + '!';
	}

}

class SmokeSystem2 extends System {

	static public var OUT = '';
	public function new() OUT = '';

	@u function beforeAction1() {
		OUT += '>';
	}

	@u function action1(name:Name) {
		OUT += 'A';
	}

	@u function afterAction1() {
		OUT += '<';
	}

	@u function action2(name:Name) {
		OUT += 'B';
	}

	@u function afterAction2() {
		OUT += 'K';
	}

	@a function onadd() {
		OUT += '+';
	}

	@r function onrem() {
		OUT += '-';
	}

}

class SmokeSystem3 extends System {

	static public var OUT = '';
	public function new() OUT = '';

	@a function onaddName1() {
		OUT += '+,';
	}

	@u function actionA(name:Name) {
		OUT += 'A,';
	}

	@u function actionB(greeting:Greeting) {
		OUT += 'B,';
	}

	@a(0) function onaddName2(n:Name, id:Int) {
		OUT += '+(${n.val}),';
	}

	@a(1) function onaddGreeting(id:Int, g:Greeting) {
		OUT += '+(${g.val}),';
	}

}

class RemoveComponentFromIterationCycleSystem extends System {

	static public var OUT = '';
	public function new() OUT = '';

	static public var viewab = new echo.View<{ n:Name, g:Greeting }>();

	override function onactivate() {
		var ids = [ for(i in 0...10) echo.id() ];
		for (id in ids) echo.addComponent(id, new Name('A'), new Greeting('B'));
	}

	override function update(dt:Float) {
		for (i in viewab) echo.removeComponent(i.id, Name);
	}

}

class RemoveComponentFromMetaIterationCycleSystem extends System {

	static public var OUT = '';
	public function new() OUT = '';

	static public var viewab = new echo.View<{ n:Name, g:Greeting }>();

	override function onactivate() {
		var ids = [ for(i in 0...10) echo.id() ];
		for (id in ids) echo.addComponent(id, new Name('A'), new Greeting('B'));
	}

	@u function remove(i:Int, n:Name, g:Greeting) {
		echo.removeComponent(i, Name);
	}

}
