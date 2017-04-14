package;

import data.Greeting;
import data.Name;
import data.RoomSystem;
import haxe.unit.TestCase;
import echo.*;

/**
 * ...
 * @author octocake1
 */
class TestSmoke extends TestCase {
	
	
	var ch:Echo;
	
	
	public function new() super();
	
	
	override public function setup() {
		ch = new Echo();
	}
	
	public function test1() {
		ch.addSystem(new RoomSystem());
		
		var i1 = ch.id();
		var i2 = ch.id();
		var i3 = ch.id();
		
		ch.setComponent(i1, new Name('John'), new Greeting('Hello'));
		ch.setComponent(i2, new Name('Luca'), new Greeting('Bonjour'));
		ch.setComponent(i3, new Name('Vlad'), new Greeting('Privet'));
		ch.setComponent(ch.id(), new Name('Hodor'));
		ch.setComponent(ch.id(), new Greeting('Hodor'));
		
		assertEquals(4, RoomSystem.LOG.length);
		
		ch.update(0);
		
		assertEquals('John say Hello to Luca', RoomSystem.LOG[4]);
		assertEquals('Vlad say Privet to Hodor', RoomSystem.LOG[12]);
		
		ch.removeComponent(i2, Name);
		
		assertEquals('Luca leave the room', RoomSystem.LOG[13]);
		
		ch.update(0);
		
		assertEquals('John say Hello to Vlad', RoomSystem.LOG[14]);
		assertEquals('Vlad say Privet to Hodor', RoomSystem.LOG[17]);
		
		trace('\n' + RoomSystem.LOG.join('\n'));
	}
	
}

