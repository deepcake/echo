package echoes.core.macro;

#if macro
import echoes.core.macro.MacroTools.*;
import haxe.macro.Expr.ComplexType;
using echoes.core.macro.MacroTools;
using haxe.macro.Context;
using haxe.macro.ComplexTypeTools;

class ViewsOfComponentBuilder {


    // viewsOfComponentTypeName / viewsOfComponentType
    static var viewsOfComponentTypeCache = new Map<String, haxe.macro.Type>();


    public static function createViewsOfComponentType(componentComplexType:ComplexType):haxe.macro.Type {
        var componentTypeName = componentComplexType.followName();
        var viewsOfComponentTypeName = 'ViewsOfComponent' + componentComplexType.typeFullName();
        var viewsOfComponentType = viewsOfComponentTypeCache.get(viewsOfComponentTypeName);

        if (viewsOfComponentType == null) {
            // first time call in current build

            try viewsOfComponentType = Context.getType(viewsOfComponentTypeName) catch (err:String) {
                // type was not cached in previous build

                var viewsOfComponentTypePath = tpath([], viewsOfComponentTypeName, []);
                var viewsOfComponentComplexType = TPath(viewsOfComponentTypePath);

                var def = macro class $viewsOfComponentTypeName {

                    static var instance = new $viewsOfComponentTypePath();

                    @:keep public static inline function inst():$viewsOfComponentComplexType {
                        return instance;
                    }

                    // instance

                    var views = new Array<echoes.core.AbstractView>();

                    function new() { }

                    public inline function addRelatedView(v:echoes.core.AbstractView) {
                        views.push(v);
                    }

                    public inline function removeIfMatched(id:Int) {
                        for (v in views) {
                            if (v.isActive()) {
                                 @:privateAccess v.removeIfExists(id);
                            }
                        }
                    }
                }

                Context.defineType(def);

                viewsOfComponentType = viewsOfComponentComplexType.toType();
            }

            // caching current build
            viewsOfComponentTypeCache.set(viewsOfComponentTypeName, viewsOfComponentType);
        }

        return viewsOfComponentType;
    }

    public static function getViewsOfComponent(componentComplexType:ComplexType):ComplexType {
        return createViewsOfComponentType(componentComplexType).toComplexType();
    }


}
#end
