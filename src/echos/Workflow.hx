package echos;

import echos.Entity.Status;

#if macro
import echos.macro.*;
import haxe.macro.Expr;
import haxe.macro.Type;
using haxe.macro.Context;
using echos.macro.Macro;
using Lambda;
#end

/**
 * ...
 * @author https://github.com/deepcake
 */
class Workflow {


    static var __entitySequence = -1;


    static var __componentContainers = new Array<echos.macro.ComponentMacro.ComponentContainer<Dynamic>>();

    static function regComponentContainer(cc:echos.macro.ComponentMacro.ComponentContainer<Dynamic>) {
        __componentContainers.push(cc);
    }


    static var idsCache = new Array<Int>();
    static var ids = new Map<Int, Status>();

    public static var entities(default, null) = new List<Entity>();
    public static var views(default, null) = new List<View.ViewBase>();
    public static var systems(default, null) = new List<System>();


    function new() { }


    #if echos_profiling
    static var times = new Map<Int, Float>();
    #end
    /**
    * Returns the workflow statistics:  
    * ( _systems count_ ) { _views count_ } [ _entities count_ | _entity cache size_ ]  
    * With `echos_profiling` flag additionaly returns:  
    * ( _system name_ ) : _time for update_ ms  
    * { _view name_ } [ _collected entities count_ ]  
    * @return String
     */
    public static function toString():String {
        var ret = '# ( ${systems.length} ) { ${views.length} } [ ${entities.length} | ${idsCache.length} ]'; // TODO version or something

        #if echos_profiling
        ret += ' : ${ times.get(-2) } ms'; // total
        for (s in systems) {
            ret += '\n        ($s) : ${ times.get(s.__id) } ms';
        }
        for (v in views) {
            ret += '\n    {$v} [${v.entities.length}]';
        }
        #end

        return ret;
    }


    /**
     * Update
     * @param dt - delta time
     */
    public static function update(dt:Float) {
        #if echos_profiling
        var engineUpdateStartTimestamp = Date.now().getTime();
        #end

        for (s in systems) {
            #if echos_profiling
            var systemUpdateStartTimestamp = Date.now().getTime();
            #end

            s.update(dt);

            #if echos_profiling
            times.set(s.__id, Std.int(Date.now().getTime() - systemUpdateStartTimestamp));
            #end
        }

        #if echos_profiling
        times.set(-2, Std.int(Date.now().getTime() - engineUpdateStartTimestamp));
        #end
    }


    /**
    * Removes all views, systems and entities and resets the id sequence
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
        for (cc in __componentContainers) {
            cc.dispose();
        }
        while (idsCache.length > 0) {
            idsCache.pop();
        }
        while (__entitySequence > -1) {
            ids.remove(__entitySequence);
            --__entitySequence;
        }
    }


    /**
    * Returns the view of passed component types
    * @param types - list of component types
    * @return View<>
     */
    macro public static inline function getView(types:Array<ExprOf<Class<Any>>>) {
        var components = types
            .map(function(type) return type.identName().getType().follow().toComplexType())
            .map(function(ct)return { name: ct.tp().name.toLowerCase(), cls: ct })
            .array();
        var viewComplexType = ViewMacro.createViewType(components).toComplexType();
        return macro ${ viewComplexType.expr(Context.currentPos()) }.inst();
    }


    // System

    /**
     * Adds system to the workflow
     * @param s `System` instance
     */
    public static function addSystem(s:System) {
        systems.add(s);
        s.activate();
    }

    /**
     * Removes system from the workflow
     * @param s `System` instance
     */
    public static function removeSystem(s:System) {
        s.deactivate();
        systems.remove(s);
    }


    // Entity

    @:allow(echos.Entity) static function id(immediate:Bool):Int {
        var id = idsCache.length > 0 ? idsCache.pop() : ++__entitySequence;
        if (immediate) {
            ids.set(id, Active);
            entities.add(id);
        } else {
            ids.set(id, Inactive);
        }
        return id;
    }

    @:allow(echos.Entity) static function cache(id:Int) {
        // TODO debug check Unknown status
        if (status(id) < Cached) { // Active or Inactive
            remove(id);
            removeComponents(id);
            idsCache.push(id);
            ids.set(id, Cached);
        }
    }

    @:allow(echos.Entity) static function add(id:Int) {
        if (status(id) == Inactive) {
            ids.set(id, Active);
            entities.add(id);
            for (v in views) v.addIfMatch(id);
        }
    }

    @:allow(echos.Entity) static function remove(id:Int) {
        if (status(id) == Active) {
            for (v in views) v.removeIfMatch(id);
            entities.remove(id);
            ids.set(id, Inactive);
        }
    }

    @:allow(echos.Entity) static inline function status(id:Int):Status {
        return ids.exists(id) ? ids.get(id) : Invalid;
    }

    @:allow(echos.Entity) static function removeComponents(id:Int) {
        for (cc in __componentContainers) {
            cc.remove(id);
        }
    }


}
