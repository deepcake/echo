import echo.Echo;
import echo.Entity;
import echo.*;

using buddy.Should;

class Run extends buddy.SingleSuite {
    public function new() {
        describe("when echo", {

            describe("when to entity", {

                var e1 = new Entity();

                describe("when add empty component", {
                    it("add empty", {
                        e1.add();
                    });
                    it("should not exists String component", {
                        e1.exists(String).should.be(false);
                    });
                    it("should not have String component", {
                        e1.get(String).should.be(null);
                    });
                });

                describe("when add String component", {
                    it("add", {
                        e1.add("123");
                    });
                    it("should exists String component", {
                        e1.exists(String).should.be(true);
                    });
                    it("should have String component", {
                        e1.get(String).should.be("123");
                    });
                });

                describe("when add String component again", {
                    it("add again", {
                        e1.add("123456");
                    });
                    it("should exists String component", {
                        e1.exists(String).should.be(true);
                    });
                    it("should have String component", {
                        e1.get(String).should.be("123456");
                    });
                });

                describe("when remove String component", {
                    it("remove", {
                        e1.remove(String);
                    });
                    it("should not exists String component", {
                        e1.exists(String).should.be(false);
                    });
                    it("should not have String component", {
                        e1.get(String).should.be(null);
                    });
                });

            });


            describe("when init slow entity with a component", {

                beforeAll(Echo.inst().dispose());

                var e = new Entity(false).add(new ArrayComponent());

                it("should not be immediate added to the flow", {
                    Echo.inst().entities.length.should.be(0);
                });

                it("should still contains a component", {
                    e.exists(ArrayComponent).should.be(true);
                });

                it("should be deactivated", {
                    e.activated().should.be(false);
                });

                describe("then when activate", {
                    beforeAll(e.activate());

                    it("should be added to the flow", {
                        Echo.inst().entities.length.should.be(1);
                    });
                    it("should still contains a component", {
                        e.exists(ArrayComponent).should.be(true);
                    });
                    it("should be activated", {
                        e.activated().should.be(true);
                    });
                });

                describe("then when deactivate", {
                    beforeAll(e.deactivate());

                    it("should be removed from the flow", {
                        Echo.inst().entities.length.should.be(0);
                    });
                    it("should still contains a component", {
                        e.exists(ArrayComponent).should.be(true);
                    });
                    it("should be deactivated", {
                        e.activated().should.be(false);
                    });
                });

                describe("then when destroyed", {
                    beforeAll(e.destroy());

                    it("should be removed from the flow", {
                        Echo.inst().entities.length.should.be(0);
                    });
                    it("should not contains a component", {
                        e.exists(ArrayComponent).should.be(false);
                    });
                    it("should be deactivated", {
                        e.activated().should.be(false);
                    });
                });

            });

        });
    }
}

@:forward
abstract ArrayComponent(Array<String>) {
    public function new() this = new Array<String>();
}