using buddy.Should;

import echos.View;
import echos.Workflow;
import echos.Entity;

class BuildTest extends buddy.BuddySuite {
    public function new() {
        describe("Building", {

            beforeEach(echos.Workflow.dispose());

            describe("When define a View with different ways", {
                beforeEach(echos.Workflow.addSystem(new DefineViewSystem()));
                it("should define equaled views", {
                    DefineViewSystem.reversed.should.be(DefineViewSystem.original);
                    DefineViewSystem.param.should.be(DefineViewSystem.original);
                    DefineViewSystem.paramTypedef.should.be(DefineViewSystem.original);
                    DefineViewSystem.viewTypedef.should.be(DefineViewSystem.original);
                    DefineViewSystem.short.should.be(DefineViewSystem.original);
                });
                it("should add only one view to the flow", {
                    echos.Workflow.views.length.should.be(1);
                });
            });

        });
    }
}

abstract CompA(String) {
    public function new() {
        this = 'A';
    }
}

abstract CompB(String) {
    public function new() {
        this = 'B';
    }
}

typedef ParamTypedef = { a:CompA, b:CompB };

typedef ViewTypedef = View<{ a:CompA, b:CompB }>;

class DefineViewSystem extends echos.System {

    public static var original:View<CompA->CompB->Void>;

    public static var reversed:View<CompB->CompA->Void>;

    public static var param:View<{ a:CompA, b:CompB }>;

    public static var paramTypedef:View<ParamTypedef>;

    public static var viewTypedef:ViewTypedef;

    public static var short:View<CompA->CompB>;

    @u function ab(a:CompA, b:CompB) { }

    @u function ba(b:CompB, a:CompA) { }

    @u function cd(c:CompB, d:CompA) { }

    @u function eab(f:Float, a:CompA, b:CompB) { }

    @u function fab(e:Entity, a:CompA, b:CompB) { }

    @u function feab(f:Float, e:Entity, a:CompA, b:CompB) { }

    @u function fiab(f:Float, i:Int, a:CompA, b:CompB) { }

}
