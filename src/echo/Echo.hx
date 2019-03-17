package echo;

#if macro
import echo.macro.*;
import haxe.macro.Expr;
import haxe.macro.Type;
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


    @:allow(echo.Entity) static var componentContainers:Array<echo.macro.ComponentMacro.ComponentContainer<Dynamic>> = [];

    static function regComponentContainer(cc:echo.macro.ComponentMacro.ComponentContainer<Dynamic>) {
        componentContainers.push(cc);
    }


    static var entitiesMap:Map<Int, Int> = new Map(); // map (id : id)

    /** List of added entities */
    public static var entities(default, null):List<Entity> = new List();
    /** List of added views */
    public static var views(default, null):List<View.ViewBase> = new List();
    /** List of added systems */
    public static var systems(default, null):List<System> = new List();


    function new() { }


    #if echo_profiling
    static var times:Map<Int, Float> = new Map();
    #end
    public static function toString():String {
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
    public static function update(dt:Float) {
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
    public static function dispose() {
        for (e in entities) e.destroy();
        for (s in systems) removeSystem(s);
        for (v in views) v.deactivate();
        for (cc in componentContainers) {
            cc.dispose();
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

    @:allow(echo.Entity) static function id(immediate:Bool):Int {
        var id = ++__componentSequence;
        if (immediate) {
            entitiesMap.set(id, id);
            entities.add(id);
        }
        return id;
    }

    @:allow(echo.Entity) static inline function exists(id:Int) {
        return entitiesMap.exists(id);
    }

    @:allow(echo.Entity) static function add(id:Int) {
        if (!exists(id)) {
            entitiesMap.set(id, id);
            entities.add(id);
            for (v in views) v.addIfMatch(id);
        }
    }

    @:allow(echo.Entity) static function remove(id:Int) {
        if (exists(id)) {
            for (v in views) v.removeIfMatch(id);
            entitiesMap.remove(id);
            entities.remove(id);
        }
    }


}
