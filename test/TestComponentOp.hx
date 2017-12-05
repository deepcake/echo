package;

import echo.*;
import data.C;
using Lambda;

class TestComponentOp extends haxe.unit.TestCase {

    var ch = new Echo();

    var c_:C;
    var c1:C1;
    var c2:C2;

    var beforeCount:Int;

    var c_Count:Int = 0;
    var c1Count:Int = 0;
    var c2Count:Int = 0;


    override public function setup() {
        c_ = new C('C_');
        c1 = new C1('C1');
        c2 = new C2('C2');
        beforeCount = ch.entities.length;
        c_Count = getComponentCount('C');
        c1Count = getComponentCount('C_C1');
        c2Count = getComponentCount('C_C2');
    }


    function getComponentMap(clsname:String):Map<Int, Dynamic> {
        var cls = Type.resolveClass(clsname);
        return cast Reflect.callMethod(cls, Reflect.field(cls, 'get'), [ ch.__id ]);
    }

    function getComponentCount(cname:String):Int {
        return { iterator: getComponentMap('ComponentMap_data_$cname').iterator }.count();
    }


    public function test_add_0() {
        var id = ch.addComponent(ch.id());

        assertEquals(beforeCount + 1, ch.entities.length);
        assertEquals(null, ch.getComponent(id, C));
        assertEquals(null, ch.getComponent(id, C1));
        assertEquals(null, ch.getComponent(id, C2));
        assertEquals(false, ch.hasComponent(id, C));
        assertEquals(false, ch.hasComponent(id, C1));
        assertEquals(false, ch.hasComponent(id, C2));
        assertEquals(c_Count, getComponentCount('C'));
        assertEquals(c1Count, getComponentCount('C_C1'));
        assertEquals(c2Count, getComponentCount('C_C2'));
    }

    public function test_add_1() {
        var id = ch.addComponent(ch.id(), c1);

        assertEquals(beforeCount + 1, ch.entities.length);
        assertEquals(null, ch.getComponent(id, C));
        assertEquals(c1, ch.getComponent(id, C1));
        assertEquals(null, ch.getComponent(id, C2));
        assertEquals(false, ch.hasComponent(id, C));
        assertEquals(true, ch.hasComponent(id, C1));
        assertEquals(false, ch.hasComponent(id, C2));
        assertEquals(c_Count, getComponentCount('C'));
        assertEquals(c1Count + 1, getComponentCount('C_C1'));
        assertEquals(c2Count, getComponentCount('C_C2'));
    }

    public function test_add_3() {
        var id = ch.addComponent(ch.id(), c1, c2, c_);

        assertEquals(beforeCount + 1, ch.entities.length);
        assertEquals(c_, ch.getComponent(id, C));
        assertEquals(c1, ch.getComponent(id, C1));
        assertEquals(c2, ch.getComponent(id, C2));
        assertEquals(true, ch.hasComponent(id, C));
        assertEquals(true, ch.hasComponent(id, C1));
        assertEquals(true, ch.hasComponent(id, C2));
        assertEquals(c_Count + 1, getComponentCount('C'));
        assertEquals(c1Count + 1, getComponentCount('C_C1'));
        assertEquals(c2Count + 1, getComponentCount('C_C2'));
    }


    public function test_add_3_sequentially() {
        var id = ch.id();
        ch.addComponent(id, c1);
        ch.addComponent(id, c2);
        ch.addComponent(id, c_);

        assertEquals(beforeCount + 1, ch.entities.length);
        assertEquals(c_, ch.getComponent(id, C));
        assertEquals(c1, ch.getComponent(id, C1));
        assertEquals(c2, ch.getComponent(id, C2));
        assertEquals(true, ch.hasComponent(id, C));
        assertEquals(true, ch.hasComponent(id, C1));
        assertEquals(true, ch.hasComponent(id, C2));
        assertEquals(c_Count + 1, getComponentCount('C'));
        assertEquals(c1Count + 1, getComponentCount('C_C1'));
        assertEquals(c2Count + 1, getComponentCount('C_C2'));
    }


