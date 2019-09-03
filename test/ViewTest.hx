import echos.*;

using buddy.Should;
using Lambda;

class ViewTest extends buddy.BuddySuite {
    public function new() {
        describe("View", {
            var log = '';

            beforeEach(Workflow.dispose());
            beforeEach(log = '');

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

                        describe("When add one of Components back", {
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
                var e:Entity;
                var s = new MatchingViewSystem();
                var onad = function(id:Entity, a:A, v:V) log += '+$v';
                var onrm = function(id:Entity, a:A, v:V) log += '-$v';

                beforeEach({
                    Workflow.dispose();
                    Workflow.addSystem(s);
                    s.av.onAdded.add(onad);
                    s.av.onRemoved.add(onrm);
                    e = new Entity();
                });

                describe("When add matched Components", {
                    beforeEach(e.add(new A(), new V(1)));
                    it("should be dispatched", log.should.be("+1"));

                    describe("When add matched Components again", {
                        beforeEach(e.add(new V(2)));
                        it("should not be dispatched", log.should.be("+1"));
                    });

                    describe("When remove matched Components", {
                        beforeEach(e.remove(V));
                        it("should be dispatched", log.should.be("+1-1"));

                        describe("When remove matched Components again", {
                            beforeEach(e.remove(V));
                            it("should not be dispatched", log.should.be("+1-1"));
                        });

                        describe("When add matched Components back", {
                            beforeEach(e.add(new V(2)));
                            it("should be dispatched", log.should.be("+1-1+2"));
                        });
                    });

                    describe("When remove all of Components", {
                        beforeEach(e.removeAll());
                        it("should be dispatched", log.should.be("+1-1"));

                        describe("When remove all of Components again", {
                            beforeEach(e.removeAll());
                            it("should not be dispatched", log.should.be("+1-1"));
                        });
                    });

                    describe("When deactivate Entity", {
                        beforeEach(e.deactivate());
                        it("should be dispatched", log.should.be("+1-1"));

                        describe("When deactivate Entity again", {
                            beforeEach(e.deactivate());
                            it("should not be dispatched", log.should.be("+1-1"));
                        });

                        describe("When activate Entity", {
                            beforeEach(e.activate());
                            it("should be dispatched", log.should.be("+1-1+1"));

                            describe("When activate Entity again", {
                                beforeEach(e.activate());
                                it("should not be dispatched", log.should.be("+1-1+1"));
                            });
                        });
                    });

                    describe("When destroy Entity", {
                        beforeEach(e.destroy());
                        it("should be dispatched", log.should.be("+1-1"));

                        describe("When create new Entity (reuse)", {
                            beforeEach(new Entity().add(new A(), new V(2)));
                            it("should be dispatched", log.should.be("+1-1+2"));
                        });
                    });
                });
            });


            describe("Iterating", {
                var onad = function(id:Entity, a:A, v:V) log += '+$v';
                var onrm = function(id:Entity, a:A, v:V) log += '-$v';
                var s = new IteratingViewSystem();

                beforeEach({
                    Workflow.dispose();
                    Workflow.addSystem(s);
                    s.av.onAdded.add(onad);
                    s.av.onRemoved.add(onrm);
                    for (i in 0...5) new Entity().add(new A(), new V(i));
                });

                describe("When iterating", {
                    beforeEach({
                        s.f = function(id, a, v) log += '$v';
                        Workflow.update(0);
                    });
                    it("should has correct length", s.av.entities.length.should.be(5));
                    it("should has correct log", log.should.be("+0+1+2+3+401234"));

                    describe("When add an Entity and iterating", {
                        beforeEach({
                            new Entity().add(new A(), new V(5));
                            Workflow.update(0);
                        });
                        it("should has correct length", s.av.entities.length.should.be(6));
                        it("should has correct log", log.should.be("+0+1+2+3+401234+5012345"));
                    });
                });

                describe("When remove Component while iterating", {
                    beforeEach({
                        s.f = function(id, a, v) id.remove(V);
                        Workflow.update(0);
                    });
                    it("should has correct length", s.av.entities.length.should.be(0));
                    it("should has correct log", log.should.be("+0+1+2+3+4-0-1-2-3-4"));
                });

                describe("When remove all of Components while iterating", {
                    beforeEach({
                        s.f = function(id, a, v) id.removeAll();
                        Workflow.update(0);
                    });
                    it("should has correct length", s.av.entities.length.should.be(0));
                    it("should has correct log", log.should.be("+0+1+2+3+4-0-1-2-3-4"));
                });

                describe("When destroy Entity while iterating", {
                    beforeEach({
                        s.f = function(id, a, v) id.destroy();
                        Workflow.update(0);
                    });
                    it("should has correct length", s.av.entities.length.should.be(0));
                    it("should has correct log", log.should.be("+0+1+2+3+4-0-1-2-3-4"));
                });

                describe("When deactivate Entity while iterating", {
                    beforeEach({
                        s.f = function(id, a, v) id.deactivate();
                        Workflow.update(0);
                    });
                    it("should has correct length", s.av.entities.length.should.be(0));
                    it("should has correct log", log.should.be("+0+1+2+3+4-0-1-2-3-4"));
                });

                describe("When create Entity while iterating", {
                    beforeEach({
                        s.f = function(id, a, v) new Entity().add(new A(), new V(9));
                        Workflow.update(0);
                    });
                    it("should has correct length", s.av.entities.length.should.be(10));
                    it("should has correct log", log.should.be("+0+1+2+3+4+9+9+9+9+9"));
                });

                describe("When destroy and create Entity while iterating", {
                    beforeEach({
                        s.f = function(id, a, v) {
                            id.destroy();
                            new Entity().add(new A(), new V(9));
                        };
                        Workflow.update(0);
                    });
                    it("should has correct length", s.av.entities.length.should.be(5));
                    it("should has correct log", log.should.be("+0+1+2+3+4-0+9-1+9-2+9-3+9-4+9"));
                });

                describe("When remove Component while inner iterating", {
                    beforeEach({
                        s.f = function(id, a, v) {
                            s.av.iter(function(e, a, v) e.remove(V));
                        }
                        Workflow.update(0);
                    });
                    it("should has correct length", s.av.entities.length.should.be(0));
                    it("should has correct log", log.should.be("+0+1+2+3+4-0-1-2-3-4"));
                });

                describe("When remove all of Components while inner iterating", {
                    beforeEach({
                        s.f = function(id, a, v) {
                            s.av.iter(function(e, a, v) e.removeAll());
                        }
                        Workflow.update(0);
                    });
                    it("should has correct length", s.av.entities.length.should.be(0));
                    it("should has correct log", log.should.be("+0+1+2+3+4-0-1-2-3-4"));
                });

                describe("When destroy Entity while inner iterating", {
                    beforeEach({
                        s.f = function(id, a, v) {
                            s.av.iter(function(e, a, v) e.destroy());
                        }
                        Workflow.update(0);
                    });
                    it("should has correct length", s.av.entities.length.should.be(0));
                    it("should has correct log", log.should.be("+0+1+2+3+4-0-1-2-3-4"));
                });

                describe("When deactivate Entity while inner iterating", {
                    beforeEach({
                        s.f = function(id, a, v) {
                            s.av.iter(function(e, a, v) e.deactivate());
                        }
                        Workflow.update(0);
                    });
                    it("should has correct length", s.av.entities.length.should.be(0));
                    it("should has correct log", log.should.be("+0+1+2+3+4-0-1-2-3-4"));
                });
            });


            describe("Activate/Deactivate", {
                var s = new MatchingViewSystem();
                var onad = function(id:Entity, a:A, v:V) log += '+$v';
                var onrm = function(id:Entity, a:A, v:V) log += '-$v';

                beforeEach({
                    s.av.onAdded.add(onad);
                    s.av.onRemoved.add(onrm);
                    for (i in 1...4) new Entity().add(new A(), new V(i));
                });

                describe("Initially", {
                    it("should not be active", s.av.isActive().should.be(false));
                    it("should not has entities", s.av.entities.length.should.be(0));
                    it("should has on ad signals", s.av.onAdded.size().should.be(1));
                    it("should has on rm signals", s.av.onRemoved.size().should.be(1));
                    it("should has correct log", log.should.be(""));

                    describe("When activate", {
                        beforeEach({
                            s.av.activate();
                        });
                        it("should be active", s.av.isActive().should.be(true));
                        it("should has entities", s.av.entities.length.should.be(3));
                        it("should has on ad signals", s.av.onAdded.size().should.be(1));
                        it("should has on rm signals", s.av.onRemoved.size().should.be(1));
                        it("should has correct log", log.should.be("+1+2+3"));

                        describe("When deactivate", {
                            beforeEach({
                                s.av.deactivate();
                            });
                            it("should not be active", s.av.isActive().should.be(false));
                            it("should not has entities", s.av.entities.length.should.be(0));
                            it("should has on ad signals", s.av.onAdded.size().should.be(1));
                            it("should has on rm signals", s.av.onRemoved.size().should.be(1));
                            it("should has correct log", log.should.be("+1+2+3-3-2-1"));
                        });

                        describe("When dispose", {
                            beforeEach({
                                @:privateAccess s.av.dispose();
                            });
                            it("should not be active", s.av.isActive().should.be(false));
                            it("should not has entities", s.av.entities.length.should.be(0));
                            it("should not has on ad signals", s.av.onAdded.size().should.be(0));
                            it("should not has on rm signals", s.av.onRemoved.size().should.be(0));
                            it("should has correct log", log.should.be("+1+2+3-3-2-1"));
                        });
                    });
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

    public var av:View<A->V->Void>;

}

class IteratingViewSystem extends echos.System {

    public var av:View<A->V->Void>;

    public var f:Entity->A->V->Void = null;

    @u function update(id:Entity, a:A, v:V) {
        if (f != null) {
            f(id, a, v);
        }
    }

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

class V {
    var val:Int;
    public function new(val) this.val = val;
    public function toString() return Std.string(val);
}
