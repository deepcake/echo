import echo.Echo;
import echo.Entity;
import echo.*;

using buddy.Should;

class Run extends buddy.SingleSuite {
    public function new() {
        describe("when echo", {

            var e:Entity;

            describe("when init empty entity", {

                beforeAll(e = new Entity());

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
                    beforeAll(e.add("321"));

                    it("should exists a String component", {
                        e.exists(String).should.be(true);
                    });
                    it("should have a second String component", {
                        e.get(String).should.be("321");
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

                afterAll(Echo.inst().dispose());

            });


            describe("when init entity with a few components", {

                var a = new ArrayComponent();

                beforeAll(e = new Entity().add(a, "a", 8));

                it("should contains all of them", {
                    e.exists(ArrayComponent).should.be(true);
                    e.exists(String).should.be(true);
                    e.exists(Int).should.be(true);
                });

                it("should have all of them", {
                    e.get(ArrayComponent).should.be(a);
                    e.get(String).should.be("a");
                    e.get(Int).should.be(8);
                });

                describe("then when reset all of components", {

                    var b = new ArrayComponent();

                    beforeAll(e.add(b, "b", 9));

                    it("should contains all of them", {
                        e.exists(ArrayComponent).should.be(true);
                        e.exists(String).should.be(true);
                        e.exists(Int).should.be(true);
                    });

                    it("should have all of new components", {
                        e.get(ArrayComponent).should.be(b);
                        e.get(String).should.be("b");
                        e.get(Int).should.be(9);
                    });

                });

                describe("then when remove all of components", {

                    beforeAll(e.remove(ArrayComponent, String, Int));

                    it("should not contains all of them", {
                        e.exists(ArrayComponent).should.be(false);
                        e.exists(String).should.be(false);
                        e.exists(Int).should.be(false);
                    });

                    it("should not have all of new components", {
                        e.get(ArrayComponent).should.be(null);
                        e.get(String).should.be(null);
                        e.get(Int).should.be(null);
                    });

                });

                afterAll(Echo.inst().dispose());

            });


            describe("when init slow entity with a component", {

                beforeAll(e = new Entity(false).add(new ArrayComponent()));

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

                afterAll(Echo.inst().dispose());

            });

        });
    }
}

@:forward
abstract ArrayComponent(Array<String>) from Array<String> to Array<String> {
    public function new() this = [ "hello" ];
}