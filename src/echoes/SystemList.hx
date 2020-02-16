package echoes;

import echoes.core.ISystem;
import echoes.utils.LinkedList;
import echoes.utils.Timestep;

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


    var systems = new LinkedList<ISystem>();

    var activated = false;

	var timestep:Timestep;

	public function new(?timestep:Timestep) {
        this.timestep = timestep != null ? timestep : new Timestep();
    }


    @:noCompletion @:final public function __activate__() {
        activated = true;
        for (s in systems) {
            s.__activate__();
        }
    }

    @:noCompletion @:final public function __update__(dt:Float) {
		timestep.advance(dt);
		for(step in timestep) {
			for (s in systems) {
                s.__update__(step);
            }
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
