import echos.*;

using buddy.Should;
using Lambda;

class ViewTest extends buddy.BuddySuite {
    public function new() {
        describe("View", {

            describe("Matching", {
                var s = new MatchingViewSystem();
                var entities = new Array<Entity>();

                beforeEach({
                    Workflow.dispose();
                    Workflow.addSystem(s);
                });

                describe("When add Entities with random Components", {
                    beforeEach({
                        for (i in 0...300) {
                            var e = new Entity();
                            e.add(new A());
                            if (i % 2 == 0) e.add(new B());
                            if (i % 3 == 0) e.add(new C());
                            if (i % 4 == 0) e.add(new D());
                            if (i % 5 == 0) e.add(new E());
                            entities.push(e);
                        }
                    });
                    it("should matching correctly", {
                        s.a.entities.length.should.be(300);
                        s.b.entities.length.should.be(150);
                        s.ab.entities.length.should.be(150);
                        s.bc.entities.length.should.be(50);
                        s.abcd.entities.length.should.be(25);
                    });

                    describe("When remove one of Components", {
                        beforeEach({
                            for (e in entities) {
                                e.remove(A);
                            }
                            Workflow.update(0);
                        });
                        it("should matching correctly", {
                            s.a.entities.length.should.be(0);
                            s.b.entities.length.should.be(150);
                            s.ab.entities.length.should.be(0);
                            s.bc.entities.length.should.be(50);
                            s.abcd.entities.length.should.be(0);
                        });

                        describe("When add one of Components", {
                            beforeEach({
                                for (e in entities) {
                                    e.add(new A());
                                }
                                Workflow.update(0);
                            });
                            it("should matching correctly", {
                                s.a.entities.length.should.be(300);
                                s.b.entities.length.should.be(150);
                                s.ab.entities.length.should.be(150);
                                s.bc.entities.length.should.be(50);
                                s.abcd.entities.length.should.be(25);
                            });
                        });
                    });

                    describe("When remove all of Components", {
                        beforeEach({
                            for (e in entities) {
                                e.removeAll();
                            }
                            Workflow.update(0);
                        });
                        it("should matching correctly", {
                            s.a.entities.length.should.be(0);
                            s.b.entities.length.should.be(0);
                            s.ab.entities.length.should.be(0);
                            s.bc.entities.length.should.be(0);
                            s.abcd.entities.length.should.be(0);
                        });
                    });

                    describe("When deactivate Entity", {
                        beforeEach({
                            for(e in entities) {
                                e.deactivate();
                            }
                            Workflow.update(0);
                        });
                        it("should matching correctly", {
                            s.a.entities.length.should.be(0);
                            s.b.entities.length.should.be(0);
                            s.ab.entities.length.should.be(0);
                            s.bc.entities.length.should.be(0);
                            s.abcd.entities.length.should.be(0);
                        });

                        describe("When activate Entity", {
                            beforeEach({
                                for(e in entities) {
                                    e.activate();
                                }
                                Workflow.update(0);
                            });
                            it("should matching correctly", {
                                s.a.entities.length.should.be(300);
                                s.b.entities.length.should.be(150);
                                s.ab.entities.length.should.be(150);
                                s.bc.entities.length.should.be(50);
                                s.abcd.entities.length.should.be(25);
                            });
                        });
                    });

                    describe("When destroy Entity", {
                        beforeEach({
                            for(e in entities) {
                                e.destroy();
                            }
                            Workflow.update(0);
                        });
                        it("should matching correctly", {
                            s.a.entities.length.should.be(0);
                            s.b.entities.length.should.be(0);
                            s.ab.entities.length.should.be(0);
                            s.bc.entities.length.should.be(0);
                            s.abcd.entities.length.should.be(0);
                        });
                    });
                });
            });


            describe("Signals", {
                var s:MatchingViewSystem;
                var e:Entity;
                var r = "";

                beforeAll({
                    s = new MatchingViewSystem();
                    Workflow.addSystem(s);
                    s.ab.onAdded.add(function(id, a, b) r += '+');
                    s.ab.onRemoved.add(function(id, a, b) r += '-');
                    e = new Entity();
                });

                describe("When add Components", {
                    beforeAll(e.add(new A(), new B()));
                    it("should be dispatched", r.should.be("+"));
                });

                describe("Then add same Components", {
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
                var s = new IterViewSystem();

                beforeEach({
                    Workflow.dispose();
                    Workflow.addSystem(s);
                    s.result = '';
                });

                describe("Use Case", {

                    beforeEach({
                        for (i in 0...5) new Entity().add(new A(), new V(i));
                    });

                    describe("When remove Component while manually iterate", {
                        beforeEach(s.whileIterManuallyRemoveComponent());
                        beforeEach(Workflow.update(0));
                        it("should has view with correct length", s.view.entities.length.should.be(2));
                        it("should has correct result", s.result.should.startWith("0>1>2>3>4><0-1<2-3<4-"));
                    });

                    describe("When deactivate Entity while manually iterate", {
                        beforeEach(s.whileIterManuallyDeactEntity());
                        beforeEach(Workflow.update(0));
                        it("should has view with correct length", s.view.entities.length.should.be(2));
                        it("should has correct result", s.result.should.startWith("0>1>2>3>4><0-1<2-3<4-"));
                    });

                    describe("When destroy Entity while manually iterate", {
                        beforeEach(s.whileIterManuallyDestroyEntity());
                        beforeEach(Workflow.update(0));
                        it("should has view with correct length", s.view.entities.length.should.be(2));
                        it("should has correct result", s.result.should.startWith("0>1>2>3>4><0-1<2-3<4-"));
                    });


                    describe("When create Entity while manually iterate", {
                        beforeEach(s.whileIterManuallyCreateEntity());
                        beforeEach(Workflow.update(0));
                        it("should has view with correct length", s.view.entities.length.should.be(8));
                        it("should has correct result", s.result.should.startWith("0>1>2>3>4>_9>_1_9>_3_9>"));
                    });

                    describe("When destroy and create Entity while manually iterate", {
                        beforeEach(s.whileIterManuallyDestroyAndCreateEntity());
                        beforeEach(Workflow.update(0));
                        it("should has view with correct length", s.view.entities.length.should.be(5));
                        it("should has correct result", s.result.should.startWith("0>1>2>3>4>_<09>_1_<29>_3_<49>"));
                    });

                });


                describe("Stress", {

                    beforeEach(new Entity().add(new A(), new V(0)));

                    describe("When r/a/r/a Component while manually iterate", {
                        beforeEach(s.whileIterRARA());
                        it("should has view with correct length", s.view.size().should.be(1));
                        it("should has correct result", s.result.should.startWith("0>*<01><12>*"));
                    });

                    describe("When rr/aa/rr/aa Component while manually iterate", {
                        beforeEach(s.whileIterRRAARRAA());
                        it("should has view with correct length", s.view.size().should.be(1));
                        it("should has correct result", s.result.should.startWith("0>*<01><23>*"));
                    });

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

class MatchingViewSystem extends echos.System {

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


class IterViewSystem extends echos.System {
    public var result = '';
    public var view:View<A->V->Void>;

    @a function ad(id:Entity, a:A, v:V) {
        result += '$v>';
    }

    @r function rm(id:Entity, a:A, v:V) {
        result += '<$v';
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

    public function whileIterManuallyCreateEntity() {
        view.iter(function(id, a, v) {
            result += '_';
            if (v.val % 2 == 0) {
                new Entity().add(new A(), new V(9));
            } else result += '$v';
        });
    }

    public function whileIterManuallyDestroyAndCreateEntity() {
        view.iter(function(id, a, v) {
            result += '_';
            if (v.val % 2 == 0) {
                id.destroy();
                new Entity().add(new A(), new V(9));
            } else result += '$v';
        });
    }

    public function whileIterRARA() {
        view.iter(function(id, a, v) {
            result += '*';
            id.remove(V);
            id.add(new V(1));
            id.remove(V);
            id.add(new V(2));
            result += '*';
        });
    }

    public function whileIterRRAARRAA() {
        view.iter(function(id, a, v) {
            result += '*';
            id.remove(V);
            id.remove(V);
            id.add(new V(1));
            id.add(new V(2));
            id.remove(V);
            id.remove(V);
            id.add(new V(3));
            id.add(new V(4));
            result += '*';
        });
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
