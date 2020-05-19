import echoes.*;

using buddy.Should;

class SystemTest extends buddy.BuddySuite {
    public function new() {
        describe("Test System", {
            var x:SystemX;
            var y:SystemY;

            beforeEach({
                Workflow.reset();
                x = new SystemX();
                y = new SystemY();
            });

            describe("When create Systems X and Y", {

                it("x should not be active", x.isActive().should.be(false));
                it("y should not be active", y.isActive().should.be(false));
                it("should have correct count of systems", Workflow.systems.length.should.be(0));
                it("should have correct count of views", Workflow.views.length.should.be(0));

                describe("When add System X", {
                    beforeEach({
                        Workflow.addSystem(x);
                    });
                    it("x should be active", x.isActive().should.be(true));
                    it("y should not be active", y.isActive().should.be(false));
                    it("should have correct count of systems", Workflow.systems.length.should.be(1));
                    it("should have correct count of views", Workflow.views.length.should.be(2));
    
                    describe("Then add System X again", {
                        beforeEach({
                            Workflow.addSystem(x);
                        });
                        it("x should be active", x.isActive().should.be(true));
                        it("y should not be active", y.isActive().should.be(false));
                        it("should have correct count of systems", Workflow.systems.length.should.be(1));
                        it("should have correct count of views", Workflow.views.length.should.be(2));
                    });
    
                    describe("Then remove System X", {
                        beforeEach({
                            Workflow.removeSystem(x);
                        });
                        it("x should not be active", x.isActive().should.be(false));
                        it("y should not be active", y.isActive().should.be(false));
                        it("should have correct count of systems", Workflow.systems.length.should.be(0));
                        it("should have correct count of views", Workflow.views.length.should.be(0));
    
                        describe("Then remove System X again", {
                            beforeEach({
                                Workflow.removeSystem(x);
                            });
                            it("x should not be active", x.isActive().should.be(false));
                            it("y should not be active", y.isActive().should.be(false));
                            it("should have correct count of systems", Workflow.systems.length.should.be(0));
                            it("should have correct count of views", Workflow.views.length.should.be(0));
                        });
    
                        describe("Then add System X back", {
                            beforeEach({
                                Workflow.addSystem(x);
                            });
                            it("x should be active", x.isActive().should.be(true));
                            it("y should not be active", y.isActive().should.be(false));
                            it("should have correct count of systems", Workflow.systems.length.should.be(1));
                            it("should have correct count of views", Workflow.views.length.should.be(2));
                        });
                    });
    
                    describe("Then add System Y", {
                        beforeEach({
                            Workflow.addSystem(y);
                        });
                        it("x should be active", x.isActive().should.be(true));
                        it("y should be active", y.isActive().should.be(true));
                        it("should have correct count of systems", Workflow.systems.length.should.be(2));
                        it("should have correct count of views", Workflow.views.length.should.be(3));
    
                        describe("Then remove System Y", {
                            beforeEach({
                                Workflow.removeSystem(y);
                            });
                            it("x should be active", x.isActive().should.be(true));
                            it("y should not be active", y.isActive().should.be(false));
                            it("should have correct count of systems", Workflow.systems.length.should.be(1));
                            it("should have correct count of views", Workflow.views.length.should.be(2));
                        });
    
                        describe("Then remove System X", {
                            beforeEach({
                                Workflow.removeSystem(x);
                            });
                            it("x should not be active", x.isActive().should.be(false));
                            it("y should be active", y.isActive().should.be(true));
                            it("should have correct count of systems", Workflow.systems.length.should.be(1));
                            it("should have correct count of views", Workflow.views.length.should.be(2));
                        });
    
                        describe("Then reset", {
                            beforeEach({
                                Workflow.reset();
                            });
                            it("x should not be active", x.isActive().should.be(false));
                            it("y should not be active", y.isActive().should.be(false));
                            it("should have correct count of systems", Workflow.systems.length.should.be(0));
                            it("should have correct count of views", Workflow.views.length.should.be(0));
                        });
    
                        describe("Then info", {
                            var str = "\\# \\( 2 \\) \\{ 3 \\} \\[ 0 \\| 0 \\]";
                            #if echoes_profiling
                            str += " : \\d ms";
                            str += "\n    \\(SystemTest.SystemX\\) : \\d ms";
                            str += "\n    \\(SystemTest.SystemY\\) : \\d ms";
                            str += "\n    \\{SystemTest.X\\} \\[0\\]";
                            str += "\n    \\{SystemTest.X\\+SystemTest.Y\\} \\[0\\]";
                            str += "\n    \\{SystemTest.Y\\} \\[0\\]";
                            #end
                            beforeEach({
                                Workflow.update(0);
                            });
                            it("should have correct result", Workflow.info().should.match(new EReg(str, "")));
                        });
                    });
                });
            });

            describe("When create SystemList", {
                var sl:SystemList;

                beforeEach({
                    sl = new SystemList();
                });

                it("x and y should not exists", {
                    sl.exists(x).should.be(false);
                    sl.exists(y).should.be(false);
                });

                it("x should not be active", x.isActive().should.be(false));
                it("y should not be active", y.isActive().should.be(false));
                it("should not be active", sl.isActive().should.be(false));
                it("should have correct count of systems", Workflow.systems.length.should.be(0));
                it("should have correct count of views", Workflow.views.length.should.be(0));

                describe("Then add Systems X and Y to the SystemList", {
                    beforeEach({
                        sl.add(x);
                        sl.add(y);
                    });
                    it("x and y should exists", {
                        sl.exists(x).should.be(true);
                        sl.exists(y).should.be(true);
                    });
                    it("x should not be active", x.isActive().should.be(false));
                    it("y should not be active", y.isActive().should.be(false));
                    it("should not be active", sl.isActive().should.be(false));

                    describe("Then remove Systems X and Y from the SystemList", {
                        beforeEach({
                            sl.remove(x);
                            sl.remove(y);
                        });
                        it("x and y should not exists", {
                            sl.exists(x).should.be(false);
                            sl.exists(y).should.be(false);
                        });
                        it("x should not be active", x.isActive().should.be(false));
                        it("y should not be active", y.isActive().should.be(false));
                        it("should not be active", sl.isActive().should.be(false));
                    });

                    describe("Then add SystemList to the flow", {
                        beforeEach({
                            Workflow.addSystem(sl);
                        });
                        it("x should be active", x.isActive().should.be(true));
                        it("y should be active", y.isActive().should.be(true));
                        it("should be active", sl.isActive().should.be(true));
                        it("should have correct count of systems", Workflow.systems.length.should.be(1));
                        it("should have correct count of views", Workflow.views.length.should.be(3));

                        describe("Then remove System X from the SystemList", {
                            beforeEach({
                                sl.remove(x);
                            });
                            it("x should not exists", sl.exists(x).should.be(false));
                            it("y should exists", sl.exists(y).should.be(true));
                            it("x should not be active", x.isActive().should.be(false));
                            it("y should be active", y.isActive().should.be(true));
                            it("should be active", sl.isActive().should.be(true));
                            it("should have correct count of systems", Workflow.systems.length.should.be(1));
                            it("should have correct count of views", Workflow.views.length.should.be(2));

                            describe("Then add System X back", {
                                beforeEach({
                                    sl.add(x);
                                });
                                it("x and y should exists", {
                                    sl.exists(x).should.be(true);
                                    sl.exists(y).should.be(true);
                                });
                                it("x should be active", x.isActive().should.be(true));
                                it("y should be active", y.isActive().should.be(true));
                                it("should be active", sl.isActive().should.be(true));
                                it("should have correct count of systems", Workflow.systems.length.should.be(1));
                                it("should have correct count of views", Workflow.views.length.should.be(3));
                            });

                            describe("Then remove System Y from the SystemList", {
                                beforeEach({
                                    sl.remove(y);
                                });
                                it("x and y should not exists", {
                                    sl.exists(x).should.be(false);
                                    sl.exists(y).should.be(false);
                                });
                                it("x should not be active", x.isActive().should.be(false));
                                it("y should not be active", y.isActive().should.be(false));
                                it("should be active", sl.isActive().should.be(true));
                                it("should have correct count of systems", Workflow.systems.length.should.be(1));
                                it("should have correct count of views", Workflow.views.length.should.be(0));
                            });
                        });

                        describe("Then remove SystemList from the flow", {
                            beforeEach({
                                Workflow.removeSystem(sl);
                            });
                            it("x and y should exists", {
                                sl.exists(x).should.be(true);
                                sl.exists(y).should.be(true);
                            });
                            it("x should not be active", x.isActive().should.be(false));
                            it("y should not be active", y.isActive().should.be(false));
                            it("should not be active", sl.isActive().should.be(false));
                            it("should have correct count of systems", Workflow.systems.length.should.be(0));
                            it("should have correct count of views", Workflow.views.length.should.be(0));
                        });

                        describe("Then info", {
                            var str = "\\# \\( 1 \\) \\{ 3 \\} \\[ 0 \\| 0 \\]";
                            #if echoes_profiling
                            str += " : \\d ms";
                            str += "\n    \\(";
                            str += "\n        \\(SystemTest.SystemX\\) : \\d ms";
                            str += "\n        \\(SystemTest.SystemY\\) : \\d ms";
                            str += "\n    \\)";
                            str += "\n    \\{SystemTest.X\\} \\[0\\]";
                            str += "\n    \\{SystemTest.X\\+SystemTest.Y\\} \\[0\\]";
                            str += "\n    \\{SystemTest.Y\\} \\[0\\]";
                            #end
                            beforeEach({
                                Workflow.update(0);
                            });
                            it("should have correct result", Workflow.info().should.match(new EReg(str, "")));
                        });
                    });

                    describe("Then add SystemList to SystemList", {
                        var sl2:SystemList;

                        beforeEach({
                            sl2 = new SystemList();
                            sl2.add(sl);
                        });

                        it("should exists", sl2.exists(sl).should.be(true));
                        it("x should not be active", x.isActive().should.be(false));
                        it("y should not be active", y.isActive().should.be(false));
                        it("should not be active", sl2.isActive().should.be(false));

                        describe("Then add SystemList to the flow", {
                            beforeEach({
                                Workflow.addSystem(sl2);
                            });
                            it("x should be active", x.isActive().should.be(true));
                            it("y should be active", y.isActive().should.be(true));
                            it("should be active", sl2.isActive().should.be(true));
                            it("should have correct count of systems", Workflow.systems.length.should.be(1));
                            it("should have correct count of views", Workflow.views.length.should.be(3));

                            describe("Then remove SystemList from the flow", {
                                beforeEach({
                                    Workflow.removeSystem(sl2);
                                });
                                it("x should not be active", x.isActive().should.be(false));
                                it("y should not be active", y.isActive().should.be(false));
                                it("should not be active", sl2.isActive().should.be(false));
                                it("should have correct count of systems", Workflow.systems.length.should.be(0));
                                it("should have correct count of views", Workflow.views.length.should.be(0));
                            });

                            describe("Then info", {
                                var str = "\\# \\( 1 \\) \\{ 3 \\} \\[ 0 \\| 0 \\]";
                                #if echoes_profiling
                                str += " : \\d ms";
                                str += "\n    \\(";
                                str += "\n        \\(";
                                str += "\n            \\(SystemTest.SystemX\\) : \\d ms";
                                str += "\n            \\(SystemTest.SystemY\\) : \\d ms";
                                str += "\n        \\)";
                                str += "\n    \\)";
                                str += "\n    \\{SystemTest.X\\} \\[0\\]";
                                str += "\n    \\{SystemTest.X\\+SystemTest.Y\\} \\[0\\]";
                                str += "\n    \\{SystemTest.Y\\} \\[0\\]";
                                #end
                                beforeEach({
                                    Workflow.update(0);
                                });
                                it("should have correct result", Workflow.info().should.match(new EReg(str, "")));
                            });
                        });
                    });
                });

                describe("Then add SystemList to the flow", {
                    beforeEach({
                        Workflow.addSystem(sl);
                    });
                    it("x should not exists", sl.exists(x).should.be(false));
                    it("y should not exists", sl.exists(y).should.be(false));
                    it("x should not be active", x.isActive().should.be(false));
                    it("y should not be active", y.isActive().should.be(false));
                    it("should be active", sl.isActive().should.be(true));
                    it("should have correct count of systems", Workflow.systems.length.should.be(1));
                    it("should have correct count of views", Workflow.views.length.should.be(0));

                    describe("Then add System X to the SystemList", {
                        beforeEach({
                            sl.add(x);
                        });
                        it("x should exists", sl.exists(x).should.be(true));
                        it("y should not exists", sl.exists(y).should.be(false));
                        it("x should be active", x.isActive().should.be(true));
                        it("y should not be active", y.isActive().should.be(false));
                        it("should be active", sl.isActive().should.be(true));
                        it("should have correct count of systems", Workflow.systems.length.should.be(1));
                        it("should have correct count of views", Workflow.views.length.should.be(2));

                        describe("Then add System Y to the SystemList", {
                            beforeEach({
                                sl.add(y);
                            });
                            it("x should exists", sl.exists(x).should.be(true));
                            it("y should exists", sl.exists(y).should.be(true));
                            it("x should be active", x.isActive().should.be(true));
                            it("y should be active", y.isActive().should.be(true));
                            it("should be active", sl.isActive().should.be(true));
                            it("should have correct count of systems", Workflow.systems.length.should.be(1));
                            it("should have correct count of views", Workflow.views.length.should.be(3));
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

class SystemX extends echoes.System {
    var x:View<X>;
    var xy:View<X, Y>;
}

class SystemY extends echoes.System {
    @u inline function update(y:Y) { }
    @u inline function updatexy(x:X, y:Y, dt:Float) { }
}
