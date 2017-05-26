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
		ch.addSystem(new SmokeSystem());
		for (i in 'xy'.split('')) ch.setComponent(ch.id(), new Name(i));
	}

	public function test_workflow1() {
		ch.update(0);

		for (i in ch.entities) ch.remove(i);

		assertEquals('!x!yAxAyBxBy;x!y!', SmokeSystem.OUT);
	}

	public function test_stats() {
		assertEquals('Echo ( 1 ) { 1 } [ 2 ]', ch.stats());
		assertEquals('Echo ( 1 ) { 1 } [ 2 ]', '$ch');
	}


}

class SmokeSystem extends System {

	static public var OUT = '';
	public function new() OUT = '';

	@e function action1(name:Name) {
		OUT += 'A' + name.val;
	}

	@e function action2(name:Name) {
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
