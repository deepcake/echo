package echos;

import echos.utils.LinkedList;

class SystemList implements echos.core.ISystem {


    var systems = new LinkedList<System>();

    var activated = false;


    public function new() { }


    @:noCompletion @:final public function __activate__() {
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
        for (s in systems) {
            s.__deactivate__();
        }
    }


    public function add(s:System) {
        systems.add(s);
        if (activated) {
            s.__activate__();
        }
    }

    public function remove(s:System) {
        systems.remove(s);
        if (!activated) {
            s.__deactivate__();
        }
    }

    public function exists(s:System) {
        systems.exists(s);
    }


    public function toString():String return 'SystemList';


    #if echos_profiling
    @:noCompletion public function info():String {
        var ret = '[';
        for (s in systems) {
            ret += '\n    ${ s.info() }';
        }
        ret += '\n]';
        return ret;
    }
    #end


}
