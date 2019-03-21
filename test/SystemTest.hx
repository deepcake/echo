import echos.*;

using buddy.Should;

class SystemTest extends buddy.BuddySuite {
    public function new() {
        describe("Using Systems", {


            describe("Using System with update functions", {
                beforeAll(Workflow.dispose());

                var s = new FlowSystem1();

                describe("When add System and update", {
                    beforeAll(FlowSystem1.result = "");
                    beforeAll(Workflow.addSystem(s));
                    beforeAll(Workflow.update(0));
                    it("should be added to the flow", Workflow.systems.length.should.be(1));
                    it("should has correct result", FlowSystem1.result.should.be("[*]"));
                });

                describe("Then add Entity A1, B2 and update", {
                    beforeAll(FlowSystem1.result = "");
                    beforeAll(new Entity().add(new FlowComponentA("1"), new FlowComponentB("2")));
                    beforeAll(Workflow.update(0));
                    it("should has correct result", FlowSystem1.result.should.be("[1*2]"));
                });
                describe("Then add Entity A3, B4 and update", {
                    beforeAll(FlowSystem1.result = "");
                    beforeAll(new Entity().add(new FlowComponentA("3"), new FlowComponentB("4")));
                    beforeAll(Workflow.update(0));
                    it("should has correct result", FlowSystem1.result.should.be("[13*24]"));
                });

                describe("Then remove System and update", {
                    beforeAll(FlowSystem1.result = "");
                    beforeAll(Workflow.removeSystem(s));
                    beforeAll(Workflow.update(0));
                    it("should be removed from the flow", Workflow.systems.length.should.be(0));
                    it("should has correct result", FlowSystem1.result.should.be(""));
                });

            });


            describe("Using System with added/removed functions", {
                beforeAll(Workflow.dispose());

                var s = new FlowSystem2();
                var e:Entity;

                describe("When add System and update", {
                    beforeAll(FlowSystem2.result = "");
                    beforeAll(Workflow.addSystem(s));
                    beforeAll(Workflow.update(0));
                    it("should be added to the flow", Workflow.systems.length.should.be(1));
                    it("should has correct result", FlowSystem2.result.should.be(""));
                });

                describe("Then add Entity A1 and update", {
                    beforeAll(FlowSystem2.result = "");
                    beforeAll(e = new Entity().add(new FlowComponentA("1")));
                    beforeAll(Workflow.update(0));
                    it("should has correct result", FlowSystem2.result.should.be(">1"));
                });
                describe("Then remove Component A and update", {
                    beforeAll(FlowSystem2.result = "");
                    beforeAll(e.remove(FlowComponentA));
                    beforeAll(Workflow.update(0));
                    it("should has correct result", FlowSystem2.result.should.be("<1"));
                });

                describe("Then add Entity A2, B2 and update", {
                    beforeAll(FlowSystem2.result = "");
                    beforeAll(e = new Entity().add(new FlowComponentA("2"), new FlowComponentB("2")));
                    beforeAll(Workflow.update(0));
                    it("should has correct result", FlowSystem2.result.should.be(">>22>2*22*"));
                });
                describe("Then destroy Entity and update", {
                    beforeAll(FlowSystem2.result = "");
                    beforeAll(e.destroy());
                    beforeAll(Workflow.update(0));
                    it("should has correct result", FlowSystem2.result.should.be("<<22<2"));
                });

                describe("Then add Entity B3 and update", {
                    beforeAll(FlowSystem2.result = "");
                    beforeAll(e = new Entity().add(new FlowComponentB("3")));
                    beforeAll(Workflow.update(0));
                    it("should has correct result", FlowSystem2.result.should.be(""));
                });
                describe("Then add Component A3 and update", {
                    beforeAll(FlowSystem2.result = "");
                    beforeAll(e.add(new FlowComponentA("3")));
                    beforeAll(Workflow.update(0));
                    it("should has correct result", FlowSystem2.result.should.be(">>33>3*33*"));
                });

                describe("Then remove System and update", {
                    beforeAll(FlowSystem2.result = "");
                    beforeAll(Workflow.removeSystem(s));
                    beforeAll(Workflow.update(0));
                    it("should be removed from the flow", Workflow.systems.length.should.be(0));
                    it("should has correct result", FlowSystem2.result.should.be("<3<<33"));
                });

                describe("Then destroy Entity and update", {
                    beforeAll(FlowSystem2.result = "");
                    beforeAll(e.destroy());
                    beforeAll(Workflow.update(0));
                    it("should has correct result", FlowSystem2.result.should.be(""));
                });

            });


            describe("Using System after Entity was added", {
                beforeAll(Workflow.dispose());

                var s = new FlowSystem2();
                var e:Entity;

                describe("When add Entity A1, B1 and update", {
                    beforeAll(FlowSystem2.result = "");
                    beforeAll(e = new Entity().add(new FlowComponentA("1"), new FlowComponentB("1")));
                    beforeAll(Workflow.update(0));
                    it("should has correct result", FlowSystem2.result.should.be(""));
                });

                describe("Then add System", {
                    beforeAll(FlowSystem2.result = "");
                    beforeAll(Workflow.addSystem(s));
                    it("should be added to the flow", Workflow.systems.length.should.be(1));
                    it("should has correct result", FlowSystem2.result.should.be(">1>>11"));
                });

                describe("Then update System", {
                    beforeAll(FlowSystem2.result = "");
                    beforeAll(Workflow.update(0));
                    it("should has correct result", FlowSystem2.result.should.be("*11*"));
                });

                describe("Then remove System", {
                    beforeAll(FlowSystem2.result = "");
                    beforeAll(Workflow.removeSystem(s));
                    it("should be removed from the flow", Workflow.systems.length.should.be(0));
                    it("should has correct result", FlowSystem2.result.should.be("<1<<11"));
                });

                describe("Then update System", {
                    beforeAll(FlowSystem2.result = "");
                    beforeAll(Workflow.update(0));
                    it("should has correct result", FlowSystem2.result.should.be(""));
                });

                describe("Then destroy Entity and update", {
                    beforeAll(FlowSystem2.result = "");
                    beforeAll(e.destroy());
                    beforeAll(Workflow.update(0));
                    it("should has correct result", FlowSystem2.result.should.be(""));
                });

            });


            describe("Using System with manually initialized View", {
                beforeAll(Workflow.dispose());

                var s = new ManualViewSystem();
                var e:Entity;

                describe("When add System and update", {
                    beforeAll(ManualViewSystem.result = "");
                    beforeAll(Workflow.addSystem(s));
                    beforeAll(Workflow.update(0));
                    it("should be added to the flow", Workflow.systems.length.should.be(1));
                    it("should has correct result", ManualViewSystem.result.should.be(""));
                });

                describe("Then add Entity A1 and update", {
                    beforeAll(ManualViewSystem.result = "");
                    beforeAll(e = new Entity().add(new FlowComponentA("1")));
                    beforeAll(Workflow.update(0));
                    it("should has correct result", ManualViewSystem.result.should.be(">1*1*"));
                });

                describe("Then destroy Entity and update", {
                    beforeAll(ManualViewSystem.result = "");
                    beforeAll(e.destroy());
                    beforeAll(Workflow.update(0));
                    it("should has correct result", ManualViewSystem.result.should.be("<1"));
                });

            });


            describe("Using System with overrided update", {
                beforeAll(Workflow.dispose());

                var s = new OverrideSystem();
                var e:Entity;

                describe("When add System and update", {
                    beforeAll(OverrideSystem.result = "");
                    beforeAll(Workflow.addSystem(s));
                    beforeAll(Workflow.update(0));
                    it("should has correct result", OverrideSystem.result.should.be("au"));
                });

                describe("Then add Entity A1 and update", {
                    beforeAll(OverrideSystem.result = "");
                    beforeAll(e = new Entity().add(new FlowComponentA("1")));
                    beforeAll(Workflow.update(0));
                    it("should has correct result", OverrideSystem.result.should.be("0u"));
                });

                describe("Then remove System and update", {
                    beforeAll(OverrideSystem.result = "");
                    beforeAll(Workflow.removeSystem(s));
                    beforeAll(Workflow.update(0));
                    it("should has correct result", OverrideSystem.result.should.be("d"));
                });

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
        result += '>>${a.value}${b.value}';
    }

    @r function onRemoveA(a:FlowComponentA) {
        result += '<${a.value}';
    }

    @r function onRemoveAB(a:FlowComponentA, b:FlowComponentB) {
        result += '<<${a.value}${b.value}';
    }

    @u function upd(a:FlowComponentA, b:FlowComponentB) {
        result += '*${a.value}${b.value}*';
    }

}

class ManualViewSystem extends echos.System {

    public static var result = "";

    var view:View<FlowComponentA->Void>;

    override function onactivate() {
        view.onAdded.add(function(e, ca) result += '>${ca.value}');
        view.onRemoved.add(function(e, ca) result += '<${ca.value}');
    }

    @u inline function action() {
        view.iter(function(e, ca) result += '*${ca.value}*');
    }

}

class OverrideSystem extends echos.System {
    public static var result = "";
    override function update(dt:Float) {
        result += 'u';
    }
    override function onactivate() {
        result += 'a';
    }
    override function ondeactivate() {
        result += 'd';
    }

    @u function test(a:FlowComponentA, dt:Float) {
        result += '$dt';
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
