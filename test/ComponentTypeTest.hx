import echos.*;

using buddy.Should;

class ComponentTypeTest extends buddy.BuddySuite {
    public function new() {
        describe("Using Components of Different Types", {
            var e:Entity;
            var s:ComponentTypeSystem;

            beforeEach({
                Workflow.reset();
                e = new Entity();
                s = new ComponentTypeSystem();
                Workflow.addSystem(s);
            });

            describe("When add an ObjectComponent", {
                var c = new ObjectComponent("A");
                beforeEach(e.add(c));
                it("should returns by ObjectComponent", e.get(ObjectComponent).should.be(c));
                it("should returns by TypedefObjectComponent", e.get(TypedefObjectComponent).should.be(c));
                it("should not returns by AbstractObjectComponent", e.get(AbstractObjectComponent).should.not.be(c));
                it("should be collected by View<ObjectComponent>", s.objects.entities.length.should.be(1));
            });

            describe("When add an AbstractObjectComponent", {
                var c = new AbstractObjectComponent("A");
                beforeEach(e.add(c));
                it("should not returns by ObjectComponent", e.get(ObjectComponent).should.not.be(c));
                it("should not returns by TypedefObjectComponent", e.get(TypedefObjectComponent).should.not.be(c));
                it("should returns by AbstractObjectComponent", e.get(AbstractObjectComponent).should.be(c));
                it("should be collected by View<AbstractObjectComponent>", s.abstractObjects.entities.length.should.be(1));
            });

            describe("When add an AbstractPrimitiveComponent", {
                var c = new AbstractPrimitive(1);
                beforeEach(e.add(c));
                it("should returns by AbstractPrimitive", e.get(AbstractPrimitive).should.be(c));
                it("should be collected by View<AbstractPrimitive>", s.abstractPrimitives.entities.length.should.be(1));
            });

            describe("When add an EnumComponent", {
                var c = EnumComponent.E1("A");
                beforeEach(e.add(c));
                it("should returns by EnumComponent", e.get(EnumComponent).should.equal(c));
                it("should return correct value", e.get(EnumComponent).should.equal(EnumComponent.E1("A")));
                it("should be collected by View<EnumComponent>", s.enums.entities.length.should.be(1));
            });

            describe("When add an EnumAbstractComponent", {
                var c = EnumAbstractComponent.EA1;
                beforeEach(e.add(c));
                it("should returns by EnumAbstractComponent", e.get(EnumAbstractComponent).should.be(c));
                it("should return correct value", e.get(EnumAbstractComponent).should.be(EnumAbstractComponent.EA1));
                it("should be collected by View<EnumAbstractComponent>", s.enumAbstracts.entities.length.should.be(1));
            });

            describe("When add an IObjectComponent", {
                var c = (new ObjectComponent("A"):IObjectComponent);
                beforeEach(e.add(c));
                it("should returns by IObjectComponent", e.get(IObjectComponent).should.be(c));
                it("should not returns by ObjectComponent", e.get(ObjectComponent).should.not.be(c));
                it("should be collected by View<IObjectComponent>", s.iobjects.entities.length.should.be(1));
            });

            describe("When add an ExtendObjectComponent", {
                var c = new ExtendObjectComponent("A");
                beforeEach(e.add(c));
                it("should returns by ExtendObjectComponent", e.get(ExtendObjectComponent).should.be(c));
                it("should not returns by ObjectComponent", e.get(ObjectComponent).should.not.be(c));
                it("should be collected by View<ExtendObjectComponent>", s.extendObjects.entities.length.should.be(1));
            });

            describe("When add a TypeParamComponent", {
                var c = new TypeParamComponent<ObjectComponent>(new ObjectComponent("A"));
                beforeEach(e.add(c));
                it("should returns by TypeParamComponent", e.get(TypedefTypeParamComponent).should.be(c));
                it("should not returns by another TypeParamComponent", e.get(TypedefAnotherTypeParamComponent).should.not.be(c));
                it("should be collected by View<TypeParamComponent>", s.typeParams.entities.length.should.be(1));
            });

        });
    }
}


class ObjectComponent implements IObjectComponent {
    var value:String;
    public function new(v:String) this.value = v;
    public function getValue() return value;
}

typedef TypedefObjectComponent = ObjectComponent;

@:forward(getValue) 
abstract AbstractObjectComponent(ObjectComponent) {
    public function new(v:String) this = new ObjectComponent(v);
}

abstract AbstractPrimitive(Null<Int>) from Null<Int> to Null<Int> {
    public function new(i:Int) this = i;
}

enum EnumComponent {
    E1(value:String);
    E2(value:Int);
}

@:enum 
abstract EnumAbstractComponent(Null<Int>) from Null<Int> to Null<Int> {
    var EA1 = 1;
    var EA2 = 2;
}

interface IObjectComponent {
    function getValue():String;
}

class ExtendObjectComponent extends ObjectComponent {
    public function new(v:String) {
        super(v);
    }
}

class TypeParamComponent<T> {
    var value:T;
    public function new(v:T) {
        this.value = v;
    }
}

typedef TypedefTypeParamComponent = TypeParamComponent<ObjectComponent>;
typedef TypedefAnotherTypeParamComponent = TypeParamComponent<ExtendObjectComponent>;


class ComponentTypeSystem extends System {
    public var objects:View<ObjectComponent>;
    public var abstractObjects:View<AbstractObjectComponent>;
    public var abstractPrimitives:View<AbstractPrimitive>;
    public var enums:View<EnumComponent>;
    public var enumAbstracts:View<EnumAbstractComponent>;
    public var iobjects:View<IObjectComponent>;
    public var extendObjects:View<ExtendObjectComponent>;
    public var typeParams:View<TypeParamComponent<ObjectComponent>>;
}
