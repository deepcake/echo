import echos.Entity.Status;
import echos.*;

using buddy.Should;
using Lambda;

class SystemTest extends buddy.BuddySuite {
    public function new() {
        describe("Using Systems", {


            describe("Using @update functions", {
                beforeAll(Workflow.dispose());

                var s = new FlowSystem1();

                describe("When add System", {
                    beforeAll({
                        FlowSystem1.result = "";
                        Workflow.addSystem(s);
                    });
                    it("should be added to the flow", Workflow.systems.length.should.be(1));
                    it("should has correct result", FlowSystem1.result.should.be(""));
                });
                describe("Then update", {
                    beforeAll({
                        FlowSystem1.result = "";
                        Workflow.update(0);
                    });
                    it("should has correct result", FlowSystem1.result.should.be("[*]"));
                });

                describe("Then add Entity A1+B2", {
                    beforeAll({
                        FlowSystem1.result = "";
                        new Entity().add(new FlowComponentA("1"), new FlowComponentB("2"));
                    });
                    it("should has correct result", FlowSystem1.result.should.be(""));
                });
                describe("Then update", {
                    beforeAll({
                        FlowSystem1.result = "";
                        Workflow.update(0);
                    });
                    it("should has correct result", FlowSystem1.result.should.be("[1*2]"));
                });

                describe("Then add Entity A3+B4", {
                    beforeAll({
                        FlowSystem1.result = "";
                        new Entity().add(new FlowComponentA("3")).add(new FlowComponentB("4"));
                    });
                    it("should has correct result", FlowSystem1.result.should.be(""));
                });
                describe("Then update", {
                    beforeAll({
                        FlowSystem1.result = "";
                        Workflow.update(0);
                    });
                    it("should has correct result", FlowSystem1.result.should.be("[13*24]"));
                });

                describe("Then remove System", {
                    beforeAll({
                        FlowSystem1.result = "";
                        Workflow.removeSystem(s);
                    });
                    it("should be removed from the flow", Workflow.systems.length.should.be(0));
                    it("should has correct result", FlowSystem1.result.should.be(""));
                });
                describe("Then update", {
                    beforeAll({
                        FlowSystem1.result = "";
                        Workflow.update(0);
                    });
                    it("should has correct result", FlowSystem1.result.should.be(""));
                });

            });


            describe("Using @added/@removed functions", {
                beforeAll(Workflow.dispose());

                var s = new FlowSystem2();
                var e:Entity;

                describe("When add System", {
                    beforeAll({
                        FlowSystem2.result = "";
                        Workflow.addSystem(s);
                    });
                    it("should be added to the flow", Workflow.systems.length.should.be(1));
                    it("should has correct result", FlowSystem2.result.should.be(""));
                });
                describe("Then update", {
                    beforeAll({
                        FlowSystem2.result = "";
                        Workflow.update(0);
                    });
                    it("should has correct result", FlowSystem2.result.should.be(""));
                });

                describe("Then add Entity A1", {
                    beforeAll({
                        FlowSystem2.result = "";
                        e = new Entity().add(new FlowComponentA("1"));
                    });
                    it("should has correct result", FlowSystem2.result.should.be(">1"));
                });
                describe("Then update", {
                    beforeAll({
                        FlowSystem2.result = "";
                        Workflow.update(0);
                    });
                    it("should has correct result", FlowSystem2.result.should.be(""));
                });

                describe("Then remove A1", {
                    beforeAll({
                        FlowSystem2.result = "";
                        e.remove(FlowComponentA);
                    });
                    it("should has correct result", FlowSystem2.result.should.be("<1"));
                });
                describe("Then update", {
                    beforeAll({
                        FlowSystem2.result = "";
                        Workflow.update(0);
                    });
                    it("should has correct result", FlowSystem2.result.should.be(""));
                });


                describe("Then add Entity A2+B2", {
                    beforeAll({
                        FlowSystem2.result = "";
                        e = new Entity().add(new FlowComponentA("2"), new FlowComponentB("2"));
                    });
                    it("should has correct result", FlowSystem2.result.should.be(">2>>22"));
                });
                describe("Then update", {
                    beforeAll({
                        FlowSystem2.result = "";
                        Workflow.update(0);
                    });
                    it("should has correct result", FlowSystem2.result.should.be("*22*"));
                });

                describe("Then destroy Entity A2+B2", {
                    beforeAll({
                        FlowSystem2.result = "";
                        e.destroy();
                    });
                    it("should has correct result", FlowSystem2.result.should.be("<2<<22"));
                });
                describe("Then update", {
                    beforeAll({
                        FlowSystem2.result = "";
                        Workflow.update(0);
                    });
                    it("should has correct result", FlowSystem2.result.should.be(""));
                });


                describe("Then add Entity B3", {
                    beforeAll({
                        FlowSystem2.result = "";
                        e = new Entity().add(new FlowComponentB("3"));
                    });
                    it("should has correct result", FlowSystem2.result.should.be(""));
                });
                describe("Then update", {
                    beforeAll({
                        FlowSystem2.result = "";
                        Workflow.update(0);
                    });
                    it("should has correct result", FlowSystem2.result.should.be(""));
                });

                describe("Then add A3", {
                    beforeAll({
                        FlowSystem2.result = "";
                        e.add(new FlowComponentA("3"));
                    });
                    it("should has correct result", FlowSystem2.result.should.be(">3>>33"));
                });
                describe("Then update", {
                    beforeAll({
                        FlowSystem2.result = "";
                        Workflow.update(0);
                    });
                    it("should has correct result", FlowSystem2.result.should.be("*33*"));
                });


                describe("Then deactivate Entity", {
                    beforeAll({
                        FlowSystem2.result = "";
                        e.deactivate();
                    });
                    it("should has correct result", FlowSystem2.result.should.be("<3<<33"));
                });
                describe("Then update", {
                    beforeAll({
                        FlowSystem2.result = "";
                        Workflow.update(0);
                    });
                    it("should has correct result", FlowSystem2.result.should.be(""));
                });

                describe("Then activate Entity", {
                    beforeAll({
                        FlowSystem2.result = "";
                        e.activate();
                    });
                    it("should has correct result", FlowSystem2.result.should.be(">3>>33"));
                });
                describe("Then update", {
                    beforeAll({
                        FlowSystem2.result = "";
                        Workflow.update(0);
                    });
                    it("should has correct result", FlowSystem2.result.should.be("*33*"));
                });


                describe("Then remove System", {
                    beforeAll({
                        FlowSystem2.result = "";
                        Workflow.removeSystem(s);
                    });
                    it("should has correct result", FlowSystem2.result.should.be("<3<<33"));
                });
                describe("Then update", {
                    beforeAll({
                        FlowSystem2.result = "";
                        Workflow.update(0);
                    });
                    it("should has correct result", FlowSystem2.result.should.be(""));
                });


                describe("Then destroy Entity", {
                    beforeAll({
                        FlowSystem2.result = "";
                        e.destroy();
                    });
                    it("should has correct result", FlowSystem2.result.should.be(""));
                });
                describe("Then update", {
                    beforeAll({
                        FlowSystem2.result = "";
                        Workflow.update(0);
                    });
                    it("should has correct result", FlowSystem2.result.should.be(""));
                });

            });


            describe("Add System after Entity", {
                var s = new FlowSystem2();
                var e:Entity;

                beforeAll({
                    Workflow.dispose();
                    e = new Entity().add(new FlowComponentA("1"), new FlowComponentB("1"));
                });

                describe("When add System", {
                    beforeAll({
                        FlowSystem2.result = "";
                        Workflow.addSystem(s);
                    });
                    it("should has correct result", FlowSystem2.result.should.be(">1>>11"));
                });

                describe("Then update", {
                    beforeAll({
                        FlowSystem2.result = "";
                        Workflow.update(0);
                    });
                    it("should has correct result", FlowSystem2.result.should.be("*11*"));
                });

                describe("Then remove System", {
                    beforeAll({
                        FlowSystem2.result = "";
                        Workflow.removeSystem(s);
                    });
                    it("should has correct result", FlowSystem2.result.should.be("<1<<11"));
                });
            });


            describe("System with manually defined View", {
                var s = new ManualViewSystem();
                var e:Entity;

                beforeAll({
                    Workflow.dispose();
                    Workflow.addSystem(s);
                });

                describe("When add Entity", {
                    beforeAll({
                        ManualViewSystem.result = "";
                        e = new Entity().add(new FlowComponentA("1"));
                    });
                    it("should has correct result", ManualViewSystem.result.should.be(">1"));
                });

                describe("Then update", {
                    beforeAll({
                        ManualViewSystem.result = "";
                        Workflow.update(0);
                    });
                    it("should has correct result", ManualViewSystem.result.should.be("*1*"));
                });

                describe("Then destroy Entity", {
                    beforeAll({
                        ManualViewSystem.result = "";
                        e.destroy();
                    });
                    it("should has correct result", ManualViewSystem.result.should.be("<1"));
                });
            });


            describe("System on Activate/Deactivate", {
                var s = new OverrideSystem();
                var e:Entity;

                beforeAll({
                    Workflow.dispose();
                });

                describe("When add System", {
                    beforeAll({
                        OverrideSystem.result = "";
                        Workflow.addSystem(s);
                    });
                    it("should has correct result", OverrideSystem.result.should.be("a"));
                });

                describe("Then update", {
                    beforeAll({
                        OverrideSystem.result = "";
                        Workflow.update(0);
                    });
                    it("should has correct result", OverrideSystem.result.should.be(""));
                });

                describe("When remove System", {
                    beforeAll({
                        OverrideSystem.result = "";
                        Workflow.removeSystem(s);
                    });
                    it("should has correct result", OverrideSystem.result.should.be("d"));
                });
            });


            describe("Initialize/Dispose", {
                var s1 = new FlowSystem1();
                var s2 = new FlowSystem2();
                var e:Entity;

                beforeAll({
                    Workflow.dispose();
                });

                describe("When initialize", {
                    beforeAll({
                        e = new Entity().add(new FlowComponentA('x'));
                        Workflow.addSystem(s1);
                        Workflow.addSystem(s2);
                        var entities = [ for (i in 0...100) new Entity() ];
                        for (i in 0...entities.length) {
                            var e = entities[i];
                            if (i % 1 == 0) e.add(new FlowComponentA('$i'));
                            if (i % 2 == 0) e.add(new FlowComponentB('$i')); // 50
                            if (i % 5 == 0) e.deactivate(); // 20
                            if (i % 25 == 0) e.destroy(); // 4
                        }
                    });
                    it("should have correct count of systems", Workflow.systems.length.should.be(2));
                    it("should have correct count of views", Workflow.views.length.should.be(3));
                    it("should have correct count of entities", Workflow.entities.length.should.be(81));
                    it("should have correct count of cached ids", @:privateAccess Workflow.cache.length.should.be(4));
                    it("should have correct size of id map", @:privateAccess Workflow.statuses.count().should.be(101));
                    it("lost entity should have correct status", e.status().should.be(Active));
                    describe("View<A>", {
                        it("should have correct matched entities count", Workflow.getView(FlowComponentA).entities.length.should.be(81));
                        it("should have correct size of map", @:privateAccess Workflow.getView(FlowComponentA).statuses.count().should.be(81));
                        it("should have correct add signals count", Workflow.getView(FlowComponentA).onAdded.length.should.be(1));
                        it("should have correct remove signals count", Workflow.getView(FlowComponentA).onRemoved.length.should.be(1));
                    });
                });

                describe("Then dispose", {
                    beforeAll({
                        Workflow.dispose();
                    });
                    it("should have correct count of systems", Workflow.systems.length.should.be(0));
                    it("should have correct count of views", Workflow.systems.length.should.be(0));
                    it("should have correct count of entities", Workflow.systems.length.should.be(0));
                    it("should have correct count of cached ids", @:privateAccess Workflow.cache.length.should.be(0));
                    it("should have correct size of ids", @:privateAccess Workflow.statuses.count().should.be(0));
                    it("lost entity should have correct status", e.status().should.be(Invalid));
                    describe("View<A>", {
                        it("should have correct matched entities count", Workflow.getView(FlowComponentA).entities.length.should.be(0));
                        it("should have correct size of map", @:privateAccess Workflow.getView(FlowComponentA).statuses.count().should.be(0));
                        it("should have correct add signals count", Workflow.getView(FlowComponentA).onAdded.length.should.be(0));
                        it("should have correct remove signals count", Workflow.getView(FlowComponentA).onRemoved.length.should.be(0));
                    });
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

    override function onactivate() {
        result += 'a';
    }
    override function ondeactivate() {
        result += 'd';
    }

    // override function __activate() {

    // }

    // override function __deactivate() {
        
    // }

    // override function __update(dt:Float) {
        
    // }

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
