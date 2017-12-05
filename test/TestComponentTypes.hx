package;

import echo.Echo;
import echo.View;
import haxe.unit.TestCase;

/**
 * ...
 * @author https://github.com/wimcake
 */
class TestComponentTypes extends TestCase {


	var ch:Echo;
	var id:Int;


	public function new() super();

	override public function setup() {
		ch = new Echo();
		id = ch.id();
	}


	public function test_follow_typedef() {
		ch.addComponent(id, new SimpleComponent('C'));

		assertEquals('C', ch.getComponent(id, SimpleComponent).val);
		assertEquals('C', ch.getComponent(id, TypedefSimpleComponent).val);

		ch.addComponent(id, new TypedefSimpleComponent('T'));

		assertEquals('T', ch.getComponent(id, SimpleComponent).val);
		assertEquals('T', ch.getComponent(id, TypedefSimpleComponent).val);
	}

	public function test_notfollow_abstract() {
		ch.addComponent(id, new SimpleComponent('C'), new AbstractSimpleComponent('A'));

		assertEquals('C', ch.getComponent(id, SimpleComponent).val);
		assertEquals('A', ch.getComponent(id, AbstractSimpleComponent).val);
	}

	public function test_notfollow_enumabstract() {
		ch.addComponent(id, 1337, EnumAbstractComponent.EATwo);

		assertEquals(1337, ch.getComponent(id, Int));
		assertEquals(EnumAbstractComponent.EATwo, ch.getComponent(id, EnumAbstractComponent));
		assertEquals(2, ch.getComponent(id, EnumAbstractComponent));
	}


	public function test_abstract() {
		var view = new View<{ c:AbstractSimpleComponent }>();
		ch.addView(view);

		ch.addComponent(id, new AbstractSimpleComponent('A'));

		assertEquals(1, view.entities.length);
		assertEquals('A', ch.getComponent(id, AbstractSimpleComponent).val);
	}

	public function test_enum() {
		var view = new View<{ c:EnumComponent }>();
		ch.addView(view);

		ch.addComponent(id, EnumComponent.EOne);

		assertEquals(1, view.entities.length);
		assertEquals(EnumComponent.EOne, ch.getComponent(id, EnumComponent));
	}

	public function test_enumabstract() {
		var view = new View<{ c:EnumAbstractComponent }>();
		ch.addView(view);

		ch.addComponent(id, EnumAbstractComponent.EAOne);

		assertEquals(1, view.entities.length);
		assertEquals(EnumAbstractComponent.EAOne, ch.getComponent(id, EnumAbstractComponent));
	}

	public function test_abstract_primitive() {
		var view = new View<{ c:AbstractPrimitive }>();
		ch.addView(view);

		ch.addComponent(id, new AbstractPrimitive(1337));

		assertEquals(1, view.entities.length);
		assertEquals(1337, ch.getComponent(id, AbstractPrimitive));
	}

	public function test_type_param() {
		var view = new View<{ c:Array<Int> }>();
		ch.addView(view);

		ch.addComponent(id, [1, 2, 3]);

		assertEquals(1, view.entities.length);
		assertEquals([1, 2, 3].toString(), ch.getComponent(id, TypeParamComponent).toString());
	}

	public function test_anon() {
		var view = new View<AnonymousViewParam>();
		ch.addView(view);

		ch.addComponent(id, new SimpleComponent('A'), EOne);

		assertEquals(1, view.entities.length);
		assertEquals('A', ch.getComponent(id, SimpleComponent).val);
	}

	public function test_anon_extended() {
		var view = new View<AnonymousViewParamExtended>();
		ch.addView(view);

		ch.addComponent(id, new SimpleComponent('A'), EOne);

		assertEquals(1, view.entities.length);
		assertEquals('A', ch.getComponent(id, SimpleComponent).val);
		assertEquals(EOne, ch.getComponent(id, EnumComponent));
	}

}

class SimpleComponent {
	public var val = '';
	public function new(v:String) {
		val = v;
	}
}

typedef TypedefSimpleComponent = SimpleComponent;

@:forward(val) 
abstract AbstractSimpleComponent(SimpleComponent) {
	public function new(v:String) this = new SimpleComponent(v);
}

abstract AbstractPrimitive(Int) from Int to Int {
	public function new(i:Int) this = i;
}

enum EnumComponent {
	EOne;
	ETwo;
	ESome(value:Int);
}

@:enum 
abstract EnumAbstractComponent(Int) from Int to Int {
	var EAOne = 1;
	var EATwo = 2;
}

typedef TypeParamComponent = Array<Int>; // only way ?

typedef AnonymousViewParam = { var a:SimpleComponent; }

typedef AnonymousViewParamExtended = { > AnonymousViewParam, var b:EnumComponent; }
