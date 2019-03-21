using buddy.Should;

class SignalTest extends buddy.BuddySuite {
    public function new() {
        describe("Using Siganls", {

            describe("If add a one listener", {
                var s = new echos.utils.Signal<String->String->Void>();
                var r = "";
                var f = function(s1:String, s2:String) r += s1 + s2;

                describe("When add a listener", {
                    beforeAll(s.add(f));
                    it("should be added", s.has(f).should.be(true));
                    it("should have correct length", s.length.should.be(1));
                });

                describe("Then dispatch", {
                    beforeAll(s.dispatch("a", "b"));
                    it("should be dispatched", r.should.be("ab"));
                    it("should have correct length", s.length.should.be(1));
                });

                describe("Then dispatch again", {
                    beforeAll(s.dispatch("a", "b"));
                    it("should be dispatched", r.should.be("abab"));
                    it("should have correct length", s.length.should.be(1));
                });

                describe("Then remove a listener", {
                    beforeAll(s.remove(f));
                    it("should be removed", s.has(f).should.be(false));
                    it("should have correct length", s.length.should.be(1));
                });

                describe("Then dispatch", {
                    beforeAll(s.dispatch("a", "b"));
                    it("should not be dispatched", r.should.be("abab"));
                    it("should have correct length", s.length.should.be(0));
                });
            });

            describe("If add a few listeners", {
                var s = new echos.utils.Signal<String->String->Void>();
                var r = "";
                var f1 = function(s1:String, s2:String) r += s1 + s2;
                var f2 = function(s1:String, s2:String) r += "1" + s1;
                var f3 = function(s1:String, s2:String) r += "2" + s2;

                describe("When add listeners", {
                    beforeAll({
                        s.add(f1);
                        s.add(f2);
                        s.add(f3);
                    });
                    it("should be added", {
                        s.has(f1).should.be(true);
                        s.has(f2).should.be(true);
                        s.has(f3).should.be(true);
                    });
                    it("should have correct length", s.length.should.be(3));
                });

                describe("Then dispatch", {
                    beforeAll(s.dispatch("a", "b"));
                    it("should be dispatched", r.should.be("ab1a2b"));
                    it("should have correct length", s.length.should.be(3));
                });

                describe("Then remove all listeners", {
                    beforeAll({
                        s.removeAll();
                    });
                    it("should be removed", {
                        s.has(f1).should.be(false);
                        s.has(f2).should.be(false);
                        s.has(f3).should.be(false);
                    });
                    it("should have correct length", s.length.should.be(3));
                });

                describe("Then dispatch", {
                    beforeAll(s.dispatch("a", "b"));
                    it("should not be dispatched", r.should.be("ab1a2b"));
                    it("should have correct length", s.length.should.be(0));
                });
            });


            describe("Using dispose", {
                var s = new echos.utils.Signal<String->String->Void>();
                var r = "";
                var f1 = function(s1:String, s2:String) r += s1 + s2;
                var f2 = function(s1:String, s2:String) r += "1" + s1;
                var f3 = function(s1:String, s2:String) r += "2" + s2;

                beforeAll({
                    s.add(f1);
                    s.add(f2);
                    s.add(f3);
                });

                describe("When dispose", {
                    beforeAll({
                        s.dispose();
                    });
                    it("should have correct length", s.length.should.be(0));
                });
            });

        });
    }
}