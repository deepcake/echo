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


    static var __echoSequence = -1;


    static var __componentSequence = -1;


    static var componentContainers:Array<echo.macro.IComponentContainer<Dynamic>> = [];

    static function regComponentContainer(cc:echo.macro.IComponentContainer<Dynamic>) {
        componentContainers.push(cc);
    }


    static var instance = new Echo();

    @:keep inline public static function inst() {
        return instance;
    }


    @:noCompletion public var __id:Int;

    @:noCompletion public var entitiesMap:Map<Int, Int> = new Map(); // map (id : id)
    @:noCompletion public var viewsMap:Map<Int, View.ViewBase> = new Map();
    @:noCompletion public var systemsMap:Map<Int, System> = new Map();

    /** List of added ids (entities) */
    public var entities(default, null):List<Int> = new List();
    /** List of added views */
    public var views(default, null):List<View.ViewBase> = new List();
    /** List of added systems */
    public var systems(default, null):List<System> = new List();


    public function new() {
        __id = ++__echoSequence;
    }


    #if echo_profiling
    var times:Map<Int, Float> = new Map();
    #end
    public function toString():String {
        var ret = '#$__id ( ${systems.length} ) { ${views.length} } [ ${entities.length} ]'; // TODO version or something

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
    * Removes all views, systems and ids (entities)
     */
    public function dispose() {
        for (e in entities) remove(e);
        for (s in systems) removeSystem(s);
        for (v in views) removeView(v);
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
            s.activate(this);
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

    /**
     * Returns `true` if system with passed `type` was been added to the workflow, otherwise returns `false`
     * @param type `Class<T>` system type
     * @return `Bool`
     */
    macro public function hasSystem<T:System>(self:Expr, type:ExprOf<Class<T>>):ExprOf<Bool> {
        var cls = type.identName().getType().follow().toComplexType();
        return macro $self.systemsMap.exists($v{ SystemMacro.systemIdsMap[cls.followName()] });
    }

    /**
     * Retrives a system from the workflow by its type. If system with passed type will be not founded, `null` will be returned
     * @param type `Class<T>` system type
     * @return `System`
     */
    macro public function getSystem<T:System>(self:Expr, type:ExprOf<Class<T>>):ExprOf<Null<System>> {
        var cls = type.identName().getType().follow().toComplexType();
        return macro $self.systemsMap[$v{ SystemMacro.systemIdsMap[cls.followName()] }];
    }


    // View

    /**
     * Adds view to the workflow
     * @param v `View<T>` instance
     */
    public function addView(v:View.ViewBase) {
        if (!viewsMap.exists(v.__id)) {
            viewsMap[v.__id] = v;
            views.add(v);
            v.activate(this);
        }
    }

    /**
     * Removes view to the workflow
     * @param v `View<T>` instance
     */
    public function removeView(v:View.ViewBase) {
        if (viewsMap.exists(v.__id)) {
            v.deactivate();
            viewsMap.remove(v.__id);
            views.remove(v);
        }
    }

    /**
     * Returns `true` if view with passed `type` was been added to the workflow, otherwise returns `false`
     * @param type `Class<T>` view type
     * @return `Bool`
     */
    macro public function hasView<T:View.ViewBase>(self:Expr, type:ExprOf<Class<T>>):ExprOf<Bool> {
        var cls = type.identName().getType().follow().toComplexType();
        return macro $self.viewsMap.exists($v{ ViewMacro.viewIdsMap[cls.followName()] });
    }

    /**
     * Retrives a view from the workflow by its type. If view with passed type will be not found, `null` will be returned
     * @param type `Class<T>` view type
     * @return `View<T>`
     */
    macro public function getView<T:View.ViewBase>(self:Expr, type:ExprOf<Class<T>>):ExprOf<Null<View.ViewBase>> {
        var cls = type.identName().getType().follow().toComplexType();
        return macro $self.viewsMap[$v{ ViewMacro.viewIdsMap[cls.followName()] }];
    }

    macro public function getViewByTypes(self:Expr, types:Array<ExprOf<Class<Any>>>):ExprOf<Null<View.ViewBase>> {
        var viewCls = MacroBuilder.getViewClsByTypes(types.map(function(type) return type.identName().getType().follow().toComplexType()));
        return macro $self.viewsMap[$v{ ViewMacro.viewIdsMap[viewCls.followName()] }];
    }

    macro public function hasViewByTypes(self:Expr, types:Array<ExprOf<Class<Any>>>):ExprOf<Bool> {
        var viewCls = MacroBuilder.getViewClsByTypes(types.map(function(type) return type.identName().getType().follow().toComplexType()));
        return macro $self.viewsMap.exists($v{ ViewMacro.viewIdsMap[viewCls.followName()] });
    }


    // Entity

    /**
     * Creates a new id (entity)
     * @param add - immediate adds created id to the workflow if `true`, otherwise not. Default `true`
     * @return created `Int` id
     */
    public function id(add:Bool = true):Int {
        var id = ++__componentSequence;
        if (add) {
            entitiesMap.set(id, id);
            entities.add(id);
        }
        return id;
    }

    /**
     * Returns `true` if the id (entity) is added to the workflow, otherwise returns `false`
     * @param id - `Int` id (entity)
     * @return `Bool`
     */
    public inline function has(id:Int):Bool {
        return entitiesMap.exists(id);
    }

    /**
     * Adds the id (entity) to the workflow
     * @param id - `Int` id (entity)
     */
    public inline function push(id:Int) {
        if (!this.has(id)) {
            entitiesMap.set(id, id);
            entities.add(id);
            for (v in views) v.addIfMatch(id);
        }
    }

    /**
     * Removes the id (entity) from the workflow with saving all it's components. 
     * The id can be pushed back to the workflow
     * @param id - `Int` id (entity)
     */
    public inline function pull(id:Int) {
        if (this.has(id)) {
            for (v in views) v.removeIfMatch(id);
            entitiesMap.remove(id);
            entities.remove(id);
        }
    }

    /**
     * Removes the id (entity) from the workflow and removes all it components
     * @param id - `Int` id (entity)
     */
    public function remove(id:Int) {
        pull(id);
        for (i in 0...componentContainers.length) {
            componentContainers[i].remove(id);
        }
    }


    // Component

    /**
     * Adds specified components to the id (entity).
     * If component with same type is already added to the id, it will be replaced.
     * @param id - `Int` id (entity)
     * @param components - comma separated list of components of `Any` type
     * @return `Int` id
     */
    macro public function addComponent(self:Expr, id:ExprOf<Int>, components:Array<ExprOf<Any>>):ExprOf<Int> {
        var componentExprs = new List<Expr>()
            .concat(
                components
                    .map(function(c){
                        var ct = ComponentMacro.getComponentContainer(c.typeof().follow().toComplexType());
                        return macro ${ ct.expr(Context.currentPos()) }.inst().set(id, $c);
                    })
            )
            .array();

        var exprs = new List<Expr>()
            .concat(componentExprs)
            .concat([ macro if ($self.has(id)) for (v in $self.views) @:privateAccess v.addIfMatch(id) ])
            .concat([ macro return id ])
            .array();

        var ret = macro ( function(id:Int) $b{exprs} )($id);

        #if echo_verbose
        trace(new haxe.macro.Printer().printExpr(ret), @:pos Context.currentPos());
        #end

        return ret;
    }

    /**
     * Removes a components from the id (entity) by its type
     * @param id - `Int` id (entity)
     * @param types - comma separated `Class<Any>` types of components to be removed
     * @return `Int` id
     */
    macro public function removeComponent(self:Expr, id:ExprOf<Int>, types:Array<ExprOf<Class<Any>>>):ExprOf<Int> {
        var componentExprs = new List<Expr>()
            .concat(
                types
                    .map(function(t){
                        var ct = ComponentMacro.getComponentContainer(t.identName().getType().follow().toComplexType());
                        return macro ${ ct.expr(Context.currentPos()) }.inst().remove(id);
                    })
            )
            .array();

        var requireExprs = new List<Expr>()
            .concat(
                types
                    .map(function(t){
                        return ComponentMacro.getComponentId(t.identName().getType().follow().toComplexType());
                    })
                    .map(function(i){
                        return macro @:privateAccess v.isRequire($v{i});
                    })
            )
            .array();

        var requireCond = requireExprs.slice(1)
            .fold(function(e:Expr, r:Expr){
                return macro $r || $e;
            }, requireExprs.length > 0 ? requireExprs[0] : null);

        var exprs = new List<Expr>()
            .concat(requireCond == null ? [] : [ macro if ($self.has(id)) for (v in $self.views) if ($requireCond) @:privateAccess v.removeIfMatch(id) ])
            .concat(componentExprs)
            .concat([ macro return id ])
            .array();

        var ret = macro ( function(id:Int) $b{exprs} )($id);

        #if echo_verbose
        trace(new haxe.macro.Printer().printExpr(ret), @:pos Context.currentPos());
        #end

        return ret;
    }

    /**
     * Retrives a component from the id (entity) by its type.
     * If component with passed type is not added to the id, `null` will be returned.
     * @param id - `Int` id (entity)
     * @param type - `Class<T>` type of component to be retrieved
     * @return `T`
     */
    macro public function getComponent<T>(self:Expr, id:ExprOf<Int>, type:ExprOf<Class<T>>):ExprOf<T> {
        var ct = ComponentMacro.getComponentContainer(type.identName().getType().follow().toComplexType());
        var exprs = [ macro return ${ ct.expr(Context.currentPos()) }.inst().get(id) ];
        var ret = macro ( function(id:Int) $b{exprs} )($id);
        return ret;
    }

    /**
     * Returns `true` if the id (entity) has a component with passed type, otherwise returns false
     * @param id - `Int` id (entity)
     * @param type - `Class<T>` type of component
     * @return `Bool`
     */
    macro public function hasComponent(self:Expr, id:ExprOf<Int>, type:ExprOf<Class<Any>>):ExprOf<Bool> {
        var ct = ComponentMacro.getComponentContainer(type.identName().getType().follow().toComplexType());
        var exprs = [ macro return ${ ct.expr(Context.currentPos()) }.inst().exists(id) ];
        var ret = macro ( function(id:Int) $b{exprs} )($id);
        return ret;
    }

}
