using buddy.Should;

import echoes.View;
import echoes.Workflow;
import echoes.Entity;

class SystemMetaTest extends buddy.BuddySuite {
    public function new() {
        describe("Test System Meta", {

            beforeEach({
                Workflow.reset();
                BuildResult.value = '';
            });

            describe("When create System (meta @update)", {
                var entities:Array<Entity>;
                var s1 = new SystemUpdateMeta();

                describe("Then update", {
                    beforeEach(Workflow.update(0));
                    it("should have correct result", {
                        BuildResult.value.should.be('');
                    });

                    describe("Then add system to the flow", {
                        beforeEach(Workflow.addSystem(s1));
                        it("should have correct result", {
                            BuildResult.value.should.be('^');
                        });

                        describe("Then update", {
                            beforeEach(Workflow.update(0));
                            it("should have correct result", {
                                BuildResult.value.should.be('^[0____]');
                            });

                            describe("Then add Entities", {
                                beforeEach({
                                    entities = [ for (i in 0...2) new Entity() ];
                                });
                                it("should have correct result", {
                                    BuildResult.value.should.be('^[0____]');
                                });
            
                                describe("Then update", {
                                    beforeEach(Workflow.update(0));
                                    it("should have correct result", {
                                        BuildResult.value.should.be('^[0____][0___0e0e_]');
                                    });

                                    describe("Then add Component A", {
                                        beforeEach({
                                            for (e in entities) e.add(new CompA());
                                        });
                                        it("should have correct result", {
                                            BuildResult.value.should.be('^[0____][0___0e0e_]');
                                        });

                                        describe("Then update", {
                                            beforeEach(Workflow.update(0));
                                            it("should have correct result", {
                                                BuildResult.value.should.be('^[0____][0___0e0e_][0_AA_0A0A_0e0e_0eA0eA]');
                                            });

                                            describe("Then add Component B", {
                                                beforeEach({
                                                    for (e in entities) e.add(new CompB());
                                                });
                                                it("should have correct result", {
                                                    BuildResult.value.should.be('^[0____][0___0e0e_][0_AA_0A0A_0e0e_0eA0eA]');
                                                });
        
                                                describe("Then update", {
                                                    beforeEach(Workflow.update(0));
                                                    it("should have correct result", {
                                                        BuildResult.value.should.be('^[0____][0___0e0e_][0_AA_0A0A_0e0e_0eA0eA][0_AA_0A0A_0e0e_0eA0eA0eB0eB0eAB0eAB]');
                                                    });

                                                    describe("Then remove System from the flow", {
                                                        beforeEach(Workflow.removeSystem(s1));
                                                        it("should have correct result", {
                                                            BuildResult.value.should.be('^[0____][0___0e0e_][0_AA_0A0A_0e0e_0eA0eA][0_AA_0A0A_0e0e_0eA0eA0eB0eB0eAB0eAB]$');
                                                        });
                            
                                                        describe("Then update", {
                                                            beforeEach(Workflow.update(0));
                                                            it("should have correct result", {
                                                                BuildResult.value.should.be('^[0____][0___0e0e_][0_AA_0A0A_0e0e_0eA0eA][0_AA_0A0A_0e0e_0eA0eA0eB0eB0eAB0eAB]$');
                                                            });
                                                        });
                                                    });
                                                });
                                            });
                                        });
                                    });
                                });
                            });
                        });
                    });
                });
            });

            describe("When create System (meta @added/@removed)", {
                var entities:Array<Entity>;
                var s1 = new SystemAddRemMeta();

                describe("Then create Entities", {
                    beforeEach({
                        entities = [ for (i in 0...2) new Entity().add(new CompA(), new CompB(), new CompC()) ];
                    });
                    it("should have correct result", {
                        BuildResult.value.should.be('');
                    });

                    describe("Then add System to the flow", {
                        beforeEach(Workflow.addSystem(s1));
                        it("should have correct result", {
                            BuildResult.value.should.be('+A+A>A>A+Ae+Ae');
                        });

                        describe("Then remove System from the flow", {
                            beforeEach(Workflow.removeSystem(s1));
                            it("should have correct result", {
                                BuildResult.value.should.be('+A+A>A>A+Ae+Ae<A-A-Ae<A-A-Ae');
                            });

                            describe("Then destroy Entities", {
                                beforeEach({
                                    for (e in entities) e.destroy();
                                });
                                it("should have correct result", {
                                    BuildResult.value.should.be('+A+A>A>A+Ae+Ae<A-A-Ae<A-A-Ae');
                                });
                            });
                        });
                    });
                });

                describe("Then add System to the flow", {
                    beforeEach(Workflow.addSystem(s1));
                    it("should correctly add listeners", {
                        ViewCompA.inst().isActive().should.be(true);
                        ViewCompA.inst().onAdded.size().should.be(3);
                        ViewCompA.inst().onRemoved.size().should.be(3);
                    });

                    describe("Then remove System from the flow", {
                        beforeEach(Workflow.removeSystem(s1));
                        it("should correctly remove listeners", {
                            ViewCompA.inst().isActive().should.be(false);
                            ViewCompA.inst().onAdded.size().should.be(0);
                            ViewCompA.inst().onRemoved.size().should.be(0);
                        });
                    });

                    describe("Then create Entities", {
                        beforeEach({
                            entities = [ for (i in 0...2) new Entity().add(new CompA(), new CompB(), new CompC()) ];
                        });
                        it("should have correct result", {
                            BuildResult.value.should.be('+A>A+Ae+A>A+Ae');
                        });

                        describe("Then destroy Entities", {
                            beforeEach({
                                for (e in entities) e.destroy();
                            });
                            it("should have correct result", {
                                BuildResult.value.should.be('+A>A+Ae+A>A+Ae<A-A-Ae<A-A-Ae');
                            });
                        });
                    });

                    describe("Then add a second System with equal View to the flow", {
                        var s2 = new SystemAddRemMeta2();

                        beforeEach(Workflow.addSystem(s2));
                        it("should correctly add listeners", {
                            ViewCompA.inst().isActive().should.be(true);
                            ViewCompA.inst().onAdded.size().should.be(4);
                            ViewCompA.inst().onRemoved.size().should.be(4);
                        });

                        describe("Then remove a second System with equal View from the flow", {
                            beforeEach(Workflow.removeSystem(s2));
                            it("should correctly remove listeners", {
                                ViewCompA.inst().isActive().should.be(true);
                                ViewCompA.inst().onAdded.size().should.be(3);
                                ViewCompA.inst().onRemoved.size().should.be(3);
                            });

                            describe("Then remove a first System from the flow", {
                                beforeEach(Workflow.removeSystem(s1));
                                it("should correctly remove listeners", {
                                    ViewCompA.inst().isActive().should.be(false);
                                    ViewCompA.inst().onAdded.size().should.be(0);
                                    ViewCompA.inst().onRemoved.size().should.be(0);
                                });
                            });

                            describe("Then create Entities", {
                                beforeEach({
                                    entities = [ for (i in 0...2) new Entity().add(new CompA(), new CompB(), new CompC()) ];
                                });
                                it("should have correct result", {
                                    BuildResult.value.should.be('+A>A+Ae+A>A+Ae');
                                });

                                describe("Then destroy Entities", {
                                    beforeEach({
                                        for (e in entities) e.destroy();
                                    });
                                    it("should have correct result", {
                                        BuildResult.value.should.be('+A>A+Ae+A>A+Ae<A-A-Ae<A-A-Ae');
                                    });
                                });
                            });
                        });

                        describe("Then remove a first System from the flow", {
                            beforeEach(Workflow.removeSystem(s1));
                            it("should correctly remove listeners", {
                                ViewCompA.inst().isActive().should.be(true);
                                ViewCompA.inst().onAdded.size().should.be(1);
                                ViewCompA.inst().onRemoved.size().should.be(1);
                            });

                            describe("Then create Entities", {
                                beforeEach({
                                    entities = [ for (i in 0...2) new Entity().add(new CompA(), new CompB(), new CompC()) ];
                                });
                                it("should have correct result", {
                                    BuildResult.value.should.be('!!');
                                });

                                describe("Then destroy Entities", {
                                    beforeEach({
                                        for (e in entities) e.destroy();
                                    });
                                    it("should have correct result", {
                                        BuildResult.value.should.be('!!##');
                                    });
                                });
                            });
                        });

                        describe("Then create Entities", {
                            beforeEach({
                                entities = [ for (i in 0...2) new Entity().add(new CompA(), new CompB(), new CompC()) ];
                            });
                            it("should have correct result", {
                                BuildResult.value.should.be('+A>A+Ae!+A>A+Ae!');
                            });

                            describe("Then destroy Entities", {
                                beforeEach({
                                    for (e in entities) e.destroy();
                                });
                                it("should have correct result", {
                                    BuildResult.value.should.be('+A>A+Ae!+A>A+Ae!<A-A-Ae#<A-A-Ae#');
                                });
                            });
                        });
                    });
                });
            });
        });
    }
}

