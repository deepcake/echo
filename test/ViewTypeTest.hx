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

            describe("When define a View with Different Type Params", {
                var sys:ViewTypeSystem;

                beforeEach(sys = new ViewTypeSystem());

                it("should be equals", {
                    sys.rest.should.be(StandaloneVAVBSystem.ab);
                    sys.restReversed.should.be(StandaloneVAVBSystem.ab);
                });

                describe("When add System to the flow", {
                    beforeEach(Workflow.addSystem(sys));

                    it("should have correct count of views", {
                        Workflow.views.length.should.be(1);
                    });

                    describe("When add standalone System to the flow", {
                        beforeEach(Workflow.addSystem(new StandaloneVAVBSystem()));

                        it("should have correct count of views", {
                            Workflow.views.length.should.be(1);
                        });
                    });

                    describe("When remove System from the flow", {
                        beforeEach(Workflow.removeSystem(sys));

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


class ViewTypeSystem extends echoes.System {

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

class StandaloneVAVBSystem extends echoes.System {
    public static var ab:View<VA, VB>;
}
