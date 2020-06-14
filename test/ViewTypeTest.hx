using buddy.Should;

import echoes.View;
import echoes.Workflow;
import echoes.Entity;

class ViewTypeTest extends buddy.BuddySuite {
    public function new() {
        buddy.BuddySuite.useDefaultTrace = true;
        describe("Test View with Different Type Params", {

            beforeEach({
                Workflow.reset();
            });

            describe("When define a View with Type Params", {
                var tvs:TypeViewSystem;

                beforeEach(tvs = new TypeViewSystem());

                it("should be equals", {
                    tvs.rest.should.be(StandaloneTypeViewSystem.ab);
                    tvs.restReversed.should.be(StandaloneTypeViewSystem.ab);
                });

                describe("When add System to the flow", {
                    beforeEach(Workflow.addSystem(tvs));

                    it("should have correct count of views", {
                        Workflow.views.length.should.be(1);
                    });

                    describe("When add standalone System to the flow", {
                        beforeEach(Workflow.addSystem(new StandaloneTypeViewSystem()));

                        it("should have correct count of views", {
                            Workflow.views.length.should.be(1);
                        });
                    });

                    describe("When remove System from the flow", {
                        beforeEach(Workflow.removeSystem(tvs));

                        it("should have correct count of views", {
                            Workflow.views.length.should.be(0);
                        });
                    });
                });
            });

            describe("When define a View with Func Params", {
                var fvs:FuncViewSystem;

                beforeEach(fvs = new FuncViewSystem());

                it("should be equals", {
                    fvs.fv.should.be(StandaloneFuncViewSystem.fv);
                    fvs.fvReversed.should.be(StandaloneFuncViewSystem.fv);
                });

                describe("When add System to the flow", {
                    beforeEach(Workflow.addSystem(fvs));

                    it("should have correct count of views", {
                        Workflow.views.length.should.be(1);
                    });

                    describe("When add standalone System to the flow", {
                        beforeEach(Workflow.addSystem(new StandaloneFuncViewSystem()));

                        it("should have correct count of views", {
                            Workflow.views.length.should.be(1);
                        });
                    });

                    describe("When remove System from the flow", {
                        beforeEach(Workflow.removeSystem(fvs));

                        it("should have correct count of views", {
                            Workflow.views.length.should.be(0);
                        });
                    });
                });
            });

        });
    }
}

abstract VA(String) {
    public function new() this = 'A';
}

abstract VB(String) {
    public function new() this = 'B';
}

abstract VC(String) {
    public function new() this = 'C';
}


class TypeViewSystem extends echoes.System {

    public var rest:View<VA, VB>;

    public var restReversed:View<VA, VB>;

    @u function ab(a:VA, b:VB) { }

    @u function ba(b:VB, a:VA) { }

    @u function cd(c:VB, d:VA) { }

    @u function fab(f:Float, a:VA, b:VB) { }

    @u function eab(e:Entity, a:VA, b:VB) { }

    @u function iab(i:Int, a:VA, b:VB) { }

    @u function feab(f:Float, e:Entity, a:VA, b:VB) { }

}

class FuncViewSystem extends echoes.System {

    public var fv:View<VA->VB->Void, VA->VB>;

    public var fvReversed:View<VA->VB, VA->VB->Void>;

    @u function abv_ab(abv:VA->VB->Void, ab:VA->VB) { }

    @u function ab_abv(ab:VA->VB, abv:VA->VB->Void) { }

    @u function dt_e_abv_ab(f:Float, e:Entity, abv:VA->VB->Void, ab:VA->VB) { }

}

class StandaloneTypeViewSystem extends echoes.System {
    public static var ab:View<VA, VB>;
}

class StandaloneFuncViewSystem extends echoes.System {
    public static var fv:View<VA->VB->Void, VA->VB>;
}