abstract CompA(String) {
    public function new() this = 'A';
}

abstract CompB(String) {
    public function new() this = 'B';
}

abstract CompC(String) {
    public function new() this = 'C';
}

class SystemUpdateMeta extends echoes.System {
    @u function empty0() BuildResult.value += '[';
    @u function _f____(f:Float) BuildResult.value += '$f';
    @u function empty1() BuildResult.value += '_';
    @u function ___a__(a:CompA) BuildResult.value += '$a';
    @u function empty2() BuildResult.value += '_';
    @u function _f_a_(f:Float, a:CompA) BuildResult.value += '${f}${a}';
    @u function empty3() BuildResult.value += '_';
    @u function _fe___(f:Float, e:Entity) BuildResult.value += '${f}e';
    @u function empty4() BuildResult.value += '_';
    @u function _fea__(f:Float, e:Entity, a:CompA) BuildResult.value += '${f}e${a}';
    @u function _fe_b_(f:Float, e:Entity, b:CompB) BuildResult.value += '${f}e${b}';
    @u function _feab_(f:Float, e:Entity, a:CompA, b:CompB) BuildResult.value += '${f}e${a}${b}';
    @u function empty5() BuildResult.value += ']';
    override function onactivate() {
        BuildResult.value += '^';
    }
    override function ondeactivate() {
        BuildResult.value += '$';
    }
}

class SystemAddRemMeta extends echoes.System {
    @a function ad_a1(a:CompA) BuildResult.value += '+${a}';
    @a function ad_a2(a:CompA) BuildResult.value += '>${a}';
    @r function rm_a2(a:CompA) BuildResult.value += '<${a}';
    @r function rm_a1(a:CompA) BuildResult.value += '-${a}';
    @a function ad_ae(a:CompA, e:Entity) BuildResult.value += '+${a}e';
    @r function rm_ae(a:CompA, e:Entity) BuildResult.value += '-${a}e';
}

class SystemAddRemMeta2 extends echoes.System {
    @a function ad_a(a:CompA) BuildResult.value += '!';
    @r function rm_a(a:CompA) BuildResult.value += '#';
}

typedef ViewCompA = View<CompA>;

class BuildResult {
    public static var value = '';
}
