import echo.Echo;
import echo.Entity;
import echo.*;

using buddy.Should;

class Run extends buddy.SingleSuite {
    public function new() {
        describe("when echo", {

            describe("when init empty entity", {

                var e = new Entity();

                describe("then when add a Void component", {
                    beforeAll(e.add());

                    it("should not exists a String component", {
                        e.exists(String).should.be(false);
                    });
                    it("should not have a String component", {
                        e.get(String).should.be(null);
                    });
                });

                describe("then when add a String component", {
                    beforeAll(e.add("123"));

                    it("should exists a String component", {
                        e.exists(String).should.be(true);
                    });
                    it("should have a String component", {
                        e.get(String).should.be("123");
                    });
                });

                describe("then when add a second String component", {
                    beforeAll(e.add("hello"));

                    it("should exists a String component", {
                        e.exists(String).should.be(true);
                    });
                    it("should have a second String component", {
                        e.get(String).should.be("hello");
                    });
                });

                describe("then when remove a String component", {
                    beforeAll(e.remove(String));

                    it("should not exists a String component", {
                        e.exists(String).should.be(false);
                    });
                    it("should not have a String component", {
                        e.get(String).should.be(null);
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