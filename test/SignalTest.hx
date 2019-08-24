import echos.utils.Signal;

using buddy.Should;

class SignalTest extends buddy.BuddySuite {
    public function new() {
        describe("Signal", {
            var s:Signal<Int->O->Void>;
            var r:String;

            beforeEach({
                s = new Signal<Int->O->Void>();
                r = '';
            });

            describe("When add listener", {
                var f1 = function(i:Int, o:O) r += '1_$i$o';
                beforeEach({
                    s.add(f1);
                });
                it("should be added", s.has(f1).should.be(true));
                it("should has correct length", s.length.should.be(1));

                describe("When remove listener", {
                    beforeEach({
                        s.remove(f1);
                    });
                    it("should be removed", s.has(f1).should.be(false));
                    //it("should has correct length", s.length.should.be(0));

                    describe("When dispatch", {
                        beforeEach({
                            s.dispatch(1, new O('1'));
                        });
                        it("should not be dispatched", r.should.be(""));
                    });
                });

                describe("When remove all of listeners", {
                    beforeEach({
                        s.removeAll();
                    });
                    it("should be removed", s.has(f1).should.be(false));
                    //it("should has correct length", s.length.should.be(0));

                    describe("When dispatch", {
                        beforeEach({
                            s.dispatch(1, new O('1'));
                        });
                        it("should not be dispatched", r.should.be(""));
                    });
                });

                describe("When dispatch", {
                    beforeEach({
                        s.dispatch(1, new O('1'));
                    });
                    it("should be dispatched", r.should.be("1_11"));
                });

                describe("When dispose", {
                    beforeEach({
                        s.dispose();
                    });
                    it("should be removed", s.has(f1).should.be(false));
                    it("should has correct length", s.length.should.be(0));
                });

                describe("When add second listener", {
                    var f2 = function(i:Int, o:O) r += '2_$i$o';
                    beforeEach({
                        s.add(f2);
                    });
                    it("should be added", s.has(f2).should.be(true));
                    it("should has correct length", s.length.should.be(2));

                    describe("When remove second listener", {
                        beforeEach({
                            s.remove(f2);
                        });
                        it("should not be removed", s.has(f1).should.be(true));
                        it("should be removed", s.has(f2).should.be(false));
                        //it("should has correct length", s.length.should.be(1));

                        describe("When dispatch", {
                            beforeEach({
                                s.dispatch(1, new O('1'));
                            });
                            it("should not be dispatched", r.should.be("1_11"));
                        });
                    });

                    describe("When remove all of listeners", {
                        beforeEach({
                            s.removeAll();
                        });
                        it("should be removed", s.has(f1).should.be(false));
                        it("should be removed", s.has(f2).should.be(false));
                        //it("should has correct length", s.length.should.be(0));

                        describe("When dispatch", {
                            beforeEach({
                                s.dispatch(1, new O('1'));
                            });
                            it("should not be dispatched", r.should.be(""));
                        });
                    });

                    describe("When dispatch", {
                        beforeEach({
                            s.dispatch(1, new O('1'));
                        });
                        it("should be dispatched", r.should.be("1_112_11"));
                    });

                    describe("When dispose", {
                        beforeEach({
                            s.dispose();
                        });
                        it("should be removed", s.has(f1).should.be(false));
                        it("should be removed", s.has(f2).should.be(false));
                        it("should has correct length", s.length.should.be(0));
                    });
                });
            });
        });
    }
}

class O {
    var val:String;
    public function new(val) this.val = val;
    public function toString() return val;
}
