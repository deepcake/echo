package echo;

#if macro
import echo.macro.*;
import haxe.macro.Expr;
using haxe.macro.Context;
using echo.macro.Macro;
using Lambda;
#end

abstract Entity(Int) from Int to Int {


    public inline function new(immediate = true) {
        this = ++ @:privateAccess Echo.__componentSequence;
        if (immediate) activate();
    }


    public function activate() {
        if (!activated()) {
            Echo.inst().entitiesMap.set(this, this);
            Echo.inst().entities.add(this);
            for (v in Echo.inst().views) @:privateAccess v.addIfMatch(this);
        }
    }

    public function deactivate() {
        if (activated()) {
            for (v in Echo.inst().views) @:privateAccess v.removeIfMatch(this);
            Echo.inst().entitiesMap.remove(this);
            Echo.inst().entities.remove(this);
        }
    }

    public function activated():Bool {
        return Echo.inst().entitiesMap.exists(this);
    }

    public function destroy() {
        deactivate();
        for (cc in @:privateAccess Echo.componentContainers) {
            cc.remove(this);
        }
    }


    /**
     * Adds specified components to the id (entity).
     * If component with same type is already added to the id, it will be replaced.
     * @param id - `Int` id (entity)
     * @param components - comma separated list of components of `Any` type
     * @return `Int` id
     */
    macro public function add(self:Expr, components:Array<ExprOf<Any>>):ExprOf<Entity> {
        var componentExprs = new List<Expr>()
            .concat(
                components
                    .map(function(c){
                        var ct = ComponentMacro.getComponentContainer(c.typeof().follow().toComplexType());
                        return macro ${ ct.expr(Context.currentPos()) }.inst().add(id, $c);
                    })
            )
            .array();

        var exprs = new List<Expr>()
            .concat(componentExprs)
            .concat([ macro if (Echo.inst().has(id)) for (v in Echo.inst().views) @:privateAccess v.addIfMatch(id) ])
            .concat([ macro return id ])
            .array();

        var ret = macro ( function(id:Entity) $b{exprs} )($self);

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
    macro public function remove(self:Expr, types:Array<ExprOf<Class<Any>>>):ExprOf<Entity> {
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
            .concat(requireCond == null ? [] : [ macro if (Echo.inst().has(id)) for (v in Echo.inst().views) if ($requireCond) @:privateAccess v.removeIfMatch(id) ])
            .concat(componentExprs)
            .concat([ macro return id ])
            .array();

        var ret = macro ( function(id:Entity) $b{exprs} )($self);

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
    macro public function get<T>(self:Expr, type:ExprOf<Class<T>>):ExprOf<T> {
        var ct = ComponentMacro.getComponentContainer(type.identName().getType().follow().toComplexType());
        var exprs = [ macro return ${ ct.expr(Context.currentPos()) }.inst().get(id) ];
        var ret = macro ( function(id:Entity) $b{exprs} )($self);

        #if echo_verbose
        trace(new haxe.macro.Printer().printExpr(ret), @:pos Context.currentPos());
        #end

        return ret;
    }

    /**
     * Returns `true` if the id (entity) has a component with passed type, otherwise returns false
     * @param id - `Int` id (entity)
     * @param type - `Class<T>` type of component
     * @return `Bool`
     */
    macro public function exists(self:Expr, type:ExprOf<Class<Any>>):ExprOf<Bool> {
        var ct = ComponentMacro.getComponentContainer(type.identName().getType().follow().toComplexType());
        var exprs = [ macro return ${ ct.expr(Context.currentPos()) }.inst().exists(id) ];
        var ret = macro ( function(id:Entity) $b{exprs} )($self);

        #if echo_verbose
        trace(new haxe.macro.Printer().printExpr(ret), @:pos Context.currentPos());
        #end

        return ret;
    }


}