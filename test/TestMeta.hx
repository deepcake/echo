package;

import echo.*;
import data.C;
using Lambda;

class TestMeta extends haxe.unit.TestCase {

    var ch:Echo;

    override public function setup() {
        ch = new Echo();
    }


    public function test_workflow() {
        var s = new WorkflowSystem();
        var id = ch.id();

        ch.addComponent(id, new C1(), new C2());
        ch.update(0);

        ch.addSystem(s);
        ch.update(0);

        ch.addComponent(id, new C());
        ch.update(0);

        ch.removeComponent(id, C1);
        ch.update(0);

        ch.removeSystem(s);
        ch.update(0);

        ch.removeComponent(id, C);
        ch.update(0);

        assertEquals('>S+ab(C1;C2) [*ab(C1;C2)] ! +c [*c*ab(C1;C2)] ! -ab(C1;C2) [*c] ! <S', s.out);
    }


    public function test_view_building_by_field() {
        var s = new ViewBuildingByFieldSystem();

        ch.addSystem(s);

        assertTrue(ch.hasView(VC0));
        assertTrue(ch.hasView(VC1));
        assertTrue(ch.hasView(VC2));
        assertTrue(ch.hasView(VC3));
        assertTrue(ch.hasView(VC01));
        assertTrue(ch.hasView(VC02));
        assertFalse(ch.hasView(VC1C2));
        assertEquals(6, ch.views.length);
    }

    public function test_view_building_by_meta() {
        var s = new ViewBuildingByMetaSystem();

        ch.addSystem(s);

        assertTrue(ch.hasView(VC0));
        assertTrue(ch.hasView(VC1));
        assertTrue(ch.hasView(VC2));
        assertTrue(ch.hasView(VC3));
        assertFalse(ch.hasView(VC1C2));
        assertEquals(4, ch.views.length);
    }

}


private class WorkflowSystem extends System {

    public var out = '';
    var ab:View<{ a:C1, b:C2 }>;

    override public function onactivate() {
        out += '>S';
    }

    override public function ondeactivate() {
        out += '<S';
    }

    override public function update(dt:Float) {
        out += '! ';
    }


    @a public function on_c_add(c:C) {
        out += '+c';
    }
    @r public function on_c_remove(cCustomName:C) {
        out += '-c';
    }


    @a inline function on_ab_add(c1:C1, customName2:C2) {
        out += '+ab(${c1.val};${customName2.val})';
    }
    @r inline function on_ab_remove(customName1:C1, c2:C2) {
        out += '-ab(${customName1.val};${c2.val})';
    }


    @u inline function on_before_update_space() {
        out += ' ';
    }

    @u function on_before_update() {
        out += '[';
    }

    @u function on_c_update(c_:C) {
        out += '*c';
    }

    @u function on_ab_update(aCustomName:C1, bCustomName:C2) {
        out += '*ab(${aCustomName.val};${bCustomName.val})';
    }

    @u function on_after_update() {
        out += ']';
    }

    @u inline function on_after_update_space() {
        out += ' ';
    }

}


private class ViewBuildingByFieldSystem extends System {
    var vc0:VC0;
    var vc1 = new VC1();
    var vc2:View<{ c2:C2 }>;
    var vc3 = new View<{ c3:C3 }>();
    var vc01:VC01;
    var vc02:View<VD02>;
    @i var vc0c1:VC1C2;
}

private class ViewBuildingByMetaSystem extends System {
    var vc3:VC3;
    var r = 1;
    @a function ad(c:C0) r++;
    @r function rm(c:C1) r++;
    @u function up1(c:C2) r++;
    @u function up2(c:C3) r++;
    @i @u function up3(a:C1, b:C2) r++;
}


private typedef VC1C2 = View<{ a:C1, b:C2 }>;
private typedef VC0 = View<{ c0:C0 }>;
private typedef VC1 = View<{ c1:C1 }>;
private typedef VC2 = View<{ c2:C2 }>;
private typedef VC3 = View<{ c3:C3 }>;
private typedef VD01 = { c0:C0, c1:C1 };
private typedef VD02 = { c0:C0, c2:C2 };
private typedef VC01 = View<VD01>;
private typedef VC02 = View<VD02>;
