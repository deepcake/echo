package echos;

import echos.core.ISystem;
import echos.utils.LinkedList;

class SystemList implements ISystem {


    var systems = new LinkedList<ISystem>();

    var activated = false;


    public function new() { }


    @:noCompletion @:final public function __activate__() {
        activated = true;
        for (s in systems) {
            s.__activate__();
        }
    }

    @:noCompletion @:final public function __update__(dt:Float) {
        for (s in systems) {
            s.__update__(dt);
        }
    }

    @:noCompletion @:final public function __deactivate__() {
        activated = false;
        for (s in systems) {
            s.__deactivate__();
        }
    }

    public function info(indent:String = ''):String {
        var ret = '$indent(';
        for (s in systems) {
            ret += '\n${ s.info("    " + indent) }';
        }
        ret += '\n$indent)';
        return ret;
    }


    public function add(s:ISystem) {
        if (!exists(s)) {
            systems.add(s);
            if (activated) {
                s.__activate__();
            }
        }
    }

    public function remove(s:ISystem) {
        if (exists(s)) {
            systems.remove(s);
            if (activated) {
                s.__deactivate__();
            }
        }
    }

    public function exists(s:ISystem):Bool {
        return systems.exists(s);
    }


    public function toString():String return 'SystemList';


}
