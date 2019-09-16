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
                it("should has correct count of views", Workflow.views.length.should.be(2));

                describe("When remove System X", {
                    beforeEach({
                        Workflow.removeSystem(x);
                    });
                    it("should be removed", Workflow.systems.length.should.be(0));
                    it("should be removed", Workflow.hasSystem(x).should.be(false));
                    it("should has correct count of views", Workflow.views.length.should.be(0));
                });

                describe("When add System Y", {
                    beforeEach({
                        Workflow.addSystem(y);
                    });
                    it("should be added", Workflow.systems.length.should.be(2));
                    it("should be added", Workflow.hasSystem(y).should.be(true));
                    it("should has correct count of views", Workflow.views.length.should.be(3));

                    describe("When remove System Y", {
                        beforeEach({
                            Workflow.removeSystem(y);
                        });
                        it("should be removed", Workflow.systems.length.should.be(1));
                        it("should be removed", Workflow.hasSystem(y).should.be(false));
                        it("should has correct count of views", Workflow.views.length.should.be(2));
                    });

                    describe("When remove System X", {
                        beforeEach({
                            Workflow.removeSystem(x);
                        });
                        it("should be removed", Workflow.systems.length.should.be(1));
                        it("should be removed", Workflow.hasSystem(x).should.be(false));
                        it("should has correct count of views", Workflow.views.length.should.be(2));
                    });

                    describe("When dispose", {
                        beforeEach({
                            Workflow.dispose();
                        });
                        it("should be removed", Workflow.systems.length.should.be(0));
                        it("should be removed", Workflow.hasSystem(x).should.be(false));
                        it("should be removed", Workflow.hasSystem(y).should.be(false));
                        it("should has correct count of views", Workflow.views.length.should.be(0));
                    });
                });
            });
        });
    }
}

class X {
    public function new() { };
}

class Y {
    public function new() { };
}

class SystemX extends echos.System {
    var x:View<X>;
    var xy:View<X, Y>;
}

class SystemY extends echos.System {
    @u inline function update(y:Y) { }
    @u inline function updatexy(x:X, y:Y, dt:Float) { }
}
