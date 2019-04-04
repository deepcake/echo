import echos.*;

using buddy.Should;
using Lambda;

class ViewTest extends buddy.BuddySuite {
    public function new() {
        describe("Using Views", {

            describe("Matching", {
                var s = new ViewTestSystem1();

                describe("When add entities", {
                    beforeAll({
                        Workflow.addSystem(s);
                        for (i in 0...300) {
                            var e = new Entity();
                            e.add(new A());
                            if (i % 2 == 0) e.add(new B());
                            if (i % 3 == 0) e.add(new C());
                            if (i % 5 == 0) e.add(new D());
                            if (i % 6 == 0) e.add(new E());
                        }
                    });
                    it("should matching them correctly", {
                        s.a.entities.length.should.be(300);
                        s.b.entities.length.should.be(150);

                        s.ab.entities.length.should.be(150);
                        s.bc.entities.length.should.be(50);

                        s.abcd.entities.length.should.be(10);
                    });
                });

                describe("When remove components", {
                    beforeAll({
                        for(e in Workflow.entities) {
                            e.remove(A);
                        }
                    });
                    it("should matching them correctly", {
                        s.a.entities.length.should.be(0);
                        s.b.entities.length.should.be(150);

                        s.ab.entities.length.should.be(0);
                        s.bc.entities.length.should.be(50);

                        s.abcd.entities.length.should.be(0);
                    });
                });

                describe("When remove entities", {
                    beforeAll({
                        for(e in Workflow.entities) {
                            e.destroy();
                        }
                    });
                    it("should matching them correctly", {
                        s.a.entities.length.should.be(0);
                        s.b.entities.length.should.be(0);

                        s.ab.entities.length.should.be(0);
                        s.bc.entities.length.should.be(0);

                        s.abcd.entities.length.should.be(0);
                    });
                });
            });


            describe("Signals", {
                var s:ViewTestSystem1;
                var e:Entity;
                var r = "";

                beforeAll({
                    s = new ViewTestSystem1();
                    Workflow.addSystem(s);
                    s.ab.onAdded.add(function(id, a, b) r += '+');
                    s.ab.onRemoved.add(function(id, a, b) r += '-');
                    e = new Entity();
                });

                describe("When add Entity", {
                    beforeAll(e.add(new A(), new B()));
                    it("should be dispatched", r.should.be("+"));
                });

                describe("Then add Components", {
                    beforeAll(e.add(new A(), new B()));
                    it("should not be dispatched", r.should.be("+"));
                });

                describe("Then remove Components", {
                    beforeAll(e.remove(A, B));
                    it("should be dispatched", r.should.be("+-"));
                });

                describe("Then remove Components again", {
                    beforeAll(e.remove(A, B));
                    it("should not be dispatched", r.should.be("+-"));
                });

            });


            describe("Iterating", {
                var s = new ViewIterTestSystem();
                var s2 = new ViewIterSignalTestSystem();

                describe("When remove Component while meta iterate", {
                    beforeAll({
                        Workflow.dispose();
                        Workflow.addSystem(s);
                        s.result = '';
                        for (i in 0...10) new Entity().add(new A(), new V(i));
                        Workflow.update(0);
                    });
                    it("should has correct result", s.result.should.be("-1-3-5-7-9"));
                });

                describe("When remove Component while manually iterate", {
                    beforeAll({
                        Workflow.dispose();
                        Workflow.addSystem(s);
                        s.result = '';
                        for (i in 0...10) new Entity().add(new A(), new V(i));
                        s.whileIterManuallyRemoveComponent();
                    });
                    it("should has correct result", s.result.should.be("-1-3-5-7-9"));
                });

                describe("When deact Entity while manually iterate", {
                    beforeAll({
                        Workflow.dispose();
                        Workflow.addSystem(s);
                        s.result = '';
                        for (i in 0...10) new Entity().add(new A(), new V(i));
                        s.whileIterManuallyDeactEntity();
                    });
                    it("should has correct result", s.result.should.be("-1-3-5-7-9"));
                });

                describe("When destroy Entity while manually iterate", {
                    beforeAll({
                        Workflow.dispose();
                        Workflow.addSystem(s);
                        s.result = '';
                        for (i in 0...10) new Entity().add(new A(), new V(i));
                        s.whileIterManuallyDestroyEntity();
                    });
                    it("should has correct result", s.result.should.be("-1-3-5-7-9"));
                });


                describe("When remove/add Component while meta iterate", {
                    beforeAll({
                        Workflow.dispose();
                        Workflow.addSystem(s2);
                        s2.result = '';
                        new Entity().add(new A(), new V(0));
                        Workflow.update(0);
                    });
                    it("should has correct result", s2.result.should.be("0>*<01><12>*"));
                });

            });


            describe("Same Param Types", {
                beforeAll(Workflow.dispose());
                beforeAll(Workflow.addSystem(new SameViewSystem()));
                it("should not define doublicates", {
                    SameViewSystem.ab.should.be(SameViewSystem.ba);
                    SameViewSystem.ab.should.be(SameViewSystem.ab1);
                    SameViewSystem.ab.should.be(SameViewSystem.ab2);
                    SameViewSystem.ab.should.be(SameViewSystem.ab3);
                    SameViewSystem.ab.should.be(SameViewSystem.ab4);
                });
                it("should not add doublicates to the flow", {
                    Workflow.views.length.should.be(1);
                });
            });


            describe("View Ref", {
                describe("When view was defined somewhere already", {
                    var view = Workflow.getView(B, A);
                    beforeAll(Workflow.dispose());
                    beforeAll(view.activate());
                    beforeAll(new Entity().add(new A(), new B(), new C(), new D(), new E()));
                    it("should be added to the flow", Workflow.views.length.should.be(1));
                    it("should matching entities correctly", view.entities.length.should.be(1));
                });
                describe("When view was not defined before", {
                    var view = Workflow.getView(D, C, B);
                    beforeAll(Workflow.dispose());
                    beforeAll(view.activate());
                    beforeAll(new Entity().add(new A(), new B(), new C(), new D(), new E()));
                    it("should be added to the flow", Workflow.views.length.should.be(1));
                    it("should matching entities correctly", view.entities.length.should.be(1));
                });
            });


        });
    }
}

