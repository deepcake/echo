import echoes.*;

using buddy.Should;
using Lambda;

class ViewTest extends buddy.BuddySuite {
    public function new() {
        describe("Test View", {
            var log = '';

            var mvs:MatchingViewSystem;
            var ivs:IteratingViewSystem;

            beforeEach(Workflow.reset());
            beforeEach({
                log = '';
                mvs = new MatchingViewSystem();
                ivs = new IteratingViewSystem();
            });

            describe("Test Matching", {
                var entities:Array<Entity>;

                beforeEach({
                    Workflow.addSystem(mvs);
                    entities = new Array<Entity>();
                });

                describe("When add Entities with different Components", {
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
                        mvs.a.entities.length.should.be(300);
                        mvs.b.entities.length.should.be(150);
                        mvs.ab.entities.length.should.be(150);
                        mvs.bc.entities.length.should.be(50);
                        mvs.abcd.entities.length.should.be(25);
                    });

                    describe("Then add a Component to all Entities", {
                        beforeEach({
                            for (e in entities) {
                                e.add(new C());
                            }
                            Workflow.update(0);
                        });
                        it("should matching correctly", {
                            mvs.a.entities.length.should.be(300);
                            mvs.b.entities.length.should.be(150);
                            mvs.ab.entities.length.should.be(150);
                            mvs.bc.entities.length.should.be(150);
                            mvs.abcd.entities.length.should.be(75);
                        });
                    });

                    describe("Then remove a Component from all Entities", {
                        beforeEach({
                            for (e in entities) {
                                e.remove(C);
                            }
                            Workflow.update(0);
                        });
                        it("should matching correctly", {
                            mvs.a.entities.length.should.be(300);
                            mvs.b.entities.length.should.be(150);
                            mvs.ab.entities.length.should.be(150);
                            mvs.bc.entities.length.should.be(0);
                            mvs.abcd.entities.length.should.be(0);
                        });

                        describe("Then add a Component to all Entities back", {
                            beforeEach({
                                for (e in entities) {
                                    e.add(new C());
                                }
                                Workflow.update(0);
                            });
                            it("should matching correctly", {
                                mvs.a.entities.length.should.be(300);
                                mvs.b.entities.length.should.be(150);
                                mvs.ab.entities.length.should.be(150);
                                mvs.bc.entities.length.should.be(150);
                                mvs.abcd.entities.length.should.be(75);
                            });
                        });
                    });

                    describe("Then remove all of Components", {
                        beforeEach({
                            for (e in entities) {
                                e.removeAll();
                            }
                            Workflow.update(0);
                        });
                        it("should matching correctly", {
                            mvs.a.entities.length.should.be(0);
                            mvs.b.entities.length.should.be(0);
                            mvs.ab.entities.length.should.be(0);
                            mvs.bc.entities.length.should.be(0);
                            mvs.abcd.entities.length.should.be(0);
                        });
                    });

                    describe("Then deactivate Entities", {
                        beforeEach({
                            for(e in entities) {
                                e.deactivate();
                            }
                            Workflow.update(0);
                        });
                        it("should matching correctly", {
                            mvs.a.entities.length.should.be(0);
                            mvs.b.entities.length.should.be(0);
                            mvs.ab.entities.length.should.be(0);
                            mvs.bc.entities.length.should.be(0);
                            mvs.abcd.entities.length.should.be(0);
                        });

                        describe("Then activate Entities", {
                            beforeEach({
                                for(e in entities) {
                                    e.activate();
                                }
                                Workflow.update(0);
                            });
                            it("should matching correctly", {
                                mvs.a.entities.length.should.be(300);
                                mvs.b.entities.length.should.be(150);
                                mvs.ab.entities.length.should.be(150);
                                mvs.bc.entities.length.should.be(50);
                                mvs.abcd.entities.length.should.be(25);
                            });
                        });
                    });

                    describe("Then destroy Entities", {
                        beforeEach({
                            for(e in entities) {
                                e.destroy();
                            }
                            Workflow.update(0);
                        });
                        it("should matching correctly", {
                            mvs.a.entities.length.should.be(0);
                            mvs.b.entities.length.should.be(0);
                            mvs.ab.entities.length.should.be(0);
                            mvs.bc.entities.length.should.be(0);
                            mvs.abcd.entities.length.should.be(0);
                        });
                    });
                });
            });


            describe("Test Signals", {
                var e:Entity;
                var onad = function(id:Entity, a:A, v:V) log += '+$v';
                var onrm = function(id:Entity, a:A, v:V) log += '-$v';

                beforeEach({
                    Workflow.addSystem(mvs);
                    mvs.av.onAdded.add(onad);
                    mvs.av.onRemoved.add(onrm);
                    e = new Entity();
                });

                describe("When add matched Components", {
                    beforeEach(e.add(new A(), new V(1)));
                    it("should be dispatched", log.should.be("+1"));

                    describe("Then add matched Components again", {
                        beforeEach(e.add(new V(2)));
                        it("should not be dispatched", log.should.be("+1"));
                    });

                    describe("Then remove matched Components", {
                        beforeEach(e.remove(V));
                        it("should be dispatched", log.should.be("+1-1"));

                        describe("Then remove matched Components again", {
                            beforeEach(e.remove(V));
                            it("should not be dispatched", log.should.be("+1-1"));
                        });

                        describe("Then add matched Components back", {
                            beforeEach(e.add(new V(2)));
                            it("should be dispatched", log.should.be("+1-1+2"));
                        });
                    });

                    describe("Then remove all of Components", {
                        beforeEach(e.removeAll());
                        it("should be dispatched", log.should.be("+1-1"));

                        describe("Then remove all of Components again", {
                            beforeEach(e.removeAll());
                            it("should not be dispatched", log.should.be("+1-1"));
                        });
                    });

                    describe("Then deactivate Entity", {
                        beforeEach(e.deactivate());
                        it("should be dispatched", log.should.be("+1-1"));

                        describe("Then deactivate Entity again", {
                            beforeEach(e.deactivate());
                            it("should not be dispatched", log.should.be("+1-1"));
                        });

                        describe("Then activate Entity", {
                            beforeEach(e.activate());
                            it("should be dispatched", log.should.be("+1-1+1"));

                            describe("Then activate Entity again", {
                                beforeEach(e.activate());
                                it("should not be dispatched", log.should.be("+1-1+1"));
                            });
                        });
                    });

                    describe("Then destroy Entity", {
                        beforeEach(e.destroy());
                        it("should be dispatched", log.should.be("+1-1"));

                        describe("Then create new Entity (reuse)", {
                            beforeEach(new Entity().add(new A(), new V(2)));
                            it("should be dispatched", log.should.be("+1-1+2"));
                        });
                    });
                });
            });


            describe("Test Iterating", {
                var onad = function(id:Entity, a:A, v:V) log += '+$v';
                var onrm = function(id:Entity, a:A, v:V) log += '-$v';

                beforeEach({
                    Workflow.addSystem(ivs);
                    ivs.av.onAdded.add(onad);
                    ivs.av.onRemoved.add(onrm);
                    for (i in 0...5) new Entity().add(new A(), new V(i));
                });

                describe("When iterating", {
                    beforeEach({
                        ivs.f = function(id, a, v) log += '$v';
                        Workflow.update(0);
                    });
                    it("should have correct length", ivs.av.entities.length.should.be(5));
                    it("should have correct log", log.should.be("+0+1+2+3+401234"));

                    describe("Then add an Entity and iterating", {
                        beforeEach({
                            new Entity().add(new A(), new V(5));
                            Workflow.update(0);
                        });
                        it("should have correct length", ivs.av.entities.length.should.be(6));
                        it("should have correct log", log.should.be("+0+1+2+3+401234+5012345"));
                    });
                });

                describe("Then remove Component while iterating", {
                    beforeEach({
                        ivs.f = function(id, a, v) id.remove(V);
                        Workflow.update(0);
                    });
                    it("should have correct length", ivs.av.entities.length.should.be(0));
                    it("should have correct log", log.should.be("+0+1+2+3+4-0-1-2-3-4"));
                });

                describe("Then remove all of Components while iterating", {
                    beforeEach({
                        ivs.f = function(id, a, v) id.removeAll();
                        Workflow.update(0);
                    });
                    it("should have correct length", ivs.av.entities.length.should.be(0));
                    it("should have correct log", log.should.be("+0+1+2+3+4-0-1-2-3-4"));
                });

                describe("Then destroy Entity while iterating", {
                    beforeEach({
                        ivs.f = function(id, a, v) id.destroy();
                        Workflow.update(0);
                    });
                    it("should have correct length", ivs.av.entities.length.should.be(0));
                    it("should have correct log", log.should.be("+0+1+2+3+4-0-1-2-3-4"));
                });

                describe("Then deactivate Entity while iterating", {
                    beforeEach({
                        ivs.f = function(id, a, v) id.deactivate();
                        Workflow.update(0);
                    });
                    it("should have correct length", ivs.av.entities.length.should.be(0));
                    it("should have correct log", log.should.be("+0+1+2+3+4-0-1-2-3-4"));
                });

                describe("Then create Entity while iterating", {
                    beforeEach({
                        ivs.f = function(id, a, v) {
                            if ('$v' != '9') {
                                new Entity().add(new A(), new V(9));
                            }
                        }
                        Workflow.update(0);
                    });
                    it("should have correct length", ivs.av.entities.length.should.be(10));
                    it("should have correct log", log.should.be("+0+1+2+3+4+9+9+9+9+9"));
                });

                describe("Then destroy and create Entity while iterating", {
                    beforeEach({
                        ivs.f = function(id, a, v) {
                            if ('$v' != '9') {
                                id.destroy();
                                new Entity().add(new A(), new V(9));
                            }
                        }
                        Workflow.update(0);
                    });
                    it("should have correct length", ivs.av.entities.length.should.be(5));
                    it("should have correct log", log.should.be("+0+1+2+3+4-0+9-1+9-2+9-3+9-4+9"));
                });

                describe("Then remove Component while inner iterating", {
                    beforeEach({
                        ivs.f = function(id, a, v) {
                            ivs.av.iter(function(e, a, v) e.remove(V));
                        }
                        Workflow.update(0);
                    });
                    it("should have correct length", ivs.av.entities.length.should.be(0));
                    it("should have correct log", log.should.be("+0+1+2+3+4-0-1-2-3-4"));
                });

                describe("Then remove all of Components while inner iterating", {
                    beforeEach({
                        ivs.f = function(id, a, v) {
                            ivs.av.iter(function(e, a, v) e.removeAll());
                        }
                        Workflow.update(0);
                    });
                    it("should have correct length", ivs.av.entities.length.should.be(0));
                    it("should have correct log", log.should.be("+0+1+2+3+4-0-1-2-3-4"));
                });

                describe("Then destroy Entity while inner iterating", {
                    beforeEach({
                        ivs.f = function(id, a, v) {
                            ivs.av.iter(function(e, a, v) e.destroy());
                        }
                        Workflow.update(0);
                    });
                    it("should have correct length", ivs.av.entities.length.should.be(0));
                    it("should have correct log", log.should.be("+0+1+2+3+4-0-1-2-3-4"));
                });

                describe("Then deactivate Entity while inner iterating", {
                    beforeEach({
                        ivs.f = function(id, a, v) {
                            ivs.av.iter(function(e, a, v) e.deactivate());
                        }
                        Workflow.update(0);
                    });
                    it("should have correct length", ivs.av.entities.length.should.be(0));
                    it("should have correct log", log.should.be("+0+1+2+3+4-0-1-2-3-4"));
                });
            });


            describe("Test Activate/Deactivate", {
                var onad = function(id:Entity, a:A, v:V) log += '+$v';
                var onrm = function(id:Entity, a:A, v:V) log += '-$v';

                beforeEach({
                    mvs.av.onAdded.add(onad);
                    mvs.av.onRemoved.add(onrm);
                    for (i in 1...4) new Entity().add(new A(), new V(i));
                });

                describe("Initially", {
                    it("should not be active", mvs.av.isActive().should.be(false));
                    it("should not have entities", mvs.av.entities.length.should.be(0));
                    it("should have on ad signals", mvs.av.onAdded.size().should.be(1));
                    it("should have on rm signals", mvs.av.onRemoved.size().should.be(1));
                    it("should have correct log", log.should.be(""));

                    describe("Then activate", {
                        beforeEach({
                            mvs.av.activate();
                        });
                        it("should be active", mvs.av.isActive().should.be(true));
                        it("should have entities", mvs.av.entities.length.should.be(3));
                        it("should have on ad signals", mvs.av.onAdded.size().should.be(1));
                        it("should have on rm signals", mvs.av.onRemoved.size().should.be(1));
                        it("should have correct log", log.should.be("+1+2+3"));

                        describe("Then deactivate", {
                            beforeEach({
                                mvs.av.deactivate();
                            });
                            it("should not be active", mvs.av.isActive().should.be(false));
                            it("should not have entities", mvs.av.entities.length.should.be(0));
                            it("should have on ad signals", mvs.av.onAdded.size().should.be(1));
                            it("should have on rm signals", mvs.av.onRemoved.size().should.be(1));
                            it("should have correct log", log.should.be("+1+2+3-1-2-3"));
                        });

                        describe("Then reset", {
                            beforeEach({
                                @:privateAccess mvs.av.reset();
                            });
                            it("should not be active", mvs.av.isActive().should.be(false));
                            it("should not have entities", mvs.av.entities.length.should.be(0));
                            it("should not have on ad signals", mvs.av.onAdded.size().should.be(0));
                            it("should not have on rm signals", mvs.av.onRemoved.size().should.be(0));
                            it("should have correct log", log.should.be("+1+2+3-1-2-3"));
                        });
                    });
                });
            });


            describe("Test Sorting", {
                var vprinter = function(e:Entity) return '${ e.get(V) }';
                var eprinter = function(e:Entity) return '$e';

                var gt = function(e1:Entity, e2:Entity) return e2.get(V).val - e1.get(V).val;
                var lr = function(e1:Entity, e2:Entity) return e1.get(V).val - e2.get(V).val;

                describe("Initially", {
                    beforeEach({
                        Workflow.addSystem(ivs);
                        var id = 0;
                        for (i in 0...3) {
                            for (j in 1...4) {
                                new Entity().add(
                                    new V(j * 2), 
                                    new A()
                                );
                            }
                        }
                    });

                    it("should have correct v order", ivs.av.entities.map(vprinter).join("").should.be("246246246"));
                    it("should have correct e order", ivs.av.entities.map(eprinter).join("").should.be("012345678"));

                    describe("Then sort desc", {
                        beforeEach({
                            ivs.av.entities.sort(gt);
                        });
                        it("should have correct v order", ivs.av.entities.map(vprinter).join("").should.be("666444222"));
                        it("should have correct e order", ivs.av.entities.map(eprinter).join("").should.be("258147036"));

                        describe("Then sort desc again", {
                            beforeEach({
                                ivs.av.entities.sort(gt);
                            });
                            it("should not change v order", ivs.av.entities.map(vprinter).join("").should.be("666444222"));
                            it("should not change e order", ivs.av.entities.map(eprinter).join("").should.be("258147036"));
                        });

                        describe("Then add one more Entity", {
                            var e:Entity;

                            beforeEach(e = new Entity().add(new V(3), new A()));
                            it("should have correct v order", ivs.av.entities.map(vprinter).join("").should.be("6664442223"));

                            describe("Then sort asc", {
                                beforeEach({
                                    ivs.av.entities.sort(lr);
                                });
                                it("should have correct v order", ivs.av.entities.map(vprinter).join("").should.be("2223444666"));

                                describe("Then destroy an Entity", {
                                    beforeEach(e.destroy());
                                    it("should have correct v order", ivs.av.entities.map(vprinter).join("").should.be("222444666"));
                                });
                            });
                        });
                    });

                    describe("Then sort asc", {
                        beforeEach({
                            ivs.av.entities.sort(lr);
                        });
                        it("should have correct v order", ivs.av.entities.map(vprinter).join("").should.be("222444666"));
                        it("should have correct e order", ivs.av.entities.map(eprinter).join("").should.be("036147258"));

                        describe("Then sort asc again", {
                            beforeEach({
                                ivs.av.entities.sort(lr);
                            });
                            it("should not change v order", ivs.av.entities.map(vprinter).join("").should.be("222444666"));
                            it("should not change e order", ivs.av.entities.map(eprinter).join("").should.be("036147258"));
                        });

                        describe("Then add one more Entity", {
                            var e:Entity;

                            beforeEach(e = new Entity().add(new V(3), new A()));
                            it("should have correct v order", ivs.av.entities.map(vprinter).join("").should.be("2224446663"));

                            describe("Then sort desc", {
                                beforeEach({
                                    ivs.av.entities.sort(gt);
                                });
                                it("should have correct v order", ivs.av.entities.map(vprinter).join("").should.be("6664443222"));

                                describe("Then destroy an Entity", {
                                    beforeEach(e.destroy());
                                    it("should have correct v order", ivs.av.entities.map(vprinter).join("").should.be("666444222"));
                                });
                            });
                        });
                    });
                });
            });
        });
    }
}

class MatchingViewSystem extends echoes.System {

    public var a:View<A>;
    public var b:View<B>;

    public var ab:View<A, B>;
    public var bc:View<B, C>;

    public var abcd:View<A, B, C, D>;

    public var av:View<A, V>;

}

class IteratingViewSystem extends echoes.System {

    public var av:View<A, V>;

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
    public var val:Int;
    public function new(val) this.val = val;
    public function toString() return Std.string(val);
}