    public function test_add_0_without_push() {
        var id = ch.addComponent(ch.id(false));

        assertEquals(beforeCount, ch.entities.length);
        assertEquals(null, ch.getComponent(id, C));
        assertEquals(null, ch.getComponent(id, C1));
        assertEquals(null, ch.getComponent(id, C2));
        assertEquals(false, ch.hasComponent(id, C));
        assertEquals(false, ch.hasComponent(id, C1));
        assertEquals(false, ch.hasComponent(id, C2));
        assertEquals(c_Count, getComponentCount('C'));
        assertEquals(c1Count, getComponentCount('C_C1'));
        assertEquals(c2Count, getComponentCount('C_C2'));
    }

    public function test_add_1_without_push() {
        var id = ch.addComponent(ch.id(false), c1);

        assertEquals(beforeCount, ch.entities.length);
        assertEquals(null, ch.getComponent(id, C));
        assertEquals(c1, ch.getComponent(id, C1));
        assertEquals(null, ch.getComponent(id, C2));
        assertEquals(false, ch.hasComponent(id, C));
        assertEquals(true, ch.hasComponent(id, C1));
        assertEquals(false, ch.hasComponent(id, C2));
        assertEquals(c_Count, getComponentCount('C'));
        assertEquals(c1Count + 1, getComponentCount('C_C1'));
        assertEquals(c2Count, getComponentCount('C_C2'));
    }

    public function test_add_3_without_push() {
        var id = ch.addComponent(ch.id(false), c1, c2, c_);

        assertEquals(beforeCount, ch.entities.length);
        assertEquals(c_, ch.getComponent(id, C));
        assertEquals(c1, ch.getComponent(id, C1));
        assertEquals(c2, ch.getComponent(id, C2));
        assertEquals(true, ch.hasComponent(id, C));
        assertEquals(true, ch.hasComponent(id, C1));
        assertEquals(true, ch.hasComponent(id, C2));
        assertEquals(c_Count + 1, getComponentCount('C'));
        assertEquals(c1Count + 1, getComponentCount('C_C1'));
        assertEquals(c2Count + 1, getComponentCount('C_C2'));
    }


    public function test_set_0_to_0() {
        var id = ch.addComponent(ch.id());
        var nd = ch.addComponent(id);

        assertEquals(id, nd);
        assertEquals(beforeCount + 1, ch.entities.length);
        assertEquals(null, ch.getComponent(id, C));
        assertEquals(null, ch.getComponent(id, C1));
        assertEquals(null, ch.getComponent(id, C2));
        assertEquals(false, ch.hasComponent(id, C));
        assertEquals(false, ch.hasComponent(id, C1));
        assertEquals(false, ch.hasComponent(id, C2));
        assertEquals(c_Count, getComponentCount('C'));
        assertEquals(c1Count, getComponentCount('C_C1'));
        assertEquals(c2Count, getComponentCount('C_C2'));
    }

    public function test_set_1_to_0() {
        var id = ch.addComponent(ch.id());

        var n0 = new C('Hi!');
        var nd = ch.addComponent(id, n0);

        assertEquals(id, nd);
        assertEquals(beforeCount + 1, ch.entities.length);
        assertEquals(n0, ch.getComponent(id, C));
        assertEquals(null, ch.getComponent(id, C1));
        assertEquals(null, ch.getComponent(id, C2));
        assertEquals(true, ch.hasComponent(id, C));
        assertEquals(false, ch.hasComponent(id, C1));
        assertEquals(false, ch.hasComponent(id, C2));
        assertEquals(c_Count + 1, getComponentCount('C'));
        assertEquals(c1Count, getComponentCount('C_C1'));
        assertEquals(c2Count, getComponentCount('C_C2'));
    }

    public function test_set_1_to_1() {
        var id = ch.addComponent(ch.id(), c_);

        var n0 = new C('Hi!');
        var nd = ch.addComponent(id, n0);

        assertEquals(id, nd);
        assertEquals(beforeCount + 1, ch.entities.length);
        assertEquals(n0, ch.getComponent(id, C));
        assertEquals(null, ch.getComponent(id, C1));
        assertEquals(null, ch.getComponent(id, C2));
        assertEquals(true, ch.hasComponent(id, C));
        assertEquals(false, ch.hasComponent(id, C1));
        assertEquals(false, ch.hasComponent(id, C2));
        assertEquals(c_Count + 1, getComponentCount('C'));
        assertEquals(c1Count, getComponentCount('C_C1'));
        assertEquals(c2Count, getComponentCount('C_C2'));
    }

