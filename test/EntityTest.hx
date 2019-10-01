import echoes.Entity;

using buddy.Should;

class EntityTest extends buddy.BuddySuite {
    public function new() {
        describe("Entity", {
            var e:Entity;
            var a:ComponentA;
            var b:ComponentB;

            beforeEach({
                echoes.Workflow.reset();
                a = new ComponentA(1);
                b = new ComponentB(2);
            });

            describe("When create Entity (immediate = true)", {
                beforeEach({
                    e = new Entity(true);
                });
                it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                it("should be activated", e.isActive().should.be(true));
                it("should be valid", e.isValid().should.be(true));

                describe("When add a ComponentA", {
                    beforeEach({
                        e.add(a);
                    });
                    it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                    it("should be activated", e.isActive().should.be(true));
                    it("should be valid", e.isValid().should.be(true));
                    it("should has a ComponentA", e.exists(ComponentA).should.be(true));
                    it("should get a ComponentA", e.get(ComponentA).should.be(a));
                    it("should not has a ComponentB", e.exists(ComponentB).should.be(false));
                    it("should not get a ComponentB", e.get(ComponentB).should.be(null));

                    describe("When add a ComponentB", {
                        beforeEach({
                            e.add(b);
                        });
                        it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                        it("should be activated", e.isActive().should.be(true));
                        it("should be valid", e.isValid().should.be(true));
                        it("should has a ComponentA", e.exists(ComponentA).should.be(true));
                        it("should get a ComponentA", e.get(ComponentA).should.be(a));
                        it("should has a ComponentB", e.exists(ComponentB).should.be(true));
                        it("should get a ComponentB", e.get(ComponentB).should.be(b));

                        describe("When add a new ComponentB", {
                            var b2 = new ComponentB(2);
                            beforeEach({
                                e.add(b2);
                            });
                            it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                            it("should be activated", e.isActive().should.be(true));
                            it("should be valid", e.isValid().should.be(true));
                            it("should has a ComponentA", e.exists(ComponentA).should.be(true));
                            it("should get a ComponentA", e.get(ComponentA).should.be(a));
                            it("should has a ComponentB", e.exists(ComponentB).should.be(true));
                            it("should not get an old ComponentB", e.get(ComponentB).should.not.be(b));
                            it("should get a new ComponentB", e.get(ComponentB).should.be(b2));
                        });

                        describe("When remove a ComponentA", {
                            beforeEach({
                                e.remove(ComponentA);
                            });
                            it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                            it("should be activated", e.isActive().should.be(true));
                            it("should be valid", e.isValid().should.be(true));
                            it("should not has a ComponentA", e.exists(ComponentA).should.be(false));
                            it("should not get a ComponentA", e.get(ComponentA).should.be(null));
                            it("should has a ComponentB", e.exists(ComponentB).should.be(true));
                            it("should get a ComponentB", e.get(ComponentB).should.be(b));

                            describe("When remove a ComponentA again", {
                                beforeEach({
                                    e.remove(ComponentA);
                                });
                                it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                                it("should be activated", e.isActive().should.be(true));
                                it("should be valid", e.isValid().should.be(true));
                                it("should not has a ComponentA", e.exists(ComponentA).should.be(false));
                                it("should not get a ComponentA", e.get(ComponentA).should.be(null));
                                it("should has a ComponentB", e.exists(ComponentB).should.be(true));
                                it("should get a ComponentB", e.get(ComponentB).should.be(b));
                            });

                            describe("When remove a ComponentB", {
                                beforeEach({
                                    e.remove(ComponentB);
                                });
                                it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                                it("should be activated", e.isActive().should.be(true));
                                it("should be valid", e.isValid().should.be(true));
                                it("should not has a ComponentA", e.exists(ComponentA).should.be(false));
                                it("should not get a ComponentA", e.get(ComponentA).should.be(null));
                                it("should not has a ComponentB", e.exists(ComponentB).should.be(false));
                                it("should not get a ComponentB", e.get(ComponentB).should.be(null));
                            });

                            describe("When add a ComponentA back", {
                                beforeEach({
                                    e.add(a);
                                });
                                it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                                it("should be activated", e.isActive().should.be(true));
                                it("should be valid", e.isValid().should.be(true));
                                it("should has a ComponentA", e.exists(ComponentA).should.be(true));
                                it("should get a ComponentA", e.get(ComponentA).should.be(a));
                                it("should has a ComponentB", e.exists(ComponentB).should.be(true));
                                it("should get a ComponentB", e.get(ComponentB).should.be(b));
                            });
                        });

                        describe("When remove all of components", {
                            beforeEach({
                                e.removeAll();
                            });
                            it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                            it("should be activated", e.isActive().should.be(true));
                            it("should be valid", e.isValid().should.be(true));
                            it("should not has a ComponentA", e.exists(ComponentA).should.be(false));
                            it("should not get a ComponentA", e.get(ComponentA).should.be(null));
                            it("should not has a ComponentB", e.exists(ComponentB).should.be(false));
                            it("should not get a ComponentB", e.get(ComponentB).should.be(null));

                            describe("When remove all of components again", {
                                beforeEach({
                                    e.removeAll();
                                });
                                it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                                it("should be activated", e.isActive().should.be(true));
                                it("should be valid", e.isValid().should.be(true));
                                it("should not has a ComponentA", e.exists(ComponentA).should.be(false));
                                it("should not get a ComponentA", e.get(ComponentA).should.be(null));
                                it("should not has a ComponentB", e.exists(ComponentB).should.be(false));
                                it("should not get a ComponentB", e.get(ComponentB).should.be(null));
                            });
                        });

                        describe("When activate Entity", {
                            beforeEach({
                                e.activate();
                            });
                            it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                            it("should be activated", e.isActive().should.be(true));
                            it("should be valid", e.isValid().should.be(true));
                            it("should has a ComponentA", e.exists(ComponentA).should.be(true));
                            it("should get a ComponentA", e.get(ComponentA).should.be(a));
                            it("should has a ComponentB", e.exists(ComponentB).should.be(true));
                            it("should get a ComponentB", e.get(ComponentB).should.be(b));

                            describe("When activate Entity again", {
                                beforeEach({
                                    e.activate();
                                });
                                it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                                it("should be activated", e.isActive().should.be(true));
                                it("should be valid", e.isValid().should.be(true));
                                it("should has a ComponentA", e.exists(ComponentA).should.be(true));
                                it("should get a ComponentA", e.get(ComponentA).should.be(a));
                                it("should has a ComponentB", e.exists(ComponentB).should.be(true));
                                it("should get a ComponentB", e.get(ComponentB).should.be(b));
                            });
                        });

                        describe("When deactivate Entity", {
                            beforeEach({
                                e.deactivate();
                            });
                            it("should not be added to the flow", echoes.Workflow.entities.length.should.be(0));
                            it("should not be activated", e.isActive().should.be(false));
                            it("should be valid", e.isValid().should.be(true));
                            it("should has a ComponentA", e.exists(ComponentA).should.be(true));
                            it("should get a ComponentA", e.get(ComponentA).should.be(a));
                            it("should has a ComponentB", e.exists(ComponentB).should.be(true));
                            it("should get a ComponentB", e.get(ComponentB).should.be(b));

                            describe("When deactivate Entity again", {
                                beforeEach({
                                    e.deactivate();
                                });
                                it("should not be added to the flow", echoes.Workflow.entities.length.should.be(0));
                                it("should not be activated", e.isActive().should.be(false));
                                it("should be valid", e.isValid().should.be(true));
                                it("should has a ComponentA", e.exists(ComponentA).should.be(true));
                                it("should get a ComponentA", e.get(ComponentA).should.be(a));
                                it("should has a ComponentB", e.exists(ComponentB).should.be(true));
                                it("should get a ComponentB", e.get(ComponentB).should.be(b));
                            });

                            describe("When activate Entity", {
                                beforeEach({
                                    e.activate();
                                });
                                it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                                it("should be activated", e.isActive().should.be(true));
                                it("should be valid", e.isValid().should.be(true));
                                it("should has a ComponentA", e.exists(ComponentA).should.be(true));
                                it("should get a ComponentA", e.get(ComponentA).should.be(a));
                                it("should has a ComponentB", e.exists(ComponentB).should.be(true));
                                it("should get a ComponentB", e.get(ComponentB).should.be(b));
                            });
                        });

                        describe("When destroy Entity", {
                            beforeEach({
                                e.destroy();
                            });
                            it("should not be added to the flow", echoes.Workflow.entities.length.should.be(0));
                            it("should not be activated", e.isActive().should.be(false));
                            it("should not be valid", e.isValid().should.be(false));
                            it("should not has a ComponentA", e.exists(ComponentA).should.be(false));
                            it("should not get a ComponentA", e.get(ComponentA).should.be(null));
                            it("should not has a ComponentB", e.exists(ComponentB).should.be(false));
                            it("should not get a ComponentB", e.get(ComponentB).should.be(null));

                            describe("When create new Entity (reuse)", {
                                beforeEach({
                                    e = new Entity();
                                });
                                it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                                it("should be activated", e.isActive().should.be(true));
                                it("should be valid", e.isValid().should.be(true));
                                it("should not has a ComponentA", e.exists(ComponentA).should.be(false));
                                it("should not get a ComponentA", e.get(ComponentA).should.be(null));
                                it("should not has a ComponentB", e.exists(ComponentB).should.be(false));
                                it("should not get a ComponentB", e.get(ComponentB).should.be(null));
                            });
                        });

                        describe("When create new Entity", {
                            beforeEach({
                                e = new Entity();
                            });
                            it("should be added to the flow", echoes.Workflow.entities.length.should.be(2));
                            it("should be activated", e.isActive().should.be(true));
                            it("should be valid", e.isValid().should.be(true));
                            it("should not has a ComponentA", e.exists(ComponentA).should.be(false));
                            it("should not get a ComponentA", e.get(ComponentA).should.be(null));
                            it("should not has a ComponentB", e.exists(ComponentB).should.be(false));
                            it("should not get a ComponentB", e.get(ComponentB).should.be(null));
                        });

                        describe("When remove ComponentA and ComponentB at once", {
                            beforeEach({
                                e.remove(ComponentA, ComponentB);
                            });
                            it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                            it("should be activated", e.isActive().should.be(true));
                            it("should be valid", e.isValid().should.be(true));
                            it("should not has a ComponentA", e.exists(ComponentA).should.be(false));
                            it("should not get a ComponentA", e.get(ComponentA).should.be(null));
                            it("should not has a ComponentB", e.exists(ComponentB).should.be(false));
                            it("should not get a ComponentB", e.get(ComponentB).should.be(null));
                        });

                        describe("When remove ComponentA and ComponentB chained", {
                            beforeEach({
                                e.remove(ComponentA).remove(ComponentB);
                            });
                            it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                            it("should be activated", e.isActive().should.be(true));
                            it("should be valid", e.isValid().should.be(true));
                            it("should not has a ComponentA", e.exists(ComponentA).should.be(false));
                            it("should not get a ComponentA", e.get(ComponentA).should.be(null));
                            it("should not has a ComponentB", e.exists(ComponentB).should.be(false));
                            it("should not get a ComponentB", e.get(ComponentB).should.be(null));
                        });
                    });
                });

                describe("When add a ComponentA and ComponentB at once", {
                    beforeEach({
                        e.add(a, b);
                    });
                    it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                    it("should be activated", e.isActive().should.be(true));
                    it("should be valid", e.isValid().should.be(true));
                    it("should has a ComponentA", e.exists(ComponentA).should.be(true));
                    it("should get a ComponentA", e.get(ComponentA).should.be(a));
                    it("should has a ComponentB", e.exists(ComponentB).should.be(true));
                    it("should get a ComponentB", e.get(ComponentB).should.be(b));
                });

                describe("When add a ComponentA and ComponentB chained", {
                    beforeEach({
                        e.add(a).add(b);
                    });
                    it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                    it("should be activated", e.isActive().should.be(true));
                    it("should be valid", e.isValid().should.be(true));
                    it("should has a ComponentA", e.exists(ComponentA).should.be(true));
                    it("should get a ComponentA", e.get(ComponentA).should.be(a));
                    it("should has a ComponentB", e.exists(ComponentB).should.be(true));
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
                it("should not has a ComponentA", e.exists(ComponentA).should.be(false));
                it("should not get a ComponentA", e.get(ComponentA).should.be(null));
                it("should not has a ComponentB", e.exists(ComponentB).should.be(false));
                it("should not get a ComponentB", e.get(ComponentB).should.be(null));

                describe("When add a ComponentA", {
                    beforeEach({
                        e.add(a);
                    });
                    it("should not be added to the flow", echoes.Workflow.entities.length.should.be(0));
                    it("should not be activated", e.isActive().should.be(false));
                    it("should be valid", e.isValid().should.be(true));
                    it("should has a ComponentA", e.exists(ComponentA).should.be(true));
                    it("should get a ComponentA", e.get(ComponentA).should.be(a));
                    it("should not has a ComponentB", e.exists(ComponentB).should.be(false));
                    it("should not get a ComponentB", e.get(ComponentB).should.be(null));

                    describe("When add a ComponentB", {
                        beforeEach({
                            e.add(b);
                        });
                        it("should not be added to the flow", echoes.Workflow.entities.length.should.be(0));
                        it("should not be activated", e.isActive().should.be(false));
                        it("should be valid", e.isValid().should.be(true));
                        it("should has a ComponentA", e.exists(ComponentA).should.be(true));
                        it("should get a ComponentA", e.get(ComponentA).should.be(a));
                        it("should has a ComponentB", e.exists(ComponentB).should.be(true));
                        it("should get a ComponentB", e.get(ComponentB).should.be(b));

                        describe("When activate Entity", {
                            beforeEach({
                                e.activate();
                            });
                            it("should be added to the flow", echoes.Workflow.entities.length.should.be(1));
                            it("should be activated", e.isActive().should.be(true));
                            it("should be valid", e.isValid().should.be(true));
                            it("should has a ComponentA", e.exists(ComponentA).should.be(true));
                            it("should get a ComponentA", e.get(ComponentA).should.be(a));
                            it("should has a ComponentB", e.exists(ComponentB).should.be(true));
                            it("should get a ComponentB", e.get(ComponentB).should.be(b));
                        });
                    });
                });
            });

            describe("When Entity is Invalid", {
                beforeEach({
                    e = Entity.INVALID;
                });
                it("should not be added to the flow", echoes.Workflow.entities.length.should.be(0));
                it("should not be activated", e.isActive().should.be(false));
                it("should not be valid", e.isValid().should.be(false));
                it("should not has a ComponentA", e.exists(ComponentA).should.be(false));
                it("should not get a ComponentA", e.get(ComponentA).should.be(null));

                describe("When activate Entity", {
                    beforeEach({
                        e.activate();
                    });
                    it("should not be added to the flow", echoes.Workflow.entities.length.should.be(0));
                    it("should not be activated", e.isActive().should.be(false));
                    it("should not be valid", e.isValid().should.be(false));
                });

                describe("When deactivate Entity", {
                    beforeEach({
                        e.deactivate();
                    });
                    it("should not be added to the flow", echoes.Workflow.entities.length.should.be(0));
                    it("should not be activated", e.isActive().should.be(false));
                    it("should not be valid", e.isValid().should.be(false));
                });

                describe("When destroy Entity", {
                    beforeEach({
                        e.destroy();
                    });
                    it("should not be added to the flow", echoes.Workflow.entities.length.should.be(0));
                    it("should not be activated", e.isActive().should.be(false));
                    it("should not be valid", e.isValid().should.be(false));
                });

                describe("When remove all of components", {
                    beforeEach({
                        e.removeAll();
                    });
                    it("should not be added to the flow", echoes.Workflow.entities.length.should.be(0));
                    it("should not be activated", e.isActive().should.be(false));
                    it("should not be valid", e.isValid().should.be(false));
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
                it("should not has a ComponentA", e.exists(ComponentA).should.be(false));
                it("should not get a ComponentA", e.get(ComponentA).should.be(null));

                describe("When activate Entity", {
                    beforeEach({
                        e.activate();
                    });
                    it("should not be added to the flow", echoes.Workflow.entities.length.should.be(0));
                    it("should not be activated", e.isActive().should.be(false));
                    it("should not be valid", e.isValid().should.be(false));
                });

                describe("When deactivate Entity", {
                    beforeEach({
                        e.deactivate();
                    });
                    it("should not be added to the flow", echoes.Workflow.entities.length.should.be(0));
                    it("should not be activated", e.isActive().should.be(false));
                    it("should not be valid", e.isValid().should.be(false));
                });

                describe("When destroy Entity", {
                    beforeEach({
                        e.destroy();
                    });
                    it("should not be added to the flow", echoes.Workflow.entities.length.should.be(0));
                    it("should not be activated", e.isActive().should.be(false));
                    it("should not be valid", e.isValid().should.be(false));
                });

                describe("When remove all of components", {
                    beforeEach({
                        e.removeAll();
                    });
                    it("should not be added to the flow", echoes.Workflow.entities.length.should.be(0));
                    it("should not be activated", e.isActive().should.be(false));
                    it("should not be valid", e.isValid().should.be(false));
                });
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
