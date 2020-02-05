package echoes.core.macro;

#if macro
import haxe.macro.Expr;
using echoes.core.macro.ComponentBuilder;
using echoes.core.macro.ViewsOfComponentBuilder;
using echoes.core.macro.MacroTools;
using haxe.macro.Context;
using Lambda;

/**
 * Because Haxe 4 no longer allows calling macros from macros, entity manipulation
 * functions are also available in static form.
 */
class EntityTools {


    /**
     * @param componentTypes (optional) an array with length equal to the number of
     * components. These will be used instead of calling typeof() on each component.
     */
	public static function add(self:Expr, components:Array<ExprOf<Any>>, ?componentTypes:Array<ComplexType>):ExprOf<echoes.Entity> {
        if (components.length == 0) {
            Context.error("Nothing to add", Context.currentPos());
        }

        if (componentTypes == null || components.length != componentTypes.length) {
            componentTypes = [for(c in components) MacroTools.typeof(c).followMono().toComplexType()];
        }

        var addComponentsToContainersExprs = [for(i in 0...components.length) {
            var containerName = componentTypes[i].getComponentContainer().followName();
            macro @:privateAccess $i{ containerName }.inst().add(__entity__, ${ components[i] });
        }];

        var ret = macro {
            var __entity__:echoes.Entity = $self;
            
            $b{addComponentsToContainersExprs}
            
            if (__entity__.isActive()) {
                for (v in echoes.Workflow.views) {
                    @:privateAccess v.addIfMatched(__entity__);
                }
            }
            
            __entity__;
        };

        #if echoes_verbose
        trace(Context.currentPos() + "\n" + new haxe.macro.Printer().printExpr(ret));
        #end

        return ret;
    }

    public static function remove(self:Expr, types:Array<ComplexType>):ExprOf<echoes.Entity> {
        if (types.length == 0) {
            Context.error("Nothing to remove", Context.currentPos());
        }

        var removeComponentsFromContainersExprs = [for(type in types)
            macro @:privateAccess $i{ type.getComponentContainer().followName() }.inst().remove(__entity__)];

        var removeEntityFromRelatedViewsExprs = [for(type in types)
            macro @:privateAccess $i{ type.getComponentContainer().followName() }.inst().removeIfMatched(__entity__)];

        var ret = macro {
            var __entity__:echoes.Entity = $self;
            
            if (__entity__.isActive()) $b{ removeEntityFromRelatedViewsExprs }
            
            $b{ removeComponentsFromContainersExprs }
            
            __entity__;
        };

        #if echoes_verbose
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
    public static function get<T>(self:Expr, complexType:ComplexType):ExprOf<T> {
        var containerName = complexType.getComponentContainer().followName();
        var ret = macro $i{ containerName }.inst().get($self);

        #if echoes_verbose
        trace(Context.currentPos() + "\n" + new haxe.macro.Printer().printExpr(ret));
        #end

        return ret;
    }

    /**
     * Returns `true` if this entity contains a component of specified type, otherwise returns `false` 
     * @param type `Class<T:Any>` type of component
     * @return `Bool`
     */
    public static function exists(self:Expr, complexType:ComplexType):ExprOf<Bool> {
        var containerName = complexType.getComponentContainer().followName();
        var ret = macro $i{ containerName }.inst().exists($self);

        #if echoes_verbose
        trace(Context.currentPos() + "\n" + new haxe.macro.Printer().printExpr(ret));
        #end

        return ret;
	}


}
#end
