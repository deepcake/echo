package;

import echo.*;
import data.C;
using Lambda;

class TestViewOp extends haxe.unit.TestCase {


    var ch:Echo;
    var vab:View<{ a:C1, b:C2 }>;
    var va_:View<{ a:C1 }>;
    var v_b:View<{ b:C2 }>;

    var va_added = 0;
    var va_removed = 0;


    function createQwerty(add = true):Array<Int> {
        return 'qwerty'.split('').map(function(s:String) return ch.addComponent(ch.id(add), new C1('$s'.toUpperCase()), new C2()));
    }

    function onAddA(id:Int) va_added++;

    function onRemoveA(id:Int) va_removed++;


    override public function setup() {
        ch = new Echo();
        vab = new View<{ a:C1, b:C2 }>();
        va_ = new View<{ a:C1 }>();
        v_b = new View<{ b:C2 }>();
        ch.addView(vab);
        ch.addView(va_);
        ch.addView(v_b);
        va_added = 0;
        va_removed = 0;
        va_.onAdded.add(onAddA);
        va_.onRemoved.add(onRemoveA);
    }


    public function test_mapping_add_component() {
        for (i in 0...100) {
            var id = ch.id();
            if (i % 2 == 0) ch.addComponent(id, new C1());
            if (i % 5 == 0) ch.addComponent(id, new C2());
        }

        assertEquals(100, ch.entities.length);
        assertEquals(50, va_.entities.length);
        assertEquals(20, v_b.entities.length);
        assertEquals(10, vab.entities.length);
        assertEquals(50, va_added);
        assertEquals(0, va_removed);
    }

    public function test_mapping_remove_component() {
        for (i in 0...100) {
            ch.addComponent(ch.id(), new C1(), new C2());
        }

        for (i in 0...100) {
            if (i % 2 == 0) ch.removeComponent(i, C1);
            if (i % 5 == 0) ch.removeComponent(i, C2);
        }

        assertEquals(100, ch.entities.length);
        assertEquals(50, va_.entities.length);
        assertEquals(80, v_b.entities.length);
        assertEquals(40, vab.entities.length);
        assertEquals(100, va_added);
        assertEquals(50, va_removed);
    }


    public function test_mapping_not_push() {
        var ids = [ for (i in 0...100) ch.addComponent(ch.id(false), new C1(), new C2()) ];

        assertEquals(0, ch.entities.length);
        assertEquals(0, va_.entities.length);
        assertEquals(0, v_b.entities.length);
        assertEquals(0, vab.entities.length);
        assertEquals(0, va_added);
        assertEquals(0, va_removed);
    }

    public function test_mapping_push() {
        var ids = [ for (i in 0...100) ch.addComponent(ch.id(false), new C1(), new C2()) ];

        for (id in ids) if (id % 2 == 0) ch.push(id);

        assertEquals(50, ch.entities.length);
        assertEquals(50, va_.entities.length);
        assertEquals(50, v_b.entities.length);
        assertEquals(50, vab.entities.length);
        assertEquals(50, va_added);
        assertEquals(0, va_removed);
    }

    public function test_mapping_poll() {
        var ids = [ for (i in 0...100) ch.addComponent(ch.id(), new C1(), new C2()) ];

        for (id in ids) if (id % 2 == 0) ch.poll(id);

        assertEquals(50, ch.entities.length);
        assertEquals(50, va_.entities.length);
        assertEquals(50, v_b.entities.length);
        assertEquals(50, vab.entities.length);
        assertEquals(100, va_added);
        assertEquals(50, va_removed);
    }

    public function test_mapping_remove() {
        var ids = [ for (i in 0...100) ch.addComponent(ch.id(), new C1(), new C2()) ];

        for (id in ids) if (id % 2 == 0) ch.remove(id);

        assertEquals(50, ch.entities.length);
        assertEquals(50, va_.entities.length);
        assertEquals(50, v_b.entities.length);
        assertEquals(50, vab.entities.length);
        assertEquals(100, va_added);
        assertEquals(50, va_removed);
    }


    public function test_iter_remove() {
        var ids = [ for (i in 0...100) ch.addComponent(ch.id(), new C1(), new C2()) ];

        for (v in vab) if (v.id % 2 == 0) ch.removeComponent(v.id, C1);

        assertEquals(100, ch.entities.length);
        assertEquals(50, va_.entities.length);
        assertEquals(100, v_b.entities.length);
        assertEquals(50, vab.entities.length);
    }


    public function test_add_signal() {
        var aout = '';
        var rout = '';
        var af = function(id:Int) aout += ch.getComponent(id, C1).val;
        var rf = function(id:Int) rout += ch.getComponent(id, C1).val;
        vab.onAdded.add(af);
        vab.onRemoved.add(rf);

        var ids = createQwerty();
        ids.reverse();
        ids.iter(function(id:Int) ch.removeComponent(id, C1));

        assertEquals('QWERTY', aout);
        assertEquals('YTREWQ', rout);
        assertEquals(0, vab.entities.length);
    }

    public function test_add_signal_then_remove_signal() {
        var aout = '';
        var rout = '';
        var af = function(id:Int) aout += ch.getComponent(id, C1).val;
        var rf = function(id:Int) rout += ch.getComponent(id, C1).val;
        vab.onAdded.add(af);
        vab.onRemoved.add(rf);

        vab.onAdded.remove(af);
        vab.onRemoved.remove(rf);

        var ids = createQwerty();
        ids.reverse();
        ids.iter(function(id:Int) ch.removeComponent(id, C1));

        assertEquals('', aout);
        assertEquals('', rout);
        assertEquals(0, vab.entities.length);
    }

    public function test_add_signal_then_remove_view() {
        var aout = '';
        var rout = '';
        var af = function(id:Int) aout += ch.getComponent(id, C1).val;
        var rf = function(id:Int) rout += ch.getComponent(id, C1).val;
        vab.onAdded.add(af);
        vab.onRemoved.add(rf);

        ch.removeView(vab);

        var ids = createQwerty();
        ids.reverse();
        ids.iter(function(id:Int) ch.removeComponent(id, C1));

        assertEquals('', aout);
        assertEquals('', rout);
        assertEquals(0, vab.entities.length);
    }


    override public function tearDown() {
        ch.dispose();
    }

}
