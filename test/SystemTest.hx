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

                describe("Then add Entity AB 12 and update", {
                    beforeAll(new Entity().add(new FlowComponentA("1"), new FlowComponentB("2")));
                    beforeAll(Echo.update(0));
                    it("should updates correctly", FlowSystem1.result.should.be("[1*2]"));
                });
                describe("Then add Entity AB 34 and update", {
                    beforeAll(new Entity().add(new FlowComponentA("3"), new FlowComponentB("4")));
                    beforeAll(Echo.update(0));
                    it("should updates correctly", FlowSystem1.result.should.be("[13*24]"));
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

                describe("Then add Entity A 1 and update", {
                    beforeAll(a = new Entity().add(new FlowComponentA("1")));
                    beforeAll(Echo.update(0));
                    it("should updates correctly", FlowSystem2.result.should.be(">1"));
                });
                describe("Then remove Component A 1 and update", {
                    beforeAll(a.remove(FlowComponentA));
                    beforeAll(Echo.update(0));
                    it("should updates correctly", FlowSystem2.result.should.be("<1"));
                });

                describe("Then add Entity AB 34 and update", {
                    beforeAll(ab = new Entity().add(new FlowComponentA("3"), new FlowComponentB("4")));
                    beforeAll(Echo.update(0));
                    it("should updates correctly", FlowSystem2.result.should.be(">34>3*34*"));
                });
                describe("Then remove Component AB 34 and update", {
                    beforeAll(ab.remove(FlowComponentA).remove(FlowComponentB));
                    beforeAll(Echo.update(0));
                    it("should updates correctly", FlowSystem2.result.should.be("<34<3"));
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
