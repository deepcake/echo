package echos;

import echos.Entity.Status;

#if macro
import haxe.macro.Expr;
using echos.macro.MacroTools;
using haxe.macro.Context;
using Lambda;
#end

/**
 *  
 *  
 * @author https://github.com/deepcake
 */
class Workflow {


    static var __nextEntityId = 0;

    static var entityCache = new Array<Int>();
    static var entityStatuses = new Map<Int, Status>();

    static var containers = new Array<echos.macro.ComponentBuilder.DestroyableRemovableComponentContainer>();

    @:noCompletion public static #if haxe4 final #else var #end entities = new List<Entity>();
    @:noCompletion public static #if haxe4 final #else var #end views = new List<View.ViewBase>();
    @:noCompletion public static #if haxe4 final #else var #end systems = new List<System>();


    #if echos_profiling
    static var times = new Map<String, Float>();
    #end


    /**
     * Returns the workflow statistics:  
     * _( systems count ) { views count } [ entities count | entity cache size ]_  
     * With `echos_profiling` flag additionaly returns:  
     * _( system name ) : time for update ms_  
     * _{ view name } [ collected entities count ]_  
     * @return String
     */
    public static function toString():String {
        var ret = '# ( ${systems.length} ) { ${views.length} } [ ${entities.length} | ${entityCache.length} ]'; // TODO version or something

        #if echos_profiling
        ret += ' : ${ times.get("total") } ms'; // total
        for (s in systems) {
            ret += '\n        ($s) : ${ times.get(s.toString()) } ms';
        }
        for (v in views) {
            ret += '\n    {$v} [${v.entities.length}]';
        }
        #end

        return ret;
    }


    /**
     * Update 
     * @param dt deltatime
     */
    public static function update(dt:Float) {
        #if echos_profiling
        var engineUpdateStartTimestamp = Date.now().getTime();
        #end

        for (s in systems) {
            #if echos_profiling
            var systemUpdateStartTimestamp = Date.now().getTime();
            #end

            s.__update(dt);

            #if echos_profiling
            times.set(s.toString(), Std.int(Date.now().getTime() - systemUpdateStartTimestamp));
            #end
        }

        for (v in views) {
            v.flush();
        }

        #if echos_profiling
        times.set("total", Std.int(Date.now().getTime() - engineUpdateStartTimestamp));
        #end
    }


    /**
     * Removes all views, systems and entities from the workflow, and resets the id sequence 
     */
    public static function dispose() {
        for (e in entities) {
            e.destroy();
        }
        for (s in systems) {
            removeSystem(s);
        }
        for (v in views) {
            v.dispose();
        }
        for (cc in containers) {
            cc.dispose();
        }
        while (entityCache.length > 0) {
            entityCache.pop();
        }
        while (--__nextEntityId > -1) {
            entityStatuses.remove(__nextEntityId);
        }
        __nextEntityId = 0;
    }


    /**
     * Returns the view of passed component types 
     * @param types list of component types
     * @return `View`
     */
    macro public static inline function getView(types:Array<ExprOf<Class<Any>>>) {
        var components = types
            .map(function(type) return type.identName().getType().follow().toComplexType())
            .map(function(ct)return { name: ct.tp().name.toLowerCase(), cls: ct })
            .array();
        var viewComplexType = echos.macro.ViewBuilder.createViewType(components).toComplexType();
        var viewClsName = viewComplexType.followName();
        return macro $i{viewClsName}.inst();
    }


    // System

    /**
     * Adds the system to the workflow
     * @param s `System` instance
     */
    public static function addSystem(s:System) {
        if (!hasSystem(s)) {
            systems.add(s);
            s.__activate();
        }
    }

    /**
     * Removes the system from the workflow
     * @param s `System` instance
     */
    public static function removeSystem(s:System) {
        if (hasSystem(s)) {
            s.__deactivate();
            systems.remove(s);
        }
    }

    /**
     * Returns `true` if the system is added to the workflow, otherwise returns `false`  
     * @param s `System` instance
     * @return `Bool`
     */
    public static function hasSystem(s:System):Bool {
        for (system in systems) {
            if (system == s) return true;
        }
        return false;
    }


    // Entity

    @:allow(echos.Entity) static function id(immediate:Bool):Int {
        var id = entityCache.length > 0 ? entityCache.pop() : __nextEntityId++;
        if (immediate) {
            entityStatuses[id] = Active;
            entities.add(id);
        } else {
            entityStatuses[id] = Inactive;
        }
        return id;
    }

    @:allow(echos.Entity) static function free(id:Int) {
        // TODO debug check Unknown status
        if (status(id) < Cached) { // Active or Inactive
            remove(id);
            removeComponents(id);
            entityCache.push(id);
            entityStatuses[id] = Cached;
        }
    }

    @:allow(echos.Entity) static function add(id:Int) {
        if (status(id) == Inactive) {
            entityStatuses[id] = Active;
            entities.add(id);
            for (v in views) v.addIfMatch(id);
        }
    }

    @:allow(echos.Entity) static function remove(id:Int) {
        if (status(id) == Active) {
            for (v in views) v.removeIfMatch(id);
            entities.remove(id);
            entityStatuses[id] = Inactive;
        }
    }

    @:allow(echos.Entity) static inline function status(id:Int):Status {
        return entityStatuses.exists(id) ? entityStatuses[id] : Invalid;
    }

    @:allow(echos.Entity) static inline function removeComponents(id:Int) {
        if (status(id) == Active) {
            for (v in views) {
                v.removeIfMatch(id);
            }
        }
        for (cc in containers) {
            cc.remove(id);
        }
    }


}
