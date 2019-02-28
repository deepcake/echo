package echo;

#if macro
import echo.macro.*;
import haxe.macro.Expr;
using haxe.macro.Context;
using echo.macro.Macro;
using Lambda;
#end

/**
 * ...
 * @author https://github.com/deepcake
 */
class Echo {


    static var __componentSequence = -1;


    static var componentContainers:Array<echo.macro.IComponentContainer<Dynamic>> = [];

    static function regComponentContainer(cc:echo.macro.IComponentContainer<Dynamic>) {
        componentContainers.push(cc);
    }


    static var instance = new Echo();

    @:keep inline public static function inst() {
        return instance;
    }


    @:noCompletion public var entitiesMap:Map<Entity, Int> = new Map(); // map (id : id)
    @:noCompletion public var viewsMap:Map<Int, View.ViewBase> = new Map();
    @:noCompletion public var systemsMap:Map<Int, System> = new Map();

    /** List of added entities */
    public var entities(default, null):List<Entity> = new List();
    /** List of added views */
    public var views(default, null):List<View.ViewBase> = new List();
    /** List of added systems */
    public var systems(default, null):List<System> = new List();


    public function new() { }


    #if echo_profiling
    var times:Map<Int, Float> = new Map();
    #end
    public function toString():String {
        var ret = '# ( ${systems.length} ) { ${views.length} } [ ${entities.length} ]'; // TODO version or something

        #if echo_profiling
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
    public function update(dt:Float) {
        #if echo_profiling
        var engineUpdateStartTimestamp = Date.now().getTime();
        #end

        for (s in systems) {
            #if echo_profiling
            var systemUpdateStartTimestamp = Date.now().getTime();
            #end

            s.update(dt);

            #if echo_profiling
            times.set(s.__id, Std.int(Date.now().getTime() - systemUpdateStartTimestamp));
            #end
        }

        #if echo_profiling
        times.set(-2, Std.int(Date.now().getTime() - engineUpdateStartTimestamp));
        #end
    }


    /**
    * Removes all views, systems and entities
     */
    public function dispose() {
        for (e in entities) e.destroy();
        for (s in systems) removeSystem(s);
        for (v in views) v.deactivate();
    }


    // System

    /**
     * Adds system to the workflow
     * @param s `System` instance
     */
    public function addSystem(s:System) {
        if (!systemsMap.exists(s.__id)) {
            systemsMap[s.__id] = s;
            systems.add(s);
            s.activate();
        }
    }

    /**
     * Removes system from the workflow
     * @param s `System` instance
     */
    public function removeSystem(s:System) {
        if (systemsMap.exists(s.__id)) {
            s.deactivate();
            systemsMap.remove(s.__id);
            systems.remove(s);
        }
    }


    // View

    function addView(v:View.ViewBase) {
        if (!viewsMap.exists(v.__id)) {
            viewsMap[v.__id] = v;
            views.add(v);
        }
    }

    function removeView(v:View.ViewBase) {
        if (viewsMap.exists(v.__id)) {
            viewsMap.remove(v.__id);
            views.remove(v);
        }
    }


    // Entity

    @:allow(echo.Entity) function id(immediate:Bool):Int {
        var id = ++__componentSequence;
        if (immediate) {
            entitiesMap.set(id, id);
            entities.add(id);
        }
        return id;
    }

    @:allow(echo.Entity) function addEntity(id:Int) {
        if (!entitiesMap.exists(id)) {
            entitiesMap.set(id, id);
            entities.add(id);
            for (v in views) v.addIfMatch(id);
        }
    }

    @:allow(echo.Entity) function removeEntity(id:Int) {
        if (entitiesMap.exists(id)) {
            for (v in views) v.removeIfMatch(id);
            entitiesMap.remove(id);
            entities.remove(id);
        }
    }


}
