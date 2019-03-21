import echos.*;

using buddy.Should;

class EntityTest extends buddy.BuddySuite {
    public function new() {
        describe("Using Entity", {

            var e:Entity;

            describe("When init immediate Entity", {
                beforeAll(Workflow.dispose());
                beforeAll(e = new Entity());

                it("should be immediate added to the flow", Workflow.entities.length.should.be(1));
                it("should be activated", e.isActivated().should.be(true));
                it("should not exists a String component", e.exists(String).should.be(false));
                it("should not get a String component", e.get(String).should.be(null));
                it("should remove a String component without error", e.remove(String));

                describe("Then add a Void component", {
                    beforeAll(e.add());
                    it("should not exists a String component", e.exists(String).should.be(false));
                    it("should not get a String component", e.get(String).should.be(null));
                    it("should be activated", e.isActivated().should.be(true));
                });

                describe("Then add a String component 123", {
                    beforeAll(e.add("123"));
                    it("should exists a String component 123", e.exists(String).should.be(true));
                    it("should get a String component 123", e.get(String).should.be("123"));
                    it("should be activated", e.isActivated().should.be(true));
                });

                describe("Then add a String component 321", {
                    beforeAll(e.add("321"));
                    it("should exists a String component 321", e.exists(String).should.be(true));
                    it("should get a String component 321", e.get(String).should.be("321"));
                    it("should be activated", e.isActivated().should.be(true));
                });

                describe("Then remove a String component", {
                    beforeAll(e.remove(String));
                    it("should not exists a String component", e.exists(String).should.be(false));
                    it("should not get a String component", e.get(String).should.be(null));
                    it("should be activated", e.isActivated().should.be(true));
                });

                describe("Then remove a String component again", {
                    beforeAll(e.remove(String));
                    it("should not exists a String component", e.exists(String).should.be(false));
                    it("should not get a String component", e.get(String).should.be(null));
                    it("should be activated", e.isActivated().should.be(true));
                });

                describe("Then add a String component 123 after removing", {
                    beforeAll(e.add("123"));
                    it("should exists a String component 123", e.exists(String).should.be(true));
                    it("should get a String component 123", e.get(String).should.be("123"));
                    it("should be activated", e.isActivated().should.be(true));
                });
            });


            describe("When init immediate Entity and then add a few components at once", {
                beforeAll(Workflow.dispose());

                var a = new ArrayComponent();
                var i8 = new IntComponent(8);

                beforeAll(e = new Entity().add(a, "a", i8));

                it("should exists all of components", {
                    e.exists(ArrayComponent).should.be(true);
                    e.exists(String).should.be(true);
                    e.exists(IntComponent).should.be(true);
                });

                it("should get all of components", {
                    e.get(ArrayComponent).should.be(a);
                    e.get(String).should.be("a");
                    e.get(IntComponent).should.be(i8);
                });

                describe("Then re-set all of components at once", {

                    var b = new ArrayComponent();
                    var i9 = new IntComponent(9);

                    beforeAll(e.add(b, "b", i9));

                    it("should exists all of components", {
                        e.exists(ArrayComponent).should.be(true);
                        e.exists(String).should.be(true);
                        e.exists(IntComponent).should.be(true);
                    });

                    it("should get all of new components", {
                        e.get(ArrayComponent).should.be(b);
                        e.get(String).should.be("b");
                        e.get(IntComponent).should.be(i9);
                    });

                });

                describe("Then remove all of components at once", {

                    beforeAll(e.remove(ArrayComponent, String, IntComponent));

                    it("should not exists all of components", {
                        e.exists(ArrayComponent).should.be(false);
                        e.exists(String).should.be(false);
                        e.exists(IntComponent).should.be(false);
                    });

                    it("should not get all of components", {
                        e.get(ArrayComponent).should.be(null);
                        e.get(String).should.be(null);
                        e.get(IntComponent).should.be(null);
                    });

                });
            });


            describe("When init non immediate Entity and then add a component", {
                beforeAll(Workflow.dispose());
                beforeAll(e = new Entity(false).add(new ArrayComponent()));

                it("should not be immediate added to the flow", Workflow.entities.length.should.be(0));
                it("should exists a component", e.exists(ArrayComponent).should.be(true));
                it("should be deactivated", e.isActivated().should.be(false));

                describe("Then activate", {
                    beforeAll(e.activate());
                    it("should be added to the flow", Workflow.entities.length.should.be(1));
                    it("should exists a component", e.exists(ArrayComponent).should.be(true));
                    it("should be activated", e.isActivated().should.be(true));
                });

                describe("Then deactivate", {
                    beforeAll(e.deactivate());
                    it("should be removed from the flow", Workflow.entities.length.should.be(0));
                    it("should exists a component", e.exists(ArrayComponent).should.be(true));
                    it("should be deactivated", e.isActivated().should.be(false));
                });

                describe("Then activate after deactivate", {
                    beforeAll(e.activate());
                    it("should be added to the flow", Workflow.entities.length.should.be(1));
                    it("should exists a component", e.exists(ArrayComponent).should.be(true));
                    it("should be activated", e.isActivated().should.be(true));
                });

                describe("Then destroy", {
                    beforeAll(e.destroy());
                    it("should be removed from the flow", Workflow.entities.length.should.be(0));
                    it("should not exists a component", e.exists(ArrayComponent).should.be(false));
                    it("should be deactivated", e.isActivated().should.be(false));
                });

                describe("Then activate after destroy", {
                    beforeAll(e.activate());
                    it("should be added to the flow", Workflow.entities.length.should.be(1));
                    it("should not exists a component", e.exists(ArrayComponent).should.be(false));
                    it("should be activated", e.isActivated().should.be(true));
                });
            });


        });
    }
}

abstract ArrayComponent(Array<String>) {
    public function new() this = [ "hello" ];
}

abstract IntComponent(Null<Int>) {
    public function new(value:Int) this = value;
}
