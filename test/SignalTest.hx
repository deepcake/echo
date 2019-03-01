using buddy.Should;

class SignalTest extends buddy.BuddySuite {
    public function new() {
        describe("Using Siganls", {

            var s = new echo.utils.Signal<String->String->Void>();
            var r = "";
            var f = function(s1:String, s2:String) r = s1 + s2;

            describe("When add a listener", {
                beforeAll(s.add(f));
                it("should be added", s.has(f).should.be(true));
            });

            describe("Then dispatch", {
                beforeAll(s.dispatch("a", "b"));
                it("should be dispatched", r.should.be("ab"));
            });

            describe("Then remove a listener", {
                beforeAll(s.remove(f));
                it("should be removed", s.has(f).should.be(false));
            });

        });
    }
}