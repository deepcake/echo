import echos.*;

using buddy.Should;

class ViewTest extends buddy.BuddySuite {
    public function new() {
        describe("Using Views", {

            describe("Default", {
                var s = new ViewTestSystem1();
                var addCounter = 0;
                var removeCounter = 0;

                describe("When add entities", {
                    beforeAll({
                        Echo.addSystem(s);

                        s.a.onAdded.add(function(id, a) addCounter++);
                        s.a.onRemoved.add(function(id, a) removeCounter++);

                        for (i in 0...300) {
                            var e = new Entity();
                            e.add(new A());
                            if (i % 2 == 0) e.add(new B());
                            if (i % 3 == 0) e.add(new C());
                            if (i % 5 == 0) e.add(new D());
                            if (i % 6 == 0) e.add(new E());
                        }
                    });
                    it("should matching them correctly", {
                        s.a.entities.length.should.be(300);
                        s.b.entities.length.should.be(150);

                        s.ab.entities.length.should.be(150);
                        s.bc.entities.length.should.be(50);

                        s.abcd.entities.length.should.be(10);
                    });
                    it("should correctly dispatch add signals", addCounter.should.be(300));
                    it("should correctly dispatch remove signals", removeCounter.should.be(0));
                });

                describe("When remove components", {
                    beforeAll({
                        for(e in Echo.entities) {
                            e.remove(A);
                        }
                    });
                    it("should matching them correctly", {
                        s.a.entities.length.should.be(0);
                        s.b.entities.length.should.be(150);

                        s.ab.entities.length.should.be(0);
                        s.bc.entities.length.should.be(50);

                        s.abcd.entities.length.should.be(0);
                    });
                    it("should correctly dispatch add signals", addCounter.should.be(300));
                    it("should correctly dispatch remove signals", removeCounter.should.be(300));
                });

                describe("When remove entities", {
                    beforeAll({
                        for(e in Echo.entities) {
                            e.destroy();
                        }
                    });
                    it("should matching them correctly", {
                        s.a.entities.length.should.be(0);
                        s.b.entities.length.should.be(0);

                        s.ab.entities.length.should.be(0);
                        s.bc.entities.length.should.be(0);

                        s.abcd.entities.length.should.be(0);
                    });
                    it("should correctly dispatch add signals", addCounter.should.be(300));
                    it("should correctly dispatch remove signals", removeCounter.should.be(300));
                });
            });


            describe("When views was defined with the same signatures", {
                beforeAll(Echo.dispose());
                beforeAll(Echo.addSystem(new SameViewSystem()));
                it("should not define doublicates", {
                    SameViewSystem.ab.should.be(SameViewSystem.ba);
                    SameViewSystem.ab.should.be(SameViewSystem.ab1);
                    SameViewSystem.ab.should.be(SameViewSystem.ab2);
                    SameViewSystem.ab.should.be(SameViewSystem.ab3);
                });
                it("should not add doublicates to the flow", {
                    Echo.views.length.should.be(1);
                });
            });


            describe("Using Echo.getView()", {
                describe("When view was defined somewhere already", {
                    var view = Echo.getView(B, A);
                    beforeAll(Echo.dispose());
                    beforeAll(view.activate());
                    beforeAll(new Entity().add(new A(), new B(), new C(), new D(), new E()));

                    it("should be added to the flow", Echo.views.length.should.be(1));
                    it("should matching entities correctly", view.entities.length.should.be(1));
                });
                describe("When view was not defined defore", {
                    var view = Echo.getView(D, C, B);
                    beforeAll(Echo.dispose());
                    beforeAll(view.activate());
                    beforeAll(new Entity().add(new A(), new B(), new C(), new D(), new E()));

                    it("should be added to the flow", Echo.views.length.should.be(1));
                    it("should matching entities correctly", view.entities.length.should.be(1));
                });
            });


        });
    }
}

class ViewTestSystem1 extends echos.System {

    public var a:View<A->Void>;
    public var b:View<B->Void>;

    public var ab:View<A->B->Void>;
    public var bc:View<B->C->Void>;

    public var abcd:View<A->B->C->D->Void>;

}

typedef TAB = { a:A, b:B };
typedef VAB = View<{ a:A, b:B }>;
class SameViewSystem extends echos.System {

    public static var ab:View<A->B->Void>;
    public static var ba:View<B->A->Void>;

    public static var ab1:View<TAB>;
    public static var ab2:VAB;
    public static var ab3:View<{ a:A, b:B }>;

    @u function abFunc(a:A, b:B) { }
    @u function baFunc(b:B, a:A) { }
    @u function cdFunc(c:B, d:A) { }

    @u function abFloatEntityFunc(delta:Float, entity:Entity, a:A, b:B) { }
    @u function abFloatIntFunc(a:A, delta:Float, id:Int, b:B) { }
    @u function abEchoEntityFunc(entity:echos.Entity, a:A, b:B) { }

}


class A {
    public function new() { };
}

class B {
    public function new() { };
}

abstract C(A) {
    public function new() this = new A();
}

abstract D(B) {
    public function new() this = new B();
}

class E extends A {
    public function new() super();
}