import echo.Entity;
import echo.*;

using buddy.Should;

class SystemTest extends buddy.BuddySuite {
    public function new() {
        describe("Using Systems", {


            describe("Using System with update functions", {
                beforeAll(Echo.dispose());

                var s = new FlowSystem1();

                describe("When add System and update", {
                    beforeAll(Echo.addSystem(s));
                    beforeAll(Echo.update(0));
                    it("should be added to the flow", Echo.systems.length.should.be(1));
                    it("should updates correctly", FlowSystem1.result.should.be(""));
                });

                describe("Then add Entity AB and update", {
                    beforeAll(new Entity().add(new FlowComponentA("A"), new FlowComponentB("B")));
                    beforeAll(Echo.update(0));
                    it("should updates correctly", FlowSystem1.result.should.be("[A*B]"));
                });
                describe("Then add Entity CD and update", {
                    beforeAll(new Entity().add(new FlowComponentA("C"), new FlowComponentB("D")));
                    beforeAll(Echo.update(0));
                    it("should updates correctly", FlowSystem1.result.should.be("[AC*BD]"));
                });

                describe("Then remove System and update", {
                    beforeAll(Echo.removeSystem(s));
                    beforeAll(Echo.update(0));
                    it("should be removed from the flow", Echo.systems.length.should.be(0));
                    it("should updates correctly", FlowSystem1.result.should.be(""));
                });

                afterEach(FlowSystem1.result = "");
            });


            describe("Using System with added/removed functions", {
                beforeAll(Echo.dispose());

                var s = new FlowSystem2();
                var a:Entity;
                var ab:Entity;

                describe("When add System and update", {
                    beforeAll(Echo.addSystem(s));
                    beforeAll(Echo.update(0));
                    it("should be added to the flow", Echo.systems.length.should.be(1));
                    it("should updates correctly", FlowSystem2.result.should.be(""));
                });

                describe("Then add Entity A and update", {
                    beforeAll(a = new Entity().add(new FlowComponentA("A")));
                    beforeAll(Echo.update(0));
                    it("should updates correctly", FlowSystem2.result.should.be(">A"));
                });
                describe("Then remove Entity A and update", {
                    beforeAll(a.remove(FlowComponentA));
                    beforeAll(Echo.update(0));
                    it("should updates correctly", FlowSystem2.result.should.be("<A"));
                });

                describe("Then add Entity AB and update", {
                    beforeAll(ab = new Entity().add(new FlowComponentA("C"), new FlowComponentB("D")));
                    beforeAll(Echo.update(0));
                    it("should updates correctly", FlowSystem2.result.should.be(">CD>C*CD*"));
                });
                describe("Then remove Entity AB and update", {
                    beforeAll(ab.remove(FlowComponentA).remove(FlowComponentB));
                    beforeAll(Echo.update(0));
                    it("should updates correctly", FlowSystem2.result.should.be("<CD<C"));
                });

                afterEach(FlowSystem2.result = "");
            });


        });
    }
}

class FlowSystem1 extends System {

    public static var result = "";

    @u public static inline function beforeAll() {
        result += "[";
    }

    @u public static inline function actionA(a:FlowComponentA) {
        result += a.value;
    }

    @u public static inline function middleAction() {
        result += "*";
    }

    @u public static inline function actionB(b:FlowComponentB) {
        result += b.value;
    }

    @u public static inline function afterAll() {
        result += "]";
    }

}

class FlowSystem2 extends System {

    public static var result = "";

    @a function onAddA(a:FlowComponentA) {
        result += '>${a.value}';
    }

    @a function onAddAB(a:FlowComponentA, b:FlowComponentB) {
        result += '>${a.value}${b.value}';
    }

    @r function onRemoveA(a:FlowComponentA) {
        result += '<${a.value}';
    }

    @r function onRemoveAB(a:FlowComponentA, b:FlowComponentB) {
        result += '<${a.value}${b.value}';
    }

    @u function upd(a:FlowComponentA, b:FlowComponentB) {
        result += '*${a.value}${b.value}*';
    }

}

class FlowComponentA {
    public var value:String;
    public function new(s:String) this.value = s;
}

class FlowComponentB {
    public var value:String;
    public function new(s:String) this.value = s;
}
