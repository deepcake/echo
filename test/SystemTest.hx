using buddy.Should;

import echoes.View;
import echoes.Workflow;
import echoes.Entity;

class SystemTest extends buddy.BuddySuite {
    public function new() {
        describe("System", {

            beforeEach({
                Workflow.reset();
                BuildResult.value = '';
            });

            describe("Using @update metas", {
                var updSys = new UpdateMetaGeneration();

                describe("When add System", {
                    beforeEach(Workflow.addSystem(updSys));
                    it("should have correct result", {
                        BuildResult.value.should.be('^');
                    });

                    describe("When add Entities", {
                        beforeEach({
                            for (i in 0...2) new Entity().add(new CompA(), new CompB(), new CompC());
                        });
                        it("should have correct result", {
                            BuildResult.value.should.be('^');
                        });

                        describe("When update", {
                            beforeEach(Workflow.update(0));
                            it("should have correct result", {
                                BuildResult.value.should.be('^_0_AA_0A0A_0e0e_0eA0eA_');
                            });

                            describe("When remove System", {
                                beforeEach(Workflow.removeSystem(updSys));
                                it("should have correct result", {
                                    BuildResult.value.should.be('^_0_AA_0A0A_0e0e_0eA0eA_$');
                                });

                                describe("When update", {
                                    beforeEach(Workflow.update(0));
                                    it("should have correct result", {
                                        BuildResult.value.should.be('^_0_AA_0A0A_0e0e_0eA0eA_$');
                                    });
                                });
                            });
                        });
                    });
                });
            });

            describe("Using @added and @removed metas", {
                var sys1 = new AddedRemovedMetaGeneration();
                var entities:Array<Entity>;

                describe("When add System with already created Entities", {
                    beforeEach({
                        entities = [ for (i in 0...2) new Entity().add(new CompA(), new CompB(), new CompC()) ];
                    });

                    describe("When add System to the flow", {
                        beforeEach(Workflow.addSystem(sys1));
                        it("should have correct result", {
                            BuildResult.value.should.be('+A+A>A>A+Ae+Ae');
                        });

                        describe("When remove System from the flow", {
                            beforeEach(Workflow.removeSystem(sys1));
                            it("should have correct result", {
                                BuildResult.value.should.be('+A+A>A>A+Ae+Ae<A-A-Ae<A-A-Ae');
                            });
                        });
                    });
                });

                describe("When add a first System", {
                    beforeEach(Workflow.addSystem(sys1));
                    it("should correctly add listeners", {
                        StandaloneA.a.onAdded.size().should.be(3);
                        StandaloneA.a.onRemoved.size().should.be(3);
                    });

                    describe("When create Entities", {
                        beforeEach({
                            entities = [ for (i in 0...2) new Entity().add(new CompA(), new CompB(), new CompC()) ];
                        });
                        it("should have correct result", {
                            BuildResult.value.should.be('+A>A+Ae+A>A+Ae');
                        });

                        describe("When destroy Entities", {
                            beforeEach({
                                for (e in entities) e.destroy();
                            });
                            it("should have correct result", {
                                BuildResult.value.should.be('+A>A+Ae+A>A+Ae<A-A-Ae<A-A-Ae');
                            });
                        });
                    });

                    describe("When remove a first System", {
                        beforeEach(Workflow.removeSystem(sys1));
                        it("should correctly remove listeners", {
                            StandaloneA.a.onAdded.size().should.be(0);
                            StandaloneA.a.onRemoved.size().should.be(0);
                        });
                    });

                    describe("When add a second System with equal View", {
                        var sys2 = new AddedRemovedAdditionalMetaGeneration();

                        beforeEach(Workflow.addSystem(sys2));
                        it("should correctly add listeners", {
                            StandaloneA.a.onAdded.size().should.be(4);
                            StandaloneA.a.onRemoved.size().should.be(4);
                        });

                        describe("When create Entities", {
                            beforeEach({
                                entities = [ for (i in 0...2) new Entity().add(new CompA(), new CompB(), new CompC()) ];
                            });
                            it("should have correct result", {
                                BuildResult.value.should.be('+A>A+Ae!+A>A+Ae!');
                            });

                            describe("When destroy Entities", {
                                beforeEach({
                                    for (e in entities) e.destroy();
                                });
                                it("should have correct result", {
                                    BuildResult.value.should.be('+A>A+Ae!+A>A+Ae!<A-A-Ae#<A-A-Ae#');
                                });
                            });

                            describe("When remove a first System", {
                                beforeEach(Workflow.removeSystem(sys1));
                                it("should have correct result", {
                                    BuildResult.value.should.be('+A>A+Ae!+A>A+Ae!');
                                });

                                describe("When destroy Entities", {
                                    beforeEach({
                                        for (e in entities) e.destroy();
                                    });
                                    it("should have correct result", {
                                        BuildResult.value.should.be('+A>A+Ae!+A>A+Ae!##');
                                    });
                                });
                            });

                            describe("When remove a second System with equal View", {
                                beforeEach(Workflow.removeSystem(sys2));
                                it("should have correct result", {
                                    BuildResult.value.should.be('+A>A+Ae!+A>A+Ae!');
                                });

                                describe("When destroy Entities", {
                                    beforeEach({
                                        for (e in entities) e.destroy();
                                    });
                                    it("should have correct result", {
                                        BuildResult.value.should.be('+A>A+Ae!+A>A+Ae!<A-A-Ae<A-A-Ae');
                                    });
                                });
                            });

                            describe("When reset", {
                                beforeEach(Workflow.reset());
                                it("should have correct result", {
                                    BuildResult.value.should.be('+A>A+Ae!+A>A+Ae!<A-A-Ae#<A-A-Ae#');
                                });
                            });
                        });

                        describe("When remove a second System with equal View", {
                            beforeEach(Workflow.removeSystem(sys2));
                            it("should correctly remove listeners", {
                                StandaloneA.a.onAdded.size().should.be(3);
                                StandaloneA.a.onRemoved.size().should.be(3);
                            });

                            describe("When create Entities", {
                                beforeEach({
                                    entities = [ for (i in 0...2) new Entity().add(new CompA(), new CompB(), new CompC()) ];
                                });
                                it("should have correct result", {
                                    BuildResult.value.should.be('+A>A+Ae+A>A+Ae');
                                });

                                describe("When destroy Entities", {
                                    beforeEach({
                                        for (e in entities) e.destroy();
                                    });
                                    it("should have correct result", {
                                        BuildResult.value.should.be('+A>A+Ae+A>A+Ae<A-A-Ae<A-A-Ae');
                                    });
                                });
                            });
                        });

                        describe("When remove a first System", {
                            beforeEach(Workflow.removeSystem(sys1));
                            it("should correctly remove listeners", {
                                StandaloneA.a.onAdded.size().should.be(1);
                                StandaloneA.a.onRemoved.size().should.be(1);
                            });

                            describe("When create Entities", {
                                beforeEach({
                                    entities = [ for (i in 0...2) new Entity().add(new CompA(), new CompB(), new CompC()) ];
                                });
                                it("should have correct result", {
                                    BuildResult.value.should.be('!!');
                                });

                                describe("When destroy Entities", {
                                    beforeEach({
                                        for (e in entities) e.destroy();
                                    });
                                    it("should have correct result", {
                                        BuildResult.value.should.be('!!##');
                                    });
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

class UpdateMetaGeneration extends echoes.System {
    @u function empty0() BuildResult.value += '_';
    @u function _f(f:Float) BuildResult.value += '$f';
    @u function empty1() BuildResult.value += '_';
    @u function _a(a:CompA) BuildResult.value += '$a';
    @u function empty2() BuildResult.value += '_';
    @u function _fa(f:Float, a:CompA) BuildResult.value += '${f}${a}';
    @u function empty3() BuildResult.value += '_';
    @u function _fe(f:Float, e:Entity) BuildResult.value += '${f}e';
    @u function empty4() BuildResult.value += '_';
    @u function _fea(f:Float, e:Entity, a:CompA) BuildResult.value += '${f}e${a}';
    @u function empty5() BuildResult.value += '_';
    override function onactivate() {
        BuildResult.value += '^';
    }
    override function ondeactivate() {
        BuildResult.value += '$';
    }
}

class AddedRemovedMetaGeneration extends echoes.System {
    @a function ad_a1(a:CompA) BuildResult.value += '+${a}';
    @a function ad_a2(a:CompA) BuildResult.value += '>${a}';
    @r function rm_a2(a:CompA) BuildResult.value += '<${a}';
    @r function rm_a1(a:CompA) BuildResult.value += '-${a}';
    @a function ad_ae(a:CompA, e:Entity) BuildResult.value += '+${a}e';
    @r function rm_ae(a:CompA, e:Entity) BuildResult.value += '-${a}e';
}

class AddedRemovedAdditionalMetaGeneration extends echoes.System {
    @a function ad_a(a:CompA) BuildResult.value += '!';
    @r function rm_a(a:CompA) BuildResult.value += '#';
}

class StandaloneA extends echoes.System {
    public static var a:View<CompA>;
}

class BuildResult {
    public static var value = '';
}
