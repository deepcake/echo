import echoes.Entity;

using buddy.Should;

class EntityTest extends buddy.BuddySuite {
    public function new() {
        describe("Test Entity", {
            var e:Entity;
            var a:ComponentA;
            var b:ComponentB;

            beforeEach({
                echoes.Workflow.reset();
                a = new ComponentA(1);
                b = new ComponentB(1);
            });

            describe("When create Entity (immediate = true)", {
                beforeEach({
                    e = new Entity(true);
                });
                it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                it("should be activated", e.isActive().should.be(true));
                it("should be valid", e.isValid().should.be(true));

                describe("Then add a ComponentA", {
                    beforeEach({
                        e.add(a);
                    });
                    it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                    it("should be activated", e.isActive().should.be(true));
                    it("should be valid", e.isValid().should.be(true));
                    it("should have a ComponentA", e.exists(ComponentA).should.be(true));
                    it("should get a ComponentA", e.get(ComponentA).should.be(a));
                    it("should not have a ComponentB", e.exists(ComponentB).should.be(false));
                    it("should not get a ComponentB", e.get(ComponentB).should.be(null));

                    describe("Then add a ComponentB", {
                        beforeEach({
                            e.add(b);
                        });
                        it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                        it("should be activated", e.isActive().should.be(true));
                        it("should be valid", e.isValid().should.be(true));
                        it("should have a ComponentA", e.exists(ComponentA).should.be(true));
                        it("should get a ComponentA", e.get(ComponentA).should.be(a));
                        it("should have a ComponentB", e.exists(ComponentB).should.be(true));
                        it("should get a ComponentB", e.get(ComponentB).should.be(b));

                        describe("Then add a ComponentB again", {
                            var b2 = new ComponentB(2);
                            beforeEach({
                                e.add(b2);
                            });
                            it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                            it("should be activated", e.isActive().should.be(true));
                            it("should be valid", e.isValid().should.be(true));
                            it("should have a ComponentA", e.exists(ComponentA).should.be(true));
                            it("should get a ComponentA", e.get(ComponentA).should.be(a));
                            it("should have a ComponentB", e.exists(ComponentB).should.be(true));
                            it("should not get an old ComponentB", e.get(ComponentB).should.not.be(b));
                            it("should get a new ComponentB", e.get(ComponentB).should.be(b2));
                        });

                        describe("Then remove a ComponentA", {
                            beforeEach({
                                e.remove(ComponentA);
                            });
                            it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                            it("should be activated", e.isActive().should.be(true));
                            it("should be valid", e.isValid().should.be(true));
                            it("should not have a ComponentA", e.exists(ComponentA).should.be(false));
                            it("should not get a ComponentA", e.get(ComponentA).should.be(null));
                            it("should have a ComponentB", e.exists(ComponentB).should.be(true));
                            it("should get a ComponentB", e.get(ComponentB).should.be(b));

                            describe("Then remove a ComponentA again", {
                                beforeEach({
                                    e.remove(ComponentA);
                                });
                                it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                                it("should be activated", e.isActive().should.be(true));
                                it("should be valid", e.isValid().should.be(true));
                                it("should not have a ComponentA", e.exists(ComponentA).should.be(false));
                                it("should not get a ComponentA", e.get(ComponentA).should.be(null));
                                it("should have a ComponentB", e.exists(ComponentB).should.be(true));
                                it("should get a ComponentB", e.get(ComponentB).should.be(b));
                            });

                            describe("Then remove a ComponentB", {
                                beforeEach({
                                    e.remove(ComponentB);
                                });
                                it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                                it("should be activated", e.isActive().should.be(true));
                                it("should be valid", e.isValid().should.be(true));
                                it("should not have a ComponentA", e.exists(ComponentA).should.be(false));
                                it("should not get a ComponentA", e.get(ComponentA).should.be(null));
                                it("should not have a ComponentB", e.exists(ComponentB).should.be(false));
                                it("should not get a ComponentB", e.get(ComponentB).should.be(null));
                            });

                            describe("Then add a ComponentA back", {
                                beforeEach({
                                    e.add(a);
                                });
                                it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                                it("should be activated", e.isActive().should.be(true));
                                it("should be valid", e.isValid().should.be(true));
                                it("should have a ComponentA", e.exists(ComponentA).should.be(true));
                                it("should get a ComponentA", e.get(ComponentA).should.be(a));
                                it("should have a ComponentB", e.exists(ComponentB).should.be(true));
                                it("should get a ComponentB", e.get(ComponentB).should.be(b));
                            });
                        });

                        describe("Then remove all of components", {
                            beforeEach({
                                e.removeAll();
                            });
                            it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                            it("should be activated", e.isActive().should.be(true));
                            it("should be valid", e.isValid().should.be(true));
                            it("should not have a ComponentA", e.exists(ComponentA).should.be(false));
                            it("should not get a ComponentA", e.get(ComponentA).should.be(null));
                            it("should not have a ComponentB", e.exists(ComponentB).should.be(false));
                            it("should not get a ComponentB", e.get(ComponentB).should.be(null));

                            describe("Then remove all of components again", {
                                beforeEach({
                                    e.removeAll();
                                });
                                it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                                it("should be activated", e.isActive().should.be(true));
                                it("should be valid", e.isValid().should.be(true));
                                it("should not have a ComponentA", e.exists(ComponentA).should.be(false));
                                it("should not get a ComponentA", e.get(ComponentA).should.be(null));
                                it("should not have a ComponentB", e.exists(ComponentB).should.be(false));
                                it("should not get a ComponentB", e.get(ComponentB).should.be(null));
                            });

                            describe("Then add a ComponentB", {
                                beforeEach({
                                    e.add(b);
                                });
                                it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                                it("should be activated", e.isActive().should.be(true));
                                it("should be valid", e.isValid().should.be(true));
                                it("should not have a ComponentA", e.exists(ComponentA).should.be(false));
                                it("should not get a ComponentA", e.get(ComponentA).should.be(null));
                                it("should have a ComponentB", e.exists(ComponentB).should.be(true));
                                it("should get a ComponentB", e.get(ComponentB).should.be(b));
                            });
                        });

                        describe("Then activate Entity", {
                            beforeEach({
                                e.activate();
                            });
                            it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                            it("should be activated", e.isActive().should.be(true));
                            it("should be valid", e.isValid().should.be(true));
                            it("should have a ComponentA", e.exists(ComponentA).should.be(true));
                            it("should get a ComponentA", e.get(ComponentA).should.be(a));
                            it("should have a ComponentB", e.exists(ComponentB).should.be(true));
                            it("should get a ComponentB", e.get(ComponentB).should.be(b));

                            describe("Then activate Entity again", {
                                beforeEach({
                                    e.activate();
                                });
                                it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                                it("should be activated", e.isActive().should.be(true));
                                it("should be valid", e.isValid().should.be(true));
                                it("should have a ComponentA", e.exists(ComponentA).should.be(true));
                                it("should get a ComponentA", e.get(ComponentA).should.be(a));
                                it("should have a ComponentB", e.exists(ComponentB).should.be(true));
                                it("should get a ComponentB", e.get(ComponentB).should.be(b));
                            });
                        });

                        describe("Then deactivate Entity", {
                            beforeEach({
                                e.deactivate();
                            });
                            it("should not be added to the flow", echoes.Workflow.entities.length.should.be(0));
                            it("should not be activated", e.isActive().should.be(false));
                            it("should be valid", e.isValid().should.be(true));
                            it("should have a ComponentA", e.exists(ComponentA).should.be(true));
                            it("should get a ComponentA", e.get(ComponentA).should.be(a));
                            it("should have a ComponentB", e.exists(ComponentB).should.be(true));
                            it("should get a ComponentB", e.get(ComponentB).should.be(b));

                            describe("Then deactivate Entity again", {
                                beforeEach({
                                    e.deactivate();
                                });
                                it("should not be added to the flow", echoes.Workflow.entities.length.should.be(0));
                                it("should not be activated", e.isActive().should.be(false));
                                it("should be valid", e.isValid().should.be(true));
                                it("should have a ComponentA", e.exists(ComponentA).should.be(true));
                                it("should get a ComponentA", e.get(ComponentA).should.be(a));
                                it("should have a ComponentB", e.exists(ComponentB).should.be(true));
                                it("should get a ComponentB", e.get(ComponentB).should.be(b));
                            });

                            describe("Then activate Entity back", {
                                beforeEach({
                                    e.activate();
                                });
                                it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                                it("should be activated", e.isActive().should.be(true));
                                it("should be valid", e.isValid().should.be(true));
                                it("should have a ComponentA", e.exists(ComponentA).should.be(true));
                                it("should get a ComponentA", e.get(ComponentA).should.be(a));
                                it("should have a ComponentB", e.exists(ComponentB).should.be(true));
                                it("should get a ComponentB", e.get(ComponentB).should.be(b));
                            });
                        });

                        describe("Then destroy Entity", {
                            beforeEach({
                                e.destroy();
                            });
                            it("should not be added to the flow", echoes.Workflow.entities.length.should.be(0));
                            it("should not be activated", e.isActive().should.be(false));
                            it("should not be valid", e.isValid().should.be(false));
                            it("should not have a ComponentA", e.exists(ComponentA).should.be(false));
                            it("should not get a ComponentA", e.get(ComponentA).should.be(null));
                            it("should not have a ComponentB", e.exists(ComponentB).should.be(false));
                            it("should not get a ComponentB", e.get(ComponentB).should.be(null));

                            describe("Then destroy Entity again", {
                                beforeEach({
                                    e.destroy();
                                });
                                it("should not be added to the flow", echoes.Workflow.entities.length.should.be(0));
                                it("should not be activated", e.isActive().should.be(false));
                                it("should not be valid", e.isValid().should.be(false));
                                it("should not have a ComponentA", e.exists(ComponentA).should.be(false));
                                it("should not get a ComponentA", e.get(ComponentA).should.be(null));
                                it("should not have a ComponentB", e.exists(ComponentB).should.be(false));
                                it("should not get a ComponentB", e.get(ComponentB).should.be(null));
                            });

                            describe("Then create new Entity (reuse)", {
                                beforeEach({
                                    e = new Entity();
                                });
                                it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                                it("should be activated", e.isActive().should.be(true));
                                it("should be valid", e.isValid().should.be(true));
                                it("should not have a ComponentA", e.exists(ComponentA).should.be(false));
                                it("should not get a ComponentA", e.get(ComponentA).should.be(null));
                                it("should not have a ComponentB", e.exists(ComponentB).should.be(false));
                                it("should not get a ComponentB", e.get(ComponentB).should.be(null));
                            });
                        });

                        describe("Then create new Entity", {
                            beforeEach({
                                e = new Entity();
                            });
                            it("should be added to the flow", echoes.Workflow.entities.length.should.be(2));
                            it("should be activated", e.isActive().should.be(true));
                            it("should be valid", e.isValid().should.be(true));
                            it("should not have a ComponentA", e.exists(ComponentA).should.be(false));
                            it("should not get a ComponentA", e.get(ComponentA).should.be(null));
                            it("should not have a ComponentB", e.exists(ComponentB).should.be(false));
                            it("should not get a ComponentB", e.get(ComponentB).should.be(null));
                        });

                        describe("Then remove ComponentA and ComponentB at once", {
                            beforeEach({
                                e.remove(ComponentA, ComponentB);
                            });
                            it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                            it("should be activated", e.isActive().should.be(true));
                            it("should be valid", e.isValid().should.be(true));
                            it("should not have a ComponentA", e.exists(ComponentA).should.be(false));
                            it("should not get a ComponentA", e.get(ComponentA).should.be(null));
                            it("should not have a ComponentB", e.exists(ComponentB).should.be(false));
                            it("should not get a ComponentB", e.get(ComponentB).should.be(null));
                        });

                        describe("Then remove ComponentA and ComponentB chained", {
                            beforeEach({
                                e.remove(ComponentA).remove(ComponentB);
                            });
                            it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                            it("should be activated", e.isActive().should.be(true));
                            it("should be valid", e.isValid().should.be(true));
                            it("should not have a ComponentA", e.exists(ComponentA).should.be(false));
                            it("should not get a ComponentA", e.get(ComponentA).should.be(null));
                            it("should not have a ComponentB", e.exists(ComponentB).should.be(false));
                            it("should not get a ComponentB", e.get(ComponentB).should.be(null));
                        });
                    });
                });

                describe("Then add a ComponentA and ComponentB at once", {
                    beforeEach({
                        e.add(a, b);
                    });
                    it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                    it("should be activated", e.isActive().should.be(true));
                    it("should be valid", e.isValid().should.be(true));
                    it("should have a ComponentA", e.exists(ComponentA).should.be(true));
                    it("should get a ComponentA", e.get(ComponentA).should.be(a));
                    it("should have a ComponentB", e.exists(ComponentB).should.be(true));
                    it("should get a ComponentB", e.get(ComponentB).should.be(b));
                });

                describe("Then add a ComponentA and ComponentB chained", {
                    beforeEach({
                        e.add(a).add(b);
                    });
                    it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                    it("should be activated", e.isActive().should.be(true));
                    it("should be valid", e.isValid().should.be(true));
                    it("should have a ComponentA", e.exists(ComponentA).should.be(true));
                    it("should get a ComponentA", e.get(ComponentA).should.be(a));
                    it("should have a ComponentB", e.exists(ComponentB).should.be(true));
                    it("should get a ComponentB", e.get(ComponentB).should.be(b));
                });
            });

            describe("When create Entity (immediate = false)", {
                beforeEach({
                    e = new Entity(false);
                });
                it("should not be added to the flow", echoes.Workflow.entities.length.should.be(0));
                it("should not be activated", e.isActive().should.be(false));
                it("should be valid", e.isValid().should.be(true));
                it("should not have a ComponentA", e.exists(ComponentA).should.be(false));
                it("should not get a ComponentA", e.get(ComponentA).should.be(null));
                it("should not have a ComponentB", e.exists(ComponentB).should.be(false));
                it("should not get a ComponentB", e.get(ComponentB).should.be(null));
                it("should correctly printed", e.print().should.be('#$e'));

                describe("Then activate Entity", {
                    beforeEach({
                        e.activate();
                    });
                    it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                    it("should be activated", e.isActive().should.be(true));
                    it("should be valid", e.isValid().should.be(true));
                    it("should not have a ComponentA", e.exists(ComponentA).should.be(false));
                    it("should not get a ComponentA", e.get(ComponentA).should.be(null));
                    it("should not have a ComponentB", e.exists(ComponentB).should.be(false));
                    it("should not get a ComponentB", e.get(ComponentB).should.be(null));
                    it("should correctly printed", e.print().should.be('#$e'));
                });

                describe("Then add a ComponentA", {
                    beforeEach({
                        e.add(a);
                    });
                    it("should not be added to the flow", echoes.Workflow.entities.length.should.be(0));
                    it("should not be activated", e.isActive().should.be(false));
                    it("should be valid", e.isValid().should.be(true));
                    it("should have a ComponentA", e.exists(ComponentA).should.be(true));
                    it("should get a ComponentA", e.get(ComponentA).should.be(a));
                    it("should not have a ComponentB", e.exists(ComponentB).should.be(false));
                    it("should not get a ComponentB", e.get(ComponentB).should.be(null));
                    it("should correctly printed", e.print().should.be('#$e:EntityTest.ComponentA=1'));

                    describe("Then add a ComponentB", {
                        beforeEach({
                            e.add(b);
                        });
                        it("should not be added to the flow", echoes.Workflow.entities.length.should.be(0));
                        it("should not be activated", e.isActive().should.be(false));
                        it("should be valid", e.isValid().should.be(true));
                        it("should have a ComponentA", e.exists(ComponentA).should.be(true));
                        it("should get a ComponentA", e.get(ComponentA).should.be(a));
                        it("should have a ComponentB", e.exists(ComponentB).should.be(true));
                        it("should get a ComponentB", e.get(ComponentB).should.be(b));
                        it("should correctly printed", e.print().should.be('#$e:EntityTest.ComponentA=1,EntityTest.ComponentB=1'));

                        describe("Then remove a ComponentA", {
                            beforeEach({
                                e.remove(ComponentA);
                            });
                            it("should not be added to the flow", echoes.Workflow.entities.length.should.be(0));
                            it("should not be activated", e.isActive().should.be(false));
                            it("should be valid", e.isValid().should.be(true));
                            it("should not have a ComponentA", e.exists(ComponentA).should.be(false));
                            it("should not get a ComponentA", e.get(ComponentA).should.be(null));
                            it("should have a ComponentB", e.exists(ComponentB).should.be(true));
                            it("should get a ComponentB", e.get(ComponentB).should.be(b));
                            it("should correctly printed", e.print().should.be('#$e:EntityTest.ComponentB=1'));
                        });

                        describe("Then remove all of components", {
                            beforeEach({
                                e.removeAll();
                            });
                            it("should not be added to the flow", echoes.Workflow.entities.length.should.be(0));
                            it("should not be activated", e.isActive().should.be(false));
                            it("should be valid", e.isValid().should.be(true));
                            it("should not have a ComponentA", e.exists(ComponentA).should.be(false));
                            it("should not get a ComponentA", e.get(ComponentA).should.be(null));
                            it("should not have a ComponentB", e.exists(ComponentB).should.be(false));
                            it("should not get a ComponentB", e.get(ComponentB).should.be(null));
                            it("should correctly printed", e.print().should.be('#$e'));
                        });

                        describe("Then activate Entity", {
                            beforeEach({
                                e.activate();
                            });
                            it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                            it("should be activated", e.isActive().should.be(true));
                            it("should be valid", e.isValid().should.be(true));
                            it("should have a ComponentA", e.exists(ComponentA).should.be(true));
                            it("should get a ComponentA", e.get(ComponentA).should.be(a));
                            it("should have a ComponentB", e.exists(ComponentB).should.be(true));
                            it("should get a ComponentB", e.get(ComponentB).should.be(b));
                            it("should correctly printed", e.print().should.be('#$e:EntityTest.ComponentA=1,EntityTest.ComponentB=1'));
                        });

                        describe("Then deactivate Entity", {
                            beforeEach({
                                e.deactivate();
                            });
                            it("should not be added to the flow", echoes.Workflow.entities.length.should.be(0));
                            it("should not be activated", e.isActive().should.be(false));
                            it("should be valid", e.isValid().should.be(true));
                            it("should have a ComponentA", e.exists(ComponentA).should.be(true));
                            it("should get a ComponentA", e.get(ComponentA).should.be(a));
                            it("should have a ComponentB", e.exists(ComponentB).should.be(true));
                            it("should get a ComponentB", e.get(ComponentB).should.be(b));
                            it("should correctly printed", e.print().should.be('#$e:EntityTest.ComponentA=1,EntityTest.ComponentB=1'));
                        });

                        describe("Then destroy Entity", {
                            beforeEach({
                                e.destroy();
                            });
                            it("should not be added to the flow", echoes.Workflow.entities.length.should.be(0));
                            it("should not be activated", e.isActive().should.be(false));
                            it("should not be valid", e.isValid().should.be(false));
                            it("should not have a ComponentA", e.exists(ComponentA).should.be(false));
                            it("should not get a ComponentA", e.get(ComponentA).should.be(null));
                            it("should not have a ComponentB", e.exists(ComponentB).should.be(false));
                            it("should not get a ComponentB", e.get(ComponentB).should.be(null));
                            it("should correctly printed", e.print().should.be('#$e'));
                        });
                    });
                });
            });

            describe("When Entity is Cached", {
                beforeEach({
                    e = new Entity();
                    e.destroy();
                });
                it("should not be added to the flow", echoes.Workflow.entities.length.should.be(0));
                it("should not be activated", e.isActive().should.be(false));
                it("should not be valid", e.isValid().should.be(false));
                it("should not have a ComponentA", e.exists(ComponentA).should.be(false));
                it("should not get a ComponentA", e.get(ComponentA).should.be(null));

                describe("Then activate Entity", {
                    beforeEach({
                        e.activate();
                    });
                    it("should not be added to the flow", echoes.Workflow.entities.length.should.be(0));
                    it("should not be activated", e.isActive().should.be(false));
                    it("should not be valid", e.isValid().should.be(false));
                });

                describe("Then deactivate Entity", {
                    beforeEach({
                        e.deactivate();
                    });
                    it("should not be added to the flow", echoes.Workflow.entities.length.should.be(0));
                    it("should not be activated", e.isActive().should.be(false));
                    it("should not be valid", e.isValid().should.be(false));
                });

                describe("Then destroy Entity", {
                    beforeEach({
                        e.destroy();
                    });
                    it("should not be added to the flow", echoes.Workflow.entities.length.should.be(0));
                    it("should not be activated", e.isActive().should.be(false));
                    it("should not be valid", e.isValid().should.be(false));
                });

                describe("Then remove all of components", {
                    beforeEach({
                        e.removeAll();
                    });
                    it("should not be added to the flow", echoes.Workflow.entities.length.should.be(0));
                    it("should not be activated", e.isActive().should.be(false));
                    it("should not be valid", e.isValid().should.be(false));
                });
            });

            describe("When used last of the created 1000 entities", {
                var entities:Array<Entity>;
                var last:Entity;
                beforeEach({
                    entities = [ for (i in 0...1000) last = new Entity() ];
                });
                it("should be added to the flow", echoes.Workflow.entities.length.should.be(1000));
                it("last entity should not have a ComponentA", last.exists(ComponentA).should.be(false));
                it("last entity should not get a ComponentA", last.get(ComponentA).should.be(null));
                it("last entity should be activated", last.isActive().should.be(true));
                it("last entity should be valid", last.isValid().should.be(true));
                it("last entity should correctly printed", last.print().should.be('#$last'));
            });
        });
    }
}

class ComponentA {
    var val:Int;
    public function new(val) this.val = val;
    public function toString() return Std.string(val);
}

abstract ComponentB(ComponentA) {
    public function new(val) this = new ComponentA(val);
}