    public function test_set_1_to_3() {
        var id = ch.addComponent(ch.id(), c1, c2, c_);

        var n0 = new C('Hi!');
        var nd = ch.addComponent(id, n0);

        assertEquals(id, nd);
        assertEquals(beforeCount + 1, ch.entities.length);
        assertEquals(n0, ch.getComponent(id, C));
        assertEquals(c1, ch.getComponent(id, C1));
        assertEquals(c2, ch.getComponent(id, C2));
        assertEquals(true, ch.hasComponent(id, C));
        assertEquals(true, ch.hasComponent(id, C1));
        assertEquals(true, ch.hasComponent(id, C2));
        assertEquals(c_Count + 1, getComponentCount('C'));
        assertEquals(c1Count + 1, getComponentCount('C_C1'));
        assertEquals(c2Count + 1, getComponentCount('C_C2'));
    }

    public function test_set_3_to_1() {
        var id = ch.addComponent(ch.id(), c_);

        var n0 = new C('Okay');
        var n1 = new C1('Hi!');
        var n2 = new C2('Hi!');
        var nd = ch.addComponent(id, n1, n2, n0);

        assertEquals(id, nd);
        assertEquals(beforeCount + 1, ch.entities.length);
        assertEquals(n0, ch.getComponent(id, C));
        assertEquals(n1, ch.getComponent(id, C1));
        assertEquals(n2, ch.getComponent(id, C2));
        assertEquals(true, ch.hasComponent(id, C));
        assertEquals(true, ch.hasComponent(id, C1));
        assertEquals(true, ch.hasComponent(id, C2));
        assertEquals(c_Count + 1, getComponentCount('C'));
        assertEquals(c1Count + 1, getComponentCount('C_C1'));
        assertEquals(c2Count + 1, getComponentCount('C_C2'));
    }


    public function test_set_1_to_3_without_push() {
        var id = ch.addComponent(ch.id(false), c1, c2, c_);

        var n0 = new C('Hi!');
        var nd = ch.addComponent(id, n0);

        assertEquals(id, nd);
        assertEquals(beforeCount, ch.entities.length);
        assertEquals(n0, ch.getComponent(id, C));
        assertEquals(c1, ch.getComponent(id, C1));
        assertEquals(c2, ch.getComponent(id, C2));
        assertEquals(true, ch.hasComponent(id, C));
        assertEquals(true, ch.hasComponent(id, C1));
        assertEquals(true, ch.hasComponent(id, C2));
        assertEquals(c_Count + 1, getComponentCount('C'));
        assertEquals(c1Count + 1, getComponentCount('C_C1'));
        assertEquals(c2Count + 1, getComponentCount('C_C2'));
    }


    public function test_remove_0_of_3() {
        var id = ch.addComponent(ch.id(), c_, c1, c2);

        ch.removeComponent(id);

        assertEquals(beforeCount + 1, ch.entities.length);
        assertEquals(c_, ch.getComponent(id, C));
        assertEquals(c1, ch.getComponent(id, C1));
        assertEquals(c2, ch.getComponent(id, C2));
        assertEquals(true, ch.hasComponent(id, C));
        assertEquals(true, ch.hasComponent(id, C1));
        assertEquals(true, ch.hasComponent(id, C2));
        assertEquals(c_Count + 1, getComponentCount('C'));
        assertEquals(c1Count + 1, getComponentCount('C_C1'));
        assertEquals(c2Count + 1, getComponentCount('C_C2'));
    }

