package;

import echo.Echo;
import echo.View;
import haxe.unit.TestCase;
import echo.System;

/**
 * ...
 * @author octocake1
 */
class TestFollow extends TestCase {
	

	public function new() {
		super();
	}
	
	public function test1() {
		var ch = new Echo();
		var id = ch.id();
		ch.addSystem(new FollowSystem());
		
		ch.setComponent(id, new FollowComponent('C'));
		ch.update(0);
		assertEquals('CCTC', FollowSystem.BOARD);
		
		ch.setComponent(id, new FollowComponentTypedef('T')); // replace "C"
		ch.update(0);
		assertEquals('CTTT', FollowSystem.BOARD);
		
		ch.setComponent(id, new FollowComponentAbstract('A'));
		ch.update(0);
		assertEquals('CTTTAA', FollowSystem.BOARD);
	}
	
	public function test2() {
		var ch = new Echo();
		var id = ch.id();
		ch.addSystem(new FollowSystem());
		
		
		ch.setComponent(id, new FollowComponentTypedef('T'), new FollowComponentAbstract('A'));
		ch.update(0);
		assertEquals('CTTTAA', FollowSystem.BOARD);
		
		ch.removeComponent(id, FollowComponent);
		ch.update(0);
		assertEquals('AA', FollowSystem.BOARD);
		
		
		ch.setComponent(id, new FollowComponent('C'));
		ch.update(0);
		assertEquals('CCTCAA', FollowSystem.BOARD);
		
		ch.removeComponent(id, FollowComponentTypedef);
		ch.update(0);
		assertEquals('AA', FollowSystem.BOARD);
		
		
		ch.removeComponent(id, FollowComponentAbstract);
		ch.update(0);
		assertEquals('', FollowSystem.BOARD);
	}
	
	public function test3() {
		var ch = new Echo();
		var id = ch.id();
		ch.addSystem(new FollowSystem());
		
		ch.setComponent(id, new FollowComponentTypedef('T'), new FollowComponentAbstract('A'));
		ch.update(0);
		
		assertEquals('T', ch.getComponent(id, FollowComponent).val);
		assertEquals('T', ch.getComponent(id, FollowComponentTypedef).val);
		assertEquals('A', ch.getComponent(id, FollowComponentAbstract).val);
		
		
		ch.setComponent(id, new FollowComponent('C'), new FollowComponentAbstract('A'));
		ch.update(0);
		
		assertEquals('C', ch.getComponent(id, FollowComponent).val);
		assertEquals('C', ch.getComponent(id, FollowComponentTypedef).val);
		assertEquals('A', ch.getComponent(id, FollowComponentAbstract).val);
	}
	
	
}

class FollowComponent {
	public var val = '';
	public function new(v:String) { 
		val = v;
	}
}

typedef FollowComponentTypedef = FollowComponent;

@:forward(val)
abstract FollowComponentAbstract(FollowComponent) {
	public function new(v:String) {
		this = new FollowComponent(v);
	}
}

class FollowSystem extends System {
	static public var BOARD = '';
	var v1 = new View<{ c:FollowComponent }>();
	var v2 = new View<{ c:FollowComponentTypedef }>();
	var v3 = new View<{ c:FollowComponentAbstract }>();
	override public function update(dt:Float) {
		BOARD = '';
		for (v in v1) BOARD += 'C' + v.c.val;
		for (v in v2) BOARD += 'T' + v.c.val;
		for (v in v3) BOARD += 'A' + v.c.val;
	}
}