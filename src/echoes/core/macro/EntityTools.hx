package echoes.core.macro;

#if macro
import haxe.macro.Expr;
using echoes.core.macro.ComponentBuilder;
using echoes.core.macro.ViewsOfComponentBuilder;
using echoes.core.macro.MacroTools;
using haxe.macro.ComplexTypeTools;
using haxe.macro.Context;
using Lambda;

/**
 * Because Haxe 4 no longer allows calling macros from macros, entity manipulation
 * functions are also available in static form.
 */
class EntityTools {


    /**
     * Adds a specified components to this entity.  
     * If a component with the same type is already added - it will be replaced 
     * @param components comma separated list of components of `Any` type
     * @return `Entity`
     */
	public static function add(self:Expr, components:Array<ExprOf<Any>>):ExprOf<echoes.Entity> {
        if (components.length == 0) {
            Context.error("Nothing to add; required one or more components", Context.currentPos());
        }
        
        var types = components
            .map(function(c) {
                var t = switch(c.expr) {
                    case ENew(tp, _):
                        TPath(tp).toType();
                    default:
                        c.typeof();
                }

                return t.followMono().toComplexType();
            });

        var addComponentsToContainersExprs = [for(i in 0...components.length) {
                var c = components[i];
                var containerName = types[i].getComponentContainer().followName();
                macro @:privateAccess $i{ containerName }.inst().add(__entity__, $c);
            }];

        var addEntityToRelatedViewsExprs = types
            .map(function(ct) {
                return ct.getViewsOfComponent().followName();
            })
            .map(function(viewsOfComponentClassName) {
                return macro @:privateAccess $i{ viewsOfComponentClassName }.inst().addIfMatched(__entity__);
            });

        return macro #if (haxe_ver >= 4) inline #end
            ( function (__entity__:echoes.Entity) {
                $b{addComponentsToContainersExprs}

                if (__entity__.isActive()) $b{ addEntityToRelatedViewsExprs }

                return __entity__;
            } )($self);
    }

    /**
     * Removes a component from this entity with specified type  
     * @param types `ComplexType` types of components that should be removed
     * @return `Entity`
     */
    public static function remove(self:Expr, types:Array<ComplexType>):ExprOf<echoes.Entity> {
        if (types.length == 0) {
            Context.error("Nothing to remove; required one or more component types", Context.currentPos());
        }

        var removeComponentsFromContainersExprs = types
            .map(function(ct) {
                return ct.getComponentContainer().followName();
            })
            .map(function(componentContainerClassName) {
                return macro @:privateAccess $i{ componentContainerClassName }.inst().remove(__entity__);
            });

        var removeEntityFromRelatedViewsExprs = types
            .map(function(ct) {
                return ct.getViewsOfComponent().followName();
            })
            .map(function(viewsOfComponentClassName) {
                return macro @:privateAccess $i{ viewsOfComponentClassName }.inst().removeIfExists(__entity__);
            });

        return macro #if (haxe_ver >= 4) inline #end 
            ( function (__entity__:echoes.Entity) {
                if (__entity__.isActive()) $b{ removeEntityFromRelatedViewsExprs }

                $b{ removeComponentsFromContainersExprs }

                return __entity__;
            } )($self);
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

        return ret;
	}


}
#end
