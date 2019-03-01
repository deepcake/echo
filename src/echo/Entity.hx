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
abstract Entity(Int) from Int to Int {


    public inline function new(immediate = true) this = Echo.id(immediate);


    /**
    * Adds this entity to the workflow;
     */
    public inline function activate() {
        Echo.add(this);
    }

    /**
    * Removes this entity from the workflow, but saves all associated components;
     */
    public inline function deactivate() {
        Echo.remove(this);
    }

    /**
    * Returns `true` if this entity added to the workflow, otherwise returns `false`;
    * @return Bool
     */
    public inline function activated():Bool {
        return Echo.exists(this);
    }

    /**
    * Removes all associated components of this entity;
     */
    public function removeAll() {
        for (cc in Echo.componentContainers) {
            cc.remove(this);
        }
    }

    /**
    * Removes this entity from the workflow with removing all associated components;
     */
    public function destroy() {
        deactivate();
        removeAll();
    }


    /**
     * Adds specified components to this entity;
     * If component with the same type is already added - it will be replaced;
     * @param components - comma separated list of components of `Any` type
     * @return `Entity`
     */
    macro public function add(self:Expr, components:Array<ExprOf<Any>>):ExprOf<Entity> {
        var componentExprs = new List<Expr>()
            .concat(
                components
                    .map(function(c){
                        var ct = ComponentMacro.getComponentContainer(c.typeof().follow().toComplexType());
                        return macro @:privateAccess ${ ct.expr(Context.currentPos()) }.inst().add(id, $c);
                    })
            )
            .array();

        var exprs = new List<Expr>()
            .concat(componentExprs)
            .concat([ macro if (id.activated()) for (v in Echo.views) @:privateAccess v.addIfMatch(id) ])
            .concat([ macro return id ])
            .array();

        var ret = macro #if haxe4 inline #end ( function(id:Entity) $b{exprs} )($self);

        #if echo_verbose
        trace(Context.currentPos() + "\n" + new haxe.macro.Printer().printExpr(ret));
        #end

        return ret;
    }

    /**
     * Removes a components from this entity by its type;
     * @param types - comma separated `Class<Any>` types of components
     * @return `Entity`
     */
    macro public function remove(self:Expr, types:Array<ExprOf<Class<Any>>>):ExprOf<Entity> {
        var componentExprs = new List<Expr>()
            .concat(
                types
                    .map(function(t){
                        var ct = ComponentMacro.getComponentContainer(t.identName().getType().follow().toComplexType());
                        return macro @:privateAccess ${ ct.expr(Context.currentPos()) }.inst().remove(id);
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
            .concat(requireCond == null ? [] : [ macro if (id.activated()) for (v in Echo.views) if ($requireCond) @:privateAccess v.removeIfMatch(id) ])
            .concat(componentExprs)
            .concat([ macro return id ])
            .array();

        var ret = macro #if haxe4 inline #end ( function(id:Entity) $b{exprs} )($self);

        #if echo_verbose
        trace(Context.currentPos() + "\n" + new haxe.macro.Printer().printExpr(ret));
        #end

        return ret;
    }

    /**
     * Retrives a component of this entity by its type;
     * If component with passed type is not added to this entity, `null` will be returned;
     * @param type - `Class<T>` type of component
     * @return `T`
     */
    macro public function get<T>(self:Expr, type:ExprOf<Class<T>>):ExprOf<T> {
        var ct = ComponentMacro.getComponentContainer(type.identName().getType().follow().toComplexType());
        var exprs = [ macro return ${ ct.expr(Context.currentPos()) }.inst().get(id) ];
        var ret = macro #if haxe4 inline #end ( function(id:Entity) $b{exprs} )($self);

        #if echo_verbose
        trace(Context.currentPos() + "\n" + new haxe.macro.Printer().printExpr(ret));
        #end

        return ret;
    }

    /**
     * Returns `true` if this entity contains a component with passed type, otherwise returns `false`;
     * @param type - `Class<T>` type of component
     * @return `Bool`
     */
    macro public function exists(self:Expr, type:ExprOf<Class<Any>>):ExprOf<Bool> {
        var ct = ComponentMacro.getComponentContainer(type.identName().getType().follow().toComplexType());
        var exprs = [ macro return ${ ct.expr(Context.currentPos()) }.inst().exists(id) ];
        var ret = macro #if haxe4 inline #end ( function(id:Entity) $b{exprs} )($self);

        #if echo_verbose
        trace(Context.currentPos() + "\n" + new haxe.macro.Printer().printExpr(ret));
        #end

        return ret;
    }


}