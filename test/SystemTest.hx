using buddy.Should;

import echos.View;
import echos.Workflow;
import echos.Entity;

class SystemTest extends buddy.BuddySuite {
    public function new() {
        describe("Building", {

            beforeEach({
                Workflow.dispose();
                BuildResult.value = '';
            });

            describe("Views", {

                describe("When View defined with same components but different ways", {
                    it("should be equals", {
                        DefineViewSystem.func.should.be(StandaloneAB.ab);
                        DefineViewSystem.funcReversed.should.be(StandaloneAB.ab);
                        DefineViewSystem.funcShort.should.be(StandaloneAB.ab);
                        DefineViewSystem.anon.should.be(StandaloneAB.ab);
                        DefineViewSystem.anonTypedef.should.be(StandaloneAB.ab);
                        DefineViewSystem.viewTypedef.should.be(StandaloneAB.ab);
                        DefineViewSystem.rest.should.be(StandaloneAB.ab);
                    });

                    describe("When add System to the flow", {
                        beforeEach(Workflow.addSystem(new DefineViewSystem()));
                        beforeEach(Workflow.addSystem(new StandaloneAB()));

                        it("should be added to the flow only single time", {
                            Workflow.views.length.should.be(1);
                        });
                    });
                });

            });

            describe("Using @update metas", {
                var updSys = new UpdateMetaGeneration();

                describe("When add System", {
                    beforeEach(Workflow.addSystem(updSys));
                    it("should has correct result", {
                        BuildResult.value.should.be('^');
                    });

                    describe("When add Entities", {
                        beforeEach({
                            for (i in 0...2) new Entity().add(new CompA(), new CompB(), new CompC());
                        });
                        it("should has correct result", {
                            BuildResult.value.should.be('^');
                        });

                        describe("When update", {
                            beforeEach(Workflow.update(0));
                            it("should has correct result", {
                                BuildResult.value.should.be('^_0_AA_0A0A_0e0e_0eA0eA_');
                            });

                            describe("When remove System", {
                                beforeEach(Workflow.removeSystem(updSys));
                                it("should has correct result", {
                                    BuildResult.value.should.be('^_0_AA_0A0A_0e0e_0eA0eA_$');
                                });

                                describe("When update", {
                                    beforeEach(Workflow.update(0));
                                    it("should has correct result", {
                                        BuildResult.value.should.be('^_0_AA_0A0A_0e0e_0eA0eA_$');
                                    });
                                });
                            });
                        });
                    });
                });
            });

            describe("Using @added and @removed metas", {
                var arSys = new AddedRemovedMetaGeneration();
                var entities:Array<Entity>;

                describe("When add System with already created Entities", {
                    beforeEach({
                        entities = [ for (i in 0...2) new Entity().add(new CompA(), new CompB(), new CompC()) ];
                    });

                    describe("When add System to the flow", {
                        beforeEach(Workflow.addSystem(arSys));
                        it("should has correct result", {
                            BuildResult.value.should.be('+A+A>A>A+Ae+Ae');
                        });

                        describe("When remove System from the flow", {
                            beforeEach(Workflow.removeSystem(arSys));
                            it("should has correct result", {
                                BuildResult.value.should.be('+A+A>A>A+Ae+Ae<A<A-A-A-Ae-Ae');
                            });
                        });
                    });
                });

                describe("When add System to the flow", {
                    beforeEach(Workflow.addSystem(arSys));
                    it("should correctly add listeners", {
                        StandaloneA.a.onAdded.size().should.be(3);
                        StandaloneA.a.onRemoved.size().should.be(3);
                    });

                    describe("When create Entities", {
                        beforeEach({
                            entities = [ for (i in 0...2) new Entity().add(new CompA(), new CompB(), new CompC()) ];
                        });
                        it("should has correct result", {
                            BuildResult.value.should.be('+A>A+Ae+A>A+Ae');
                        });

                        describe("When destroy Entities", {
                            beforeEach({
                                for (e in entities) e.destroy();
                            });
                            it("should has correct result", {
                                BuildResult.value.should.be('+A>A+Ae+A>A+Ae<A-A-Ae<A-A-Ae');
                            });
                        });
                    });

                    describe("When remove System from the flow", {
                        beforeEach(Workflow.removeSystem(arSys));
                        it("should correctly remove listeners", {
                            StandaloneA.a.onAdded.size().should.be(0);
                            StandaloneA.a.onRemoved.size().should.be(0);
                        });
                    });

                    describe("When add a second System with equal View", {
                        var araSys = new AddedRemovedAdditionalMetaGeneration();

                        beforeEach(Workflow.addSystem(araSys));
                        it("should correctly add listeners", {
                            StandaloneA.a.onAdded.size().should.be(4);
                            StandaloneA.a.onRemoved.size().should.be(4);
                        });

                        describe("When create Entities", {
                            beforeEach({
                                entities = [ for (i in 0...2) new Entity().add(new CompA(), new CompB(), new CompC()) ];
                            });
                            it("should has correct result", {
                                BuildResult.value.should.be('+A>A+Ae!+A>A+Ae!');
                            });

                            describe("When destroy Entities", {
                                beforeEach({
                                    for (e in entities) e.destroy();
                                });
                                it("should has correct result", {
                                    BuildResult.value.should.be('+A>A+Ae!+A>A+Ae!<A-A-Ae#<A-A-Ae#');
                                });
                            });
                        });

                        describe("When remove a second System with equal View", {
                            beforeEach(Workflow.removeSystem(araSys));
                            it("should correctly remove listeners", {
                                StandaloneA.a.onAdded.size().should.be(3);
                                StandaloneA.a.onRemoved.size().should.be(3);
                            });

                            describe("When create Entities", {
                                beforeEach({
                                    entities = [ for (i in 0...2) new Entity().add(new CompA(), new CompB(), new CompC()) ];
                                });
                                it("should has correct result", {
                                    BuildResult.value.should.be('+A>A+Ae+A>A+Ae');
                                });

                                describe("When destroy Entities", {
                                    beforeEach({
                                        for (e in entities) e.destroy();
                                    });
                                    it("should has correct result", {
                                        BuildResult.value.should.be('+A>A+Ae+A>A+Ae<A-A-Ae<A-A-Ae');
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

typedef ParamTypedef = { a:CompA, b:CompB };

typedef ViewTypedef = View<{ a:CompA, b:CompB }>;

class DefineViewSystem extends echos.System {

    public static var func:View<CompA->CompB->Void>;

    public static var funcReversed:View<CompB->CompA->Void>;

    public static var funcShort:View<CompA->CompB>;

    public static var anon:View<{ a:CompA, b:CompB }>;

    public static var anonTypedef:View<ParamTypedef>;

    public static var viewTypedef:ViewTypedef;

    public static var rest:View<CompA, CompB>;

    @u function ab(a:CompA, b:CompB) { }

    @u function ba(b:CompB, a:CompA) { }

    @u function cd(c:CompB, d:CompA) { }

    @u function fab(f:Float, a:CompA, b:CompB) { }

    @u function eab(e:Entity, a:CompA, b:CompB) { }

    @u function iab(i:Int, a:CompA, b:CompB) { }

    @u function feab(f:Float, e:Entity, a:CompA, b:CompB) { }

}

class UpdateMetaGeneration extends echos.System {
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

class AddedRemovedMetaGeneration extends echos.System {
    @a function ad_a1(a:CompA) BuildResult.value += '+${a}';
    @a function ad_a2(a:CompA) BuildResult.value += '>${a}';
    @r function rm_a2(a:CompA) BuildResult.value += '<${a}';
    @r function rm_a1(a:CompA) BuildResult.value += '-${a}';
    @a function ad_ae(a:CompA, e:Entity) BuildResult.value += '+${a}e';
    @r function rm_ae(a:CompA, e:Entity) BuildResult.value += '-${a}e';
}

class AddedRemovedAdditionalMetaGeneration extends echos.System {
    @a function ad_a(a:CompA) BuildResult.value += '!';
    @r function rm_a(a:CompA) BuildResult.value += '#';
}

class StandaloneA extends echos.System {
    public static var a:View<CompA>;
}

class StandaloneAB extends echos.System {
    public static var ab:View<CompA, CompB>;
}

class BuildResult {
    public static var value = '';
}
