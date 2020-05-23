package echoes;

import echoes.core.ISystem;
import echoes.utils.LinkedList;

/**
 * SystemList  
 * 
 * List of Systems. Can be used for better update control:  
 * ```
 *   var physics = new SystemList();
 *   physics.add(new MovementSystem());
 *   physics.add(new CollisionResolveSystem());
 *   Workflow.add(physics);
 * ```
 * 
 * @author https://github.com/deepcake
 */
class SystemList implements ISystem {


    #if echoes_profiling
    var __updateTime__ = .0;
    #end


    var name:String;

    var systems = new LinkedList<ISystem>();

    var activated = false;


    public function new(name = 'list') {
        this.name = name;
    }


    @:noCompletion @:final public function __activate__() {
        if (!activated) {
            activated = true;
            for (s in systems) {
                s.__activate__();
            }
        }
    }

    @:noCompletion @:final public function __deactivate__() {
        if (activated) {
            activated = false;
            for (s in systems) {
                s.__deactivate__();
            }
        }
    }

    @:noCompletion @:final public function __update__(dt:Float) {
        #if echoes_profiling
        var __timestamp__ = Date.now().getTime();
        #end

        for (s in systems) {
            s.__update__(dt);
        }

        #if echoes_profiling
        __updateTime__ = Std.int(Date.now().getTime() - __timestamp__);
        #end
    }

    public function isActive():Bool {
        return activated;
    }

    public function info(indent = '    ', level = 0):String {
        var span = StringTools.rpad('', indent, indent.length * level);

        var ret = '$span$name';

        #if echoes_profiling
        ret += ' : $__updateTime__ ms';
        #end

        if (systems.length > 0) {
            for (s in systems) {
                ret += '\n${ s.info(indent, level + 1) }';
            }
        }

        return ret;
    }


    public function add(s:ISystem):SystemList {
        if (!exists(s)) {
            systems.add(s);
            if (activated) {
                s.__activate__();
            }
        }
        return this;
    }

    public function remove(s:ISystem):SystemList {
        if (exists(s)) {
            systems.remove(s);
            if (activated) {
                s.__deactivate__();
            }
        }
        return this;
    }

    public function exists(s:ISystem):Bool {
        return systems.exists(s);
    }


    public function toString():String return 'SystemList';


}
