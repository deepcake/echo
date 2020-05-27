import echoes.*;

using buddy.Should;

class ComponentTypeTest extends buddy.BuddySuite {
    public function new() {
        describe("Test Components of Different Types", {
            var e:Entity;
            var s:ComponentTypeSystem;

            beforeEach({
                Workflow.reset();
            });

            describe("When create System with Views of Components of Different Types", {
                beforeEach({
                    e = new Entity();
                    s = new ComponentTypeSystem();
                    Workflow.addSystem(s);
                });

                it("views should be empty", {
                    s.objects.entities.length.should.be(0);
                    s.abstractObjects.entities.length.should.be(0);
                    s.abstractPrimitives.entities.length.should.be(0);
                    s.enums.entities.length.should.be(0);
                    s.enumAbstracts.entities.length.should.be(0);
                    s.iobjects.entities.length.should.be(0);
                    s.extendObjects.entities.length.should.be(0);
                    s.typeParams.entities.length.should.be(0);
                    s.nestedTypeParams.entities.length.should.be(0);
                });

                describe("Then get Workflow info", {
                    var str = "\\# \\( 1 \\) \\{ 9 \\} \\[ 1 \\| 0 \\]";
                    #if echoes_profiling
                    str += " : \\d ms";
                    str += "\n    ComponentTypeTest.ComponentTypeSystem : \\d ms";
                    str += "\n    \\{ObjectComponent\\} \\[0\\]";
                    str += "\n    \\{AbstractObjectComponent\\} \\[0\\]";
                    str += "\n    \\{AbstractPrimitive\\} \\[0\\]";
                    str += "\n    \\{EnumComponent\\} \\[0\\]";
                    str += "\n    \\{EnumAbstractComponent\\} \\[0\\]";
                    str += "\n    \\{IObjectComponent\\} \\[0\\]";
                    str += "\n    \\{ExtendObjectComponent\\} \\[0\\]";
                    str += "\n    \\{TypeParamComponent\\<ObjectComponent\\>\\} \\[0\\]";
                    str += "\n    \\{TypeParamComponent\\<Array\\<ObjectComponent\\>\\>\\} \\[0\\]";
                    #end
                    beforeEach({
                        Workflow.update(0);
                    });
                    it("should have correct result", Workflow.info().should.match(new EReg(str, "")));
                });

                describe("Then add an ObjectComponent", {
                    var c1 = new ObjectComponent("A");
                    beforeEach(e.add(c1));
                    it("should be returned by ObjectComponent", e.get(ObjectComponent).should.be(c1));
                    it("should be returned by TypedefObjectComponent", e.get(TypedefObjectComponent).should.be(c1));
                    it("should not be returned by AbstractObjectComponent", e.get(AbstractObjectComponent).should.not.be(c1));
                    it("should be collected by View<ObjectComponent>", s.objects.entities.length.should.be(1));
                });

                describe("Then add an AbstractObjectComponent", {
                    var c2 = new AbstractObjectComponent("A");
                    beforeEach(e.add(c2));
                    it("should not be returned by ObjectComponent", e.get(ObjectComponent).should.not.be(c2));
                    it("should not be returned by TypedefObjectComponent", e.get(TypedefObjectComponent).should.not.be(c2));
                    it("should be returned by AbstractObjectComponent", e.get(AbstractObjectComponent).should.be(c2));
                    it("should be collected by View<AbstractObjectComponent>", s.abstractObjects.entities.length.should.be(1));
                });

                describe("Then add an AbstractPrimitiveComponent", {
                    var c3 = new AbstractPrimitive(1);
                    beforeEach(e.add(c3));
                    it("should be returned by AbstractPrimitive", e.get(AbstractPrimitive).should.be(c3));
                    it("should be collected by View<AbstractPrimitive>", s.abstractPrimitives.entities.length.should.be(1));
                });

                describe("Then add an EnumComponent", {
                    var c4 = EnumComponent.E1("A");
                    beforeEach(e.add(c4));
                    it("should be returned by EnumComponent", e.get(EnumComponent).should.equal(c4));
                    it("should return correct value", e.get(EnumComponent).should.equal(EnumComponent.E1("A")));
                    it("should be collected by View<EnumComponent>", s.enums.entities.length.should.be(1));
                });

                describe("Then add an EnumAbstractComponent", {
                    var c5 = EnumAbstractComponent.EA1;
                    beforeEach(e.add(c5));
                    it("should be returned by EnumAbstractComponent", e.get(EnumAbstractComponent).should.be(c5));
                    it("should return correct value", e.get(EnumAbstractComponent).should.be(EnumAbstractComponent.EA1));
                    it("should be collected by View<EnumAbstractComponent>", s.enumAbstracts.entities.length.should.be(1));
                });

                describe("Then add an IObjectComponent", {
                    var c6 = (new ObjectComponent("A"):IObjectComponent);
                    beforeEach(e.add(c6));
                    it("should be returned by IObjectComponent", e.get(IObjectComponent).should.be(c6));
                    it("should not be returned by ObjectComponent", e.get(ObjectComponent).should.not.be(c6));
                    it("should be collected by View<IObjectComponent>", s.iobjects.entities.length.should.be(1));
                });

                describe("Then add an ExtendObjectComponent", {
                    var c7 = new ExtendObjectComponent("A");
                    beforeEach(e.add(c7));
                    it("should be returned by ExtendObjectComponent", e.get(ExtendObjectComponent).should.be(c7));
                    it("should not be returned by ObjectComponent", e.get(ObjectComponent).should.not.be(c7));
                    it("should be collected by View<ExtendObjectComponent>", s.extendObjects.entities.length.should.be(1));
                });

                describe("Then add a TypeParamComponent", {
                    var c8 = new TypeParamComponent<ObjectComponent>(new ObjectComponent("A"));
                    beforeEach(e.add(c8));
                    it("should be returned by TypeParamComponent", e.get(TypedefTypeParamComponent).should.be(c8));
                    it("should not be returned by another TypeParamComponent", e.get(TypedefAnotherTypeParamComponent).should.not.be(c8));
                    it("should be collected by View<TypeParamComponent>", s.typeParams.entities.length.should.be(1));
                });

                describe("Then add a NestedTypeParamComponent", {
                    var c9 = new TypeParamComponent<Array<ObjectComponent>>([ new ObjectComponent("A") ]);
                    beforeEach(e.add(c9));
                    it("should be returned by NestedTypeParamComponent", e.get(TypedefNestedTypeParamComponent).should.be(c9));
                    it("should not be returned by TypeParamComponent", e.get(TypedefTypeParamComponent).should.not.be(c9));
                    it("should not be returned by another TypeParamComponent", e.get(TypedefAnotherTypeParamComponent).should.not.be(c9));
                    it("should be collected by View<NestedTypeParamComponent>", s.nestedTypeParams.entities.length.should.be(1));
                });
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

typedef TypedefNestedTypeParamComponent = TypeParamComponent<Array<ObjectComponent>>;


class ComponentTypeSystem extends System {
    public var objects:View<ObjectComponent>;
    public var abstractObjects:View<AbstractObjectComponent>;
    public var abstractPrimitives:View<AbstractPrimitive>;
    public var enums:View<EnumComponent>;
    public var enumAbstracts:View<EnumAbstractComponent>;
    public var iobjects:View<IObjectComponent>;
    public var extendObjects:View<ExtendObjectComponent>;
    public var typeParams:View<TypeParamComponent<ObjectComponent>>;
    public var nestedTypeParams:View<TypeParamComponent<Array<ObjectComponent>>>;
}
