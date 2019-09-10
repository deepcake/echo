package echos;

import echos.Entity.Status;
import echos.core.AbstractView;
import echos.core.ICleanableComponentContainer;
import echos.core.RestrictedLinkedList;

/**
 *  
 *  
 * @author https://github.com/deepcake
 */
class Workflow {


    @:allow(echos.Entity) static inline var INVALID_ID = 0;


    static var nextId = INVALID_ID + 1;

    static var idPool = new Array<Int>();
    static var idStatuses = new Map<Int, Status>();

    // all of every defined component container
    static var definedContainers = new Array<ICleanableComponentContainer>();
    // all of every defined view
    static var definedViews = new Array<AbstractView>();


    public static var entities(default, null) = new RestrictedLinkedList<Entity>();
    public static var views(default, null) = new RestrictedLinkedList<AbstractView>();
    public static var systems(default, null) = new RestrictedLinkedList<System>();


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
        var ret = '# ( ${systems.length} ) { ${views.length} } [ ${entities.length} | ${idPool.length} ]'; // TODO version or something

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

            s.__update__(dt);

            #if echos_profiling
            times.set(s.toString(), Std.int(Date.now().getTime() - systemUpdateStartTimestamp));
            #end
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
        for (v in definedViews) {
            v.dispose();
        }
        for (c in definedContainers) {
            c.dispose();
        }
        while (idPool.length > 0) {
            idPool.pop();
        }
        while (--nextId > -1) {
            idStatuses.remove(nextId);
        }
        nextId = INVALID_ID + 1;
    }


    // System

    /**
     * Adds the system to the workflow
     * @param s `System` instance
     */
    public static function addSystem(s:System) {
        if (!hasSystem(s)) {
            systems.add(s);
            s.__activate__();
        }
    }

    /**
     * Removes the system from the workflow
     * @param s `System` instance
     */
    public static function removeSystem(s:System) {
        if (hasSystem(s)) {
            s.__deactivate__();
            systems.remove(s);
        }
    }

    /**
     * Returns `true` if the system is added to the workflow, otherwise returns `false`  
     * @param s `System` instance
     * @return `Bool`
     */
    public static function hasSystem(s:System):Bool {
        return systems.exists(s);
    }


    // Entity

    @:allow(echos.Entity) static function id(immediate:Bool):Int {
        var id = idPool.length > 0 ? idPool.pop() : nextId++;
        if (immediate) {
            idStatuses[id] = Active;
            entities.add(id);
        } else {
            idStatuses[id] = Inactive;
        }
        return id;
    }

    @:allow(echos.Entity) static function free(id:Int) {
        // TODO debug check Unknown status
        if (status(id) < Cached) { // Active or Inactive
            remove(id);
            removeComponents(id);
            idPool.push(id);
            idStatuses[id] = Cached;
        }
    }

    @:allow(echos.Entity) static function add(id:Int) {
        if (status(id) == Inactive) {
            idStatuses[id] = Active;
            entities.add(id);
            for (v in views) v.addIfMatch(id);
        }
    }

    @:allow(echos.Entity) static function remove(id:Int) {
        if (status(id) == Active) {
            for (v in views) v.removeIfMatch(id);
            entities.remove(id);
            idStatuses[id] = Inactive;
        }
    }

    @:allow(echos.Entity) static inline function status(id:Int):Status {
        return idStatuses.exists(id) ? idStatuses[id] : Invalid;
    }

    @:allow(echos.Entity) static inline function removeComponents(id:Int) {
        if (status(id) == Active) {
            for (v in views) {
                v.removeIfMatch(id);
            }
        }
        for (c in definedContainers) {
            c.remove(id);
        }
    }


}
