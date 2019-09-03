package echos;

#if macro
import echos.macro.ComponentBuilder;
import haxe.macro.Expr;
using echos.macro.MacroTools;
using haxe.macro.Context;
using Lambda;
#end

/**
 * Entity is an abstract over the `Int` id  
 *  
 * @author https://github.com/deepcake
 */
abstract Entity(Int) from Int to Int {


    public static inline var INVALID:Entity = Workflow.INVALID_ID;


    /**
     * Creates a new Entity instance  
     * @param immediate immediately adds this entity to the workflow if `true`, otherwise `activate()` call is required
     */
    public inline function new(immediate = true) {
        this = Workflow.id(immediate);
    }


    /**
     * Adds this entity to the workflow, so it can be collected by views  
     */
    public inline function activate() {
        Workflow.add(this);
    }

    /**
     * Removes this entity from the workflow (and also from all views), but saves all associated components.  
     * Entity can be added to the workflow again by `activate()` call
     */
    public inline function deactivate() {
        Workflow.remove(this);
    }

    /**
     * Returns `true` if this entity is added to the workflow, otherwise returns `false`  
     * @return Bool
     */
    public inline function isActive():Bool {
        return Workflow.status(this) == Active;
    }

    /**
     * Returns `true` if this entity has not been destroyed and therefore can be used safely  
     * @return Bool
     */
    public inline function isValid():Bool {
        return Workflow.status(this) < Cached;
    }

    /**
     * Returns the status of this entity: Active, Inactive, Cached or Invalid. Method is used mostly for debug purposes  
     * @return EntityStatus
     */
    public inline function status():Status {
        return Workflow.status(this);
    }

    /**
     * Removes all of associated to this entity components.  
     * __Note__ that this entity will be still exists after call this method (just without any associated components). 
     * If entity is not required anymore - `destroy()` should be called 
     */
    public inline function removeAll() {
        Workflow.removeComponents(this);
    }

    /**
     * Removes this entity from the workflow with removing all associated components. 
     * The `Int` id will be cached and then will be used again in new created entities.  
     * __Note__ that using this entity after call this method is incorrect!
     */
    public function destroy() {
        Workflow.free(this);
    }


    /**
     * Adds a specified components to this entity.  
     * If a component with the same type is already added - it will be replaced 
     * @param components comma separated list of components of `Any` type
     * @return `Entity`
     */
    macro public function add(self:Expr, components:Array<ExprOf<Any>>):ExprOf<echos.Entity> {
        if (components.length == 0) Context.error('Required one or more components', Context.currentPos());

        var componentExprs = components
            .map(function(c){
                var ct = ComponentBuilder.getComponentContainer(c.typeof().follow().toComplexType());
                return macro @:privateAccess $i{ ct.followName() }.inst().add(id, $c);
            });

        var exprs = []
            .concat(componentExprs)
            .concat([ macro if (id.isActive()) for (v in echos.Workflow.views) @:privateAccess v.addIfMatch(id) ])
            .concat([ macro return id ]);

        var ret = macro #if haxe4 inline #end ( function(id:echos.Entity) $b{exprs} )($self);

        #if echos_verbose
        trace(Context.currentPos() + "\n" + new haxe.macro.Printer().printExpr(ret));
        #end

        return ret;
    }

    /**
     * Removes a components from this entity by its type  
     * @param types comma separated `Class<Any>` types of components that should be removed
     * @return `Entity`
     */
    macro public function remove(self:Expr, types:Array<ExprOf<Class<Any>>>):ExprOf<echos.Entity> {
        if (types.length == 0) Context.error('Required one or more component types', Context.currentPos());

        var componentExprs = types
            .map(function(t){
                var ct = ComponentBuilder.getComponentContainer(t.identName().getType().follow().toComplexType());
                return macro @:privateAccess $i{ ct.followName() }.inst().remove(id);
            });

        var requireExprs = types
            .map(function(t){
                return ComponentBuilder.getComponentId(t.identName().getType().follow().toComplexType());
            })
            .map(function(i){
                return macro @:privateAccess v.isRequire($v{i});
            });

        var requireCond = requireExprs.slice(1).fold(function(e:Expr, r:Expr) return macro $e || $r, requireExprs[0]);

        var exprs = []
            .concat([ macro if (id.isActive()) for (v in echos.Workflow.views) if ($requireCond) @:privateAccess v.removeIfMatch(id) ])
            .concat(componentExprs)
            .concat([ macro return id ]);

        var ret = macro #if haxe4 inline #end ( function(id:echos.Entity) $b{exprs} )($self);

        #if echos_verbose
        trace(Context.currentPos() + "\n" + new haxe.macro.Printer().printExpr(ret));
        #end

        return ret;
    }

    /**
     * Returns a component of this entity of specified type.  
     * If a component with specified type is not added to this entity, `null` will be returned 
     * @param type `Class<T:Any>` type of component
     * @return `T:Any` component instance
     */
    macro public function get<T>(self:Expr, type:ExprOf<Class<T>>):ExprOf<T> {
        var ct = ComponentBuilder.getComponentContainer(type.identName().getType().follow().toComplexType());
        var exprs = [ macro return $i{ ct.followName() }.inst().get(id) ];
        var ret = macro #if haxe4 inline #end ( function(id:echos.Entity) $b{exprs} )($self);

        #if echos_verbose
        trace(Context.currentPos() + "\n" + new haxe.macro.Printer().printExpr(ret));
        #end

        return ret;
    }

    /**
     * Returns `true` if this entity contains a component of specified type, otherwise returns `false` 
     * @param type `Class<T:Any>` type of component
     * @return `Bool`
     */
    macro public function exists(self:Expr, type:ExprOf<Class<Any>>):ExprOf<Bool> {
        var ct = ComponentBuilder.getComponentContainer(type.identName().getType().follow().toComplexType());
        var exprs = [ macro return $i{ ct.followName() }.inst().exists(id) ];
        var ret = macro #if haxe4 inline #end ( function(id:echos.Entity) $b{exprs} )($self);

        #if echos_verbose
        trace(Context.currentPos() + "\n" + new haxe.macro.Printer().printExpr(ret));
        #end

        return ret;
    }


}

@:enum abstract Status(Int) {
    var Inactive = 0;
    var Active = 1;
    var Cached = 2;
    var Invalid = 3;
    @:op(A > B) static function gt(a:Status, b:Status):Bool;
    @:op(A < B) static function lt(a:Status, b:Status):Bool;
}