    public function test_remove_3_of_0() {
        var id = ch.addComponent(ch.id());

        ch.removeComponent(id, C1, C2, C);

        assertEquals(beforeCount + 1, ch.entities.length);
        assertEquals(null, ch.getComponent(id, C));
        assertEquals(null, ch.getComponent(id, C1));
        assertEquals(null, ch.getComponent(id, C2));
        assertEquals(false, ch.hasComponent(id, C));
        assertEquals(false, ch.hasComponent(id, C1));
        assertEquals(false, ch.hasComponent(id, C2));
        assertEquals(c_Count, getComponentCount('C'));
        assertEquals(c1Count, getComponentCount('C_C1'));
        assertEquals(c2Count, getComponentCount('C_C2'));
    }

    public function test_remove_1_of_3() {
        var id = ch.addComponent(ch.id(), c_, c1, c2);

        ch.removeComponent(id, C1);

        assertEquals(beforeCount + 1, ch.entities.length);
        assertEquals(c_, ch.getComponent(id, C));
        assertEquals(null, ch.getComponent(id, C1));
        assertEquals(c2, ch.getComponent(id, C2));
        assertEquals(true, ch.hasComponent(id, C));
        assertEquals(false, ch.hasComponent(id, C1));
        assertEquals(true, ch.hasComponent(id, C2));
        assertEquals(c_Count + 1, getComponentCount('C'));
        assertEquals(c1Count, getComponentCount('C_C1'));
        assertEquals(c2Count + 1, getComponentCount('C_C2'));
    }

    public function test_remove_3_of_3() {
        var id = ch.addComponent(ch.id(), c_, c1, c2);

        ch.removeComponent(id, C1, C2, C);

        assertEquals(beforeCount + 1, ch.entities.length);
        assertEquals(null, ch.getComponent(id, C));
        assertEquals(null, ch.getComponent(id, C1));
        assertEquals(null, ch.getComponent(id, C2));
        assertEquals(false, ch.hasComponent(id, C));
        assertEquals(false, ch.hasComponent(id, C1));
        assertEquals(false, ch.hasComponent(id, C2));
        assertEquals(c_Count, getComponentCount('C'));
        assertEquals(c1Count, getComponentCount('C_C1'));
        assertEquals(c2Count, getComponentCount('C_C2'));
    }


    public function test_remove_3_of_3_sequentially() {
        var id = ch.addComponent(ch.id(), c_, c1, c2);

        ch.removeComponent(id, C1);
        ch.removeComponent(id, C2);
        ch.removeComponent(id, C);

        assertEquals(beforeCount + 1, ch.entities.length);
        assertEquals(null, ch.getComponent(id, C));
        assertEquals(null, ch.getComponent(id, C1));
        assertEquals(null, ch.getComponent(id, C2));
        assertEquals(false, ch.hasComponent(id, C));
        assertEquals(false, ch.hasComponent(id, C1));
        assertEquals(false, ch.hasComponent(id, C2));
        assertEquals(c_Count, getComponentCount('C'));
        assertEquals(c1Count, getComponentCount('C_C1'));
        assertEquals(c2Count, getComponentCount('C_C2'));
    }


    public function test_remove_1_of_3_without_push() {
        var id = ch.addComponent(ch.id(false), c_, c1, c2);

        ch.removeComponent(id, C1);

        assertEquals(beforeCount, ch.entities.length);
        assertEquals(c_, ch.getComponent(id, C));
        assertEquals(null, ch.getComponent(id, C1));
        assertEquals(c2, ch.getComponent(id, C2));
        assertEquals(true, ch.hasComponent(id, C));
        assertEquals(false, ch.hasComponent(id, C1));
        assertEquals(true, ch.hasComponent(id, C2));
        assertEquals(c_Count + 1, getComponentCount('C'));
        assertEquals(c1Count, getComponentCount('C_C1'));
        assertEquals(c2Count + 1, getComponentCount('C_C2'));
    }


    public function test_add_same_instance() {
        var id1 = ch.addComponent(ch.id(), c_);
        var id2 = ch.addComponent(ch.id(), c_);

        assertEquals(beforeCount + 2, ch.entities.length);
        assertEquals(c_, ch.getComponent(id1, C));
        assertEquals(c_, ch.getComponent(id2, C));
        assertEquals(true, ch.hasComponent(id1, C));
        assertEquals(true, ch.hasComponent(id2, C));
        assertEquals(c_Count + 2, getComponentCount('C'));
    }

}
