using buddy.Should;

import echos.View;
import echos.Workflow;
import echos.Entity;

class BuildTest extends buddy.BuddySuite {
    public function new() {
        describe("Building", {

            beforeEach(echos.Workflow.dispose());

            describe("When a same views defined with different ways", {
                beforeEach(echos.Workflow.addSystem(new DefineViewSystem()));

                it("should be equals", {
                    DefineViewSystem.funcReversed.should.be(DefineViewSystem.func);
                    DefineViewSystem.funcShort.should.be(DefineViewSystem.func);
                    DefineViewSystem.anon.should.be(DefineViewSystem.func);
                    DefineViewSystem.anonTypedef.should.be(DefineViewSystem.func);
                    DefineViewSystem.viewTypedef.should.be(DefineViewSystem.func);
                    DefineViewSystem.rest.should.be(DefineViewSystem.func);
                });

                it("should add only one View to the flow", {
                    Workflow.views.length.should.be(1);
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
