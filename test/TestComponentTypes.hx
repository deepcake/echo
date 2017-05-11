package;

import echo.Echo;
import echo.View;
import haxe.unit.TestCase;
import echo.System;

/**
 * ...
 * @author https://github.com/wimcake
 */
class TestComponentTypes extends TestCase {
	
	
	var ch:Echo;
	var id:Int;
	
	
	public function new() super();
	
	override public function setup():Void {
		ch = new Echo();
		id = ch.id();
	}
	
	
	public function test_follow_typedef() {
		ch.setComponent(id, new SimpleComponent('C'));
		
		assertEquals('C', ch.getComponent(id, SimpleComponent).val);
		assertEquals('C', ch.getComponent(id, TypedefComponent).val);
		
		ch.setComponent(id, new TypedefComponent('T'));
		
		assertEquals('T', ch.getComponent(id, SimpleComponent).val);
		assertEquals('T', ch.getComponent(id, TypedefComponent).val);
	}
	
	public function test_notfollow_abstract() {
		ch.setComponent(id, new SimpleComponent('C'), new AbstractComponent('A'));
		
		assertEquals('C', ch.getComponent(id, SimpleComponent).val);
		assertEquals('A', ch.getComponent(id, AbstractComponent).val);
	}
	
	public function test_notfollow_enumabstract() {
		ch.setComponent(id, 1337, EnumAbstractComponent.EATwo);
		
		assertEquals(1337, ch.getComponent(id, Int));
		assertEquals(EnumAbstractComponent.EATwo, ch.getComponent(id, EnumAbstractComponent));
		assertEquals(2, ch.getComponent(id, EnumAbstractComponent));
	}
	
	
	public function test_abstract() {
		var view = new View<{ c:AbstractComponent }>();
		ch.addView(view);
		
		ch.setComponent(id, new AbstractComponent('A'));
		
		assertEquals(1, view.entities.length);
		assertEquals('A', ch.getComponent(id, AbstractComponent).val);
	}
	
	public function test_enum() {
		var view = new View<{ c:EnumComponent }>();
		ch.addView(view);
		
		ch.setComponent(id, EnumComponent.EOne);
		
		assertEquals(1, view.entities.length);
		assertEquals(EnumComponent.EOne, ch.getComponent(id, EnumComponent));
	}
	
	public function test_enumabstract() {
		var view = new View<{ c:EnumAbstractComponent }>();
		ch.addView(view);
		
		ch.setComponent(id, EnumAbstractComponent.EAOne);
		
		assertEquals(1, view.entities.length);
		assertEquals(EnumAbstractComponent.EAOne, ch.getComponent(id, EnumAbstractComponent));
	}
	
	public function test_primitive() {
		var view = new View<{ c:Int }>();
		ch.addView(view);
		
		ch.setComponent(id, 1337);
		
		assertEquals(1, view.entities.length);
		assertEquals(1337, ch.getComponent(id, Int));
	}
	
}

class SimpleComponent {
	public var val = '';
	public function new(v:String) { 
		val = v;
	}
}

typedef TypedefComponent = SimpleComponent;

@:forward(val) abstract AbstractComponent(SimpleComponent) {
	public function new(v:String) this = new SimpleComponent(v);
}

enum EnumComponent {
	EOne;
	ETwo;
	ESome(value:Int);
}

@:enum abstract EnumAbstractComponent(Int) from Int to Int {
	var EAOne = 1;
	var EATwo = 2;
}