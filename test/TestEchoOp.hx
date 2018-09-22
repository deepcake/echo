package;

import echo.*;
import data.C;
using Lambda;

class TestEchoOp extends haxe.unit.TestCase {


    var ch:Echo;
    var v:View<{ a:C1, b:C2 }>;
    var s:SimpleSystem;


    override public function setup() {
        ch = new Echo();
        v = new View<{ a:C1, b:C2 }>();
        s = new SimpleSystem();
        ch.addView(v);
        ch.addSystem(s);
    }


    public function test_dispose() {
        ch.dispose();

        assertEquals(0, v.entities.length);
        assertEquals(0, ch.entities.length);
        assertEquals(0, ch.views.length);
        assertEquals(0, ch.systems.length);
    }


}

private class SimpleSystem extends System {
    var r = .0;
    var v:VC;
    @u function action(c0:C0) {
        r = Math.random();
    }
}

private typedef VC = View<{ c:C }>;
