package;

import data.Greeting;
import data.Name;
import haxe.unit.TestCase;
import echo.*;

/**
 * ...
 * @author https://github.com/deepcake
 */
class TestSmoke3 extends TestCase {

    //var ch:Echo;


    public function new() super();


    //override public function setup() {
        //ch = new Echo();
        //for (i in 'xy'.split('')) ch.addComponent(ch.id(), new Name(i));
    //}

    public function test_workflow1() {

        var e = new Echo();
        var v = new View<String->Void>();
        var v2 = new View<String>();
        var v3 = new View<S>();

        e.addView(v);
        e.addComponent(e.id(), "hello");

        v.iter((s, _) -> trace(s));
        v2.iter((s, _) -> trace(s));
        v3.iter((s, _) -> trace(s));

        //for (i in v2) i.


        assertTrue(true);
    }

}

typedef S = { name: String };
