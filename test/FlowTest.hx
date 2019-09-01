import echos.*;

using buddy.Should;

class FlowTest extends buddy.BuddySuite {
    public function new() {
        describe("Flow", {
            var x = new SystemX();
            var y = new SystemY();

            beforeEach({
                Workflow.dispose();
            });

            describe("When add System X", {
                beforeEach({
                    Workflow.addSystem(x);
                });
                it("should be added", Workflow.systems.length.should.be(1));
                it("should be added", Workflow.hasSystem(x).should.be(true));

                describe("When remove System X", {
                    beforeEach({
                        Workflow.removeSystem(x);
                    });
                    it("should be removed", Workflow.systems.length.should.be(0));
                    it("should be removed", Workflow.hasSystem(x).should.be(false));
                });

                describe("When add System Y", {
                    beforeEach({
                        Workflow.addSystem(y);
                    });
                    it("should be added", Workflow.systems.length.should.be(2));
                    it("should be added", Workflow.hasSystem(y).should.be(true));

                    describe("When remove System Y", {
                        beforeEach({
                            Workflow.removeSystem(y);
                        });
                        it("should be removed", Workflow.systems.length.should.be(1));
                        it("should be removed", Workflow.hasSystem(y).should.be(false));
                    });

                    describe("When remove System X", {
                        beforeEach({
                            Workflow.removeSystem(x);
                        });
                        it("should be removed", Workflow.systems.length.should.be(1));
                        it("should be removed", Workflow.hasSystem(x).should.be(false));
                    });

                    describe("When dispose", {
                        beforeEach({
                            Workflow.dispose();
                        });
                        it("should be removed", Workflow.systems.length.should.be(0));
                        it("should be removed", Workflow.hasSystem(x).should.be(false));
                        it("should be removed", Workflow.hasSystem(y).should.be(false));
                    });
                });
            });
        });
    }
}

class SystemX extends echos.System {

}

class SystemY extends echos.System {

}
