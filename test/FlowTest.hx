import echos.*;

using buddy.Should;

class FlowTest extends buddy.BuddySuite {
    public function new() {
        describe("Flow", {
            var x = new SystemX();
            var y = new SystemY();

            beforeEach({
                Workflow.reset();
            });

            describe("When add System X", {
                beforeEach({
                    Workflow.addSystem(x);
                });
                it("should be added", Workflow.systems.length.should.be(1));
                it("should be added", Workflow.hasSystem(x).should.be(true));
                it("should has correct count of views", Workflow.views.length.should.be(2));

                describe("When add System X again", {
                    beforeEach({
                        Workflow.addSystem(x);
                    });
                    it("should be added", Workflow.systems.length.should.be(1));
                    it("should be added", Workflow.hasSystem(x).should.be(true));
                    it("should has correct count of views", Workflow.views.length.should.be(2));
                });

                describe("When remove System X", {
                    beforeEach({
                        Workflow.removeSystem(x);
                    });
                    it("should be removed", Workflow.systems.length.should.be(0));
                    it("should be removed", Workflow.hasSystem(x).should.be(false));
                    it("should has correct count of views", Workflow.views.length.should.be(0));

                    describe("When remove System X again", {
                        beforeEach({
                            Workflow.removeSystem(x);
                        });
                        it("should be removed", Workflow.systems.length.should.be(0));
                        it("should be removed", Workflow.hasSystem(x).should.be(false));
                        it("should has correct count of views", Workflow.views.length.should.be(0));
                    });

                    describe("When add System X back", {
                        beforeEach({
                            Workflow.addSystem(x);
                        });
                        it("should be added", Workflow.systems.length.should.be(1));
                        it("should be added", Workflow.hasSystem(x).should.be(true));
                        it("should has correct count of views", Workflow.views.length.should.be(2));
                    });
                });

                describe("When add System Y", {
                    beforeEach({
                        Workflow.addSystem(y);
                    });
                    it("should be added", Workflow.systems.length.should.be(2));
                    it("should be added", Workflow.hasSystem(y).should.be(true));
                    it("should has correct count of views", Workflow.views.length.should.be(3));

                    describe("When remove System Y", {
                        beforeEach({
                            Workflow.removeSystem(y);
                        });
                        it("should be removed", Workflow.systems.length.should.be(1));
                        it("should be removed", Workflow.hasSystem(y).should.be(false));
                        it("should has correct count of views", Workflow.views.length.should.be(2));
                    });

                    describe("When remove System X", {
                        beforeEach({
                            Workflow.removeSystem(x);
                        });
                        it("should be removed", Workflow.systems.length.should.be(1));
                        it("should be removed", Workflow.hasSystem(x).should.be(false));
                        it("should has correct count of views", Workflow.views.length.should.be(2));
                    });

                    describe("When reset", {
                        beforeEach({
                            Workflow.reset();
                        });
                        it("should be removed", Workflow.systems.length.should.be(0));
                        it("should be removed", Workflow.hasSystem(x).should.be(false));
                        it("should be removed", Workflow.hasSystem(y).should.be(false));
                        it("should has correct count of views", Workflow.views.length.should.be(0));
                    });

                    describe("When use info", {
                        var str = "\\# \\( 2 \\) \\{ 3 \\} \\[ 0 \\| 0 \\]";
                        #if echos_profiling
                        str += " : \\d ms";
                        str += "\n    \\(FlowTest.SystemX\\) : \\d ms";
                        str += "\n    \\(FlowTest.SystemY\\) : \\d ms";
                        str += "\n    \\{FlowTest.X\\} \\[0\\]";
                        str += "\n    \\{FlowTest.X\\+FlowTest.Y\\} \\[0\\]";
                        str += "\n    \\{FlowTest.Y\\} \\[0\\]";
                        #end
                        beforeEach({
                            Workflow.update(0);
                        });
                        it("should has correct result", Workflow.info().should.match(new EReg(str, "")));
                    });
                });
            });

            describe("Using System List", {
                var sl:SystemList;

                beforeEach({
                    sl = new SystemList();
                });

                describe("Initially", {
                    it("should has correct count of systems", Workflow.systems.length.should.be(0));
                    it("should has system list", Workflow.hasSystem(sl).should.be(false));
                    it("should has correct count of views", Workflow.views.length.should.be(0));

                    describe("When add Systems to the System List", {
                        beforeEach({
                            sl.add(x);
                            sl.add(y);
                        });
                        it("should exists", {
                            sl.exists(x).should.be(true);
                            sl.exists(y).should.be(true);
                        });

                        describe("When remove Systems from the System List", {
                            beforeEach({
                                sl.remove(x);
                                sl.remove(y);
                            });
                            it("should exists", {
                                sl.exists(x).should.be(false);
                                sl.exists(y).should.be(false);
                            });
                        });

                        describe("When add System List", {
                            beforeEach({
                                Workflow.addSystem(sl);
                            });
                            it("should has correct count of systems", Workflow.systems.length.should.be(1));
                            it("should has system list", Workflow.hasSystem(sl).should.be(true));
                            it("should has correct count of views", Workflow.views.length.should.be(3));

                            describe("When remove System X from the System List", {
                                beforeEach({
                                    sl.remove(x);
                                });
                                it("should has correct count of systems", Workflow.systems.length.should.be(1));
                                it("should has system list", Workflow.hasSystem(sl).should.be(true));
                                it("should has correct count of views", Workflow.views.length.should.be(2));
                                it("should exists", {
                                    sl.exists(x).should.be(false);
                                    sl.exists(y).should.be(true);
                                });

                                describe("When add System X back", {
                                    beforeEach({
                                        sl.add(x);
                                    });
                                    it("should has correct count of systems", Workflow.systems.length.should.be(1));
                                    it("should has system list", Workflow.hasSystem(sl).should.be(true));
                                    it("should has correct count of views", Workflow.views.length.should.be(3));
                                    it("should exists", {
                                        sl.exists(x).should.be(true);
                                        sl.exists(y).should.be(true);
                                    });
                                });

                                describe("When remove System Y from the System List", {
                                    beforeEach({
                                        sl.remove(y);
                                    });
                                    it("should has correct count of systems", Workflow.systems.length.should.be(1));
                                    it("should has system list", Workflow.hasSystem(sl).should.be(true));
                                    it("should has correct count of views", Workflow.views.length.should.be(0));
                                    it("should exists", {
                                        sl.exists(x).should.be(false);
                                        sl.exists(y).should.be(false);
                                    });
                                });
                            });

                            describe("When remove System List", {
                                beforeEach({
                                    Workflow.removeSystem(sl);
                                });
                                it("should has correct count of systems", Workflow.systems.length.should.be(0));
                                it("should not has system list", Workflow.hasSystem(sl).should.be(false));
                                it("should has correct count of views", Workflow.views.length.should.be(0));
                            });

                            describe("When use info", {
                                var str = "\\# \\( 1 \\) \\{ 3 \\} \\[ 0 \\| 0 \\]";
                                #if echos_profiling
                                str += " : \\d ms";
                                str += "\n    \\(";
                                str += "\n        \\(FlowTest.SystemX\\) : \\d ms";
                                str += "\n        \\(FlowTest.SystemY\\) : \\d ms";
                                str += "\n    \\)";
                                str += "\n    \\{FlowTest.X\\} \\[0\\]";
                                str += "\n    \\{FlowTest.X\\+FlowTest.Y\\} \\[0\\]";
                                str += "\n    \\{FlowTest.Y\\} \\[0\\]";
                                #end
                                beforeEach({
                                    Workflow.update(0);
                                });
                                it("should has correct result", Workflow.info().should.match(new EReg(str, "")));
                            });
                        });

                        describe("When add System List to System List", {
                            var sl2:SystemList;

                            beforeEach({
                                sl2 = new SystemList();
                                sl2.add(sl);
                            });

                            it("should exists", sl2.exists(sl).should.be(true));

                            describe("When add System List", {
                                beforeEach({
                                    Workflow.addSystem(sl2);
                                });
                                it("should has correct count of systems", Workflow.systems.length.should.be(1));
                                it("should has system list", Workflow.hasSystem(sl2).should.be(true));
                                it("should has correct count of views", Workflow.views.length.should.be(3));

                                describe("When remove System List", {
                                    beforeEach({
                                        Workflow.removeSystem(sl2);
                                    });
                                    it("should has correct count of systems", Workflow.systems.length.should.be(0));
                                    it("should not has system list", Workflow.hasSystem(sl2).should.be(false));
                                    it("should has correct count of views", Workflow.views.length.should.be(0));
                                });

                                describe("When use info", {
                                    var str = "\\# \\( 1 \\) \\{ 3 \\} \\[ 0 \\| 0 \\]";
                                    #if echos_profiling
                                    str += " : \\d ms";
                                    str += "\n    \\(";
                                    str += "\n        \\(";
                                    str += "\n            \\(FlowTest.SystemX\\) : \\d ms";
                                    str += "\n            \\(FlowTest.SystemY\\) : \\d ms";
                                    str += "\n        \\)";
                                    str += "\n    \\)";
                                    str += "\n    \\{FlowTest.X\\} \\[0\\]";
                                    str += "\n    \\{FlowTest.X\\+FlowTest.Y\\} \\[0\\]";
                                    str += "\n    \\{FlowTest.Y\\} \\[0\\]";
                                    #end
                                    beforeEach({
                                        Workflow.update(0);
                                    });
                                    it("should has correct result", Workflow.info().should.match(new EReg(str, "")));
                                });
                            });
                        });
                    });

                    describe("When add System List", {
                        beforeEach({
                            Workflow.addSystem(sl);
                        });
                        it("should has correct count of systems", Workflow.systems.length.should.be(1));
                        it("should has system list", Workflow.hasSystem(sl).should.be(true));
                        it("should has correct count of views", Workflow.views.length.should.be(0));

                        describe("When add System X to the System List", {
                            beforeEach({
                                sl.add(x);
                            });
                            it("should has correct count of systems", Workflow.systems.length.should.be(1));
                            it("should has system list", Workflow.hasSystem(sl).should.be(true));
                            it("should has correct count of views", Workflow.views.length.should.be(2));

                            describe("When add System Y to the System List", {
                                beforeEach({
                                    sl.add(y);
                                });
                                it("should has correct count of systems", Workflow.systems.length.should.be(1));
                                it("should has system list", Workflow.hasSystem(sl).should.be(true));
                                it("should has correct count of views", Workflow.views.length.should.be(3));
                            });
                        });
                    });
                });
            });
        });
    }
}

class X {
    public function new() { };
}

class Y {
    public function new() { };
}

class SystemX extends echos.System {
    var x:View<X>;
    var xy:View<X, Y>;
}

class SystemY extends echos.System {
    @u inline function update(y:Y) { }
    @u inline function updatexy(x:X, y:Y, dt:Float) { }
}