class ViewTestSystem1 extends echos.System {

    public var a:View<A->Void>;
    public var b:View<B->Void>;

    public var ab:View<A->B->Void>;
    public var bc:View<B->C->Void>;

    public var abcd:View<A->B->C->D->Void>;

}

typedef TAB = { a:A, b:B };
typedef VAB = View<{ a:A, b:B }>;
class SameViewSystem extends echos.System {

    public static var ab:View<A->B->Void>;
    public static var ba:View<B->A->Void>;

    public static var ab1:View<TAB>;
    public static var ab2:VAB;
    public static var ab3:View<{ a:A, b:B }>;
    public static var ab4:View<A->B>;

    @u function abFunc(a:A, b:B) { }
    @u function baFunc(b:B, a:A) { }
    @u function cdFunc(c:B, d:A) { }

    @u function abFloatEntityFunc(delta:Float, entity:Entity, a:A, b:B) { }
    @u function abFloatIntFunc(a:A, delta:Float, id:Int, b:B) { }
    @u function abEchoEntityFunc(entity:echos.Entity, a:A, b:B) { }

}


class A {
    public function new() { };
}

class B {
    public function new() { };
}

abstract C(A) {
    public function new() this = new A();
}

abstract D(B) {
    public function new() this = new B();
}

class E extends A {
    public function new() super();
}


class ViewIterTestSystem extends echos.System {
    public var result = '';

    public var view:View<A->V->Void>;

    @u function whileIterByMetaRemoveComponent(id:Entity, a:A, v:V) {
        if (v.val % 2 == 0) {
            id.remove(A);
            result += '-';
        } else result += '$v';
    }

    public function whileIterManuallyRemoveComponent() {
        view.iter(function(id, a, v) {
            if (v.val % 2 == 0) {
                id.remove(A);
                result += '-';
            } else result += '$v';
        });
    }

    public function whileIterManuallyDeactEntity() {
        view.iter(function(id, a, v) {
            if (v.val % 2 == 0) {
                id.deactivate();
                result += '-';
            } else result += '$v';
        });
    }

    public function whileIterManuallyDestroyEntity() {
        view.iter(function(id, a, v) {
            if (v.val % 2 == 0) {
                id.destroy();
                result += '-';
            } else result += '$v';
        });
    }
}

class ViewIterSignalTestSystem extends echos.System {
    public var result = '';

    public var view:View<A->V->Void>;

    @a function ad(id:Entity, a:A, v:V) {
        result += '$v>';
    }

    @r function rm(id:Entity, a:A, v:V) {
        result += '<$v';
    }

    @u function iter(id:Entity, a:A, v:V) {
        result += '*';
        id.remove(V);
        id.add(new V(1));
        id.remove(V);
        id.add(new V(2));
        result += '*';
    }
}

class V {
    public var val:Int;
    public function new(val) {
        this.val = val;
    }
    public function toString() {
        return Std.string(val);
    }
}
