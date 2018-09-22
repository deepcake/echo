package;

import echo.*;
import data.C;
using Lambda;

class TestIdOp extends haxe.unit.TestCase {

    var ch = new Echo();

    var ids:Array<Int>;
    var i = 0;
    var beforeCount:Int;
    var createCount = 3;

    var componentCount = 0;


    override public function setup() {
        //ids = [ for(i in 0..createCount) ch.addComponent(add(), new C('$i')) ];
        i = 0;
        beforeCount = ch.entities.length;
        componentCount = getComponentCount();
    }


    function add(push = true):Int {
        return ch.addComponent(ch.id(push), new AbstractString('A${i++}'));
    }

    function getAbstractString(i:Int):String {
        return ch.getComponent(i, AbstractString);
    }

    function notNull(s:String):Bool {
        return s != null;
    }

    function getComponentMap(clsname:String):Map<Int, Dynamic> {
        var cls = Type.resolveClass(clsname);
        return cast Reflect.callMethod(cls, Reflect.field(cls, 'get'), [ ch.__id ]);
    }

    function getComponentCount():Int {
        return { iterator: getComponentMap('ComponentMap_data_C_AbstractString').iterator }.count();
    }


    public function test_id_3_with_push() {
        var ids = [ for(i in 0...createCount) add() ];
        assertEquals(beforeCount + createCount, ch.entities.length);
        assertEquals('A0-A1-A2', ids.map(getAbstractString).join('-'));
        assertEquals(componentCount + createCount, getComponentCount());
    }

    public function test_id_3_without_push() {
        var ids = [ for(i in 0...createCount) add(false) ];
        assertEquals(beforeCount, ch.entities.length);
        assertEquals('A0-A1-A2', ids.map(getAbstractString).join('-'));
        assertEquals(componentCount + createCount, getComponentCount());
    }


    public function test_push_1_of_3() {
        var ids = [ for(i in 0...createCount) add(false) ];
        ch.push(ids[1]);
        assertEquals(beforeCount + 1, ch.entities.length);
        assertEquals('A0-A1-A2', ids.map(getAbstractString).join('-'));
        assertEquals(componentCount + createCount, getComponentCount());
    }

    public function test_push_3_of_3() {
        var ids = [ for(i in 0...createCount) add(false) ];
        ch.push(ids[0]);
        ch.push(ids[1]);
        ch.push(ids[2]);
        assertEquals(beforeCount + 3, ch.entities.length);
        assertEquals('A0-A1-A2', ids.map(getAbstractString).join('-'));
        assertEquals(componentCount + createCount, getComponentCount());
    }


    public function test_poll_1_of_0() {
        var ids = [ for(i in 0...createCount) add(false) ];
        ch.poll(ids[1]);
        assertEquals(beforeCount, ch.entities.length);
        assertEquals('A0-A1-A2', ids.map(getAbstractString).join('-'));
        assertEquals(componentCount + createCount, getComponentCount());
    }

    public function test_poll_1_of_3() {
        var ids = [ for(i in 0...createCount) add() ];
        ch.poll(ids[1]);
        assertEquals(beforeCount + createCount - 1, ch.entities.length);
        assertEquals('A0-A1-A2', ids.map(getAbstractString).join('-'));
        assertEquals(componentCount + createCount, getComponentCount());
    }

    public function test_poll_3_of_3() {
        var ids = [ for(i in 0...createCount) add() ];
        ch.poll(ids[0]);
        ch.poll(ids[1]);
        ch.poll(ids[2]);
        assertEquals(beforeCount + createCount - 3, ch.entities.length);
        assertEquals('A0-A1-A2', ids.map(getAbstractString).join('-'));
        assertEquals(componentCount + createCount, getComponentCount());
    }


    public function test_remove_1_of_0() {
        var ids = [ for(i in 0...createCount) add(false) ];
        ch.remove(ids[1]);
        assertEquals(beforeCount, ch.entities.length);
        assertEquals('A0-A2', ids.map(getAbstractString).filter(notNull).join('-'));
        assertEquals(componentCount + createCount - 1, getComponentCount());
    }

    public function test_remove_1_of_3() {
        var ids = [ for(i in 0...createCount) add() ];
        ch.remove(ids[1]);
        assertEquals(beforeCount + createCount - 1, ch.entities.length);
        assertEquals('A0-A2', ids.map(getAbstractString).filter(notNull).join('-'));
        assertEquals(componentCount + createCount - 1, getComponentCount());
    }

     public function test_remove_3_of_3() {
        var ids = [ for(i in 0...createCount) add() ];
        ch.remove(ids[0]);
        ch.remove(ids[1]);
        ch.remove(ids[2]);
        assertEquals(beforeCount + createCount - 3, ch.entities.length);
        assertEquals('', ids.map(getAbstractString).filter(notNull).join('-'));
        assertEquals(componentCount + createCount - 3, getComponentCount());
    }


    public function test_poll_then_push() {
        var id = add();
        ch.poll(id);
        ch.push(id);
        assertEquals(beforeCount + 1, ch.entities.length);
        assertEquals('A0', ch.getComponent(id, AbstractString));
        assertEquals(componentCount + 1, getComponentCount());
    }

    public function test_remove_then_push() {
        var id = add();
        ch.remove(id);
        ch.push(id);
        assertEquals(beforeCount + 1, ch.entities.length);
        assertEquals(null, ch.getComponent(id, AbstractString));
        assertEquals(componentCount, getComponentCount());
    }

}
