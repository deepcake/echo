package echo.macro;

#if macro
import echo.macro.Macro.*;
import echo.macro.MacroBuilder.*;

import haxe.macro.Expr.ComplexType;

using haxe.macro.Context;
using echo.macro.Macro;
using haxe.macro.ComplexTypeTools;
using Lambda;

class ComponentMacro {


    static var componentIndex:Int = -1;

    // componentContainerClsName / componentContainerType
    static var componentContainerTypeCache = new Map<String, haxe.macro.Type>();

    public static var componentIds:Map<String, Int> = new Map();
    public static var componentNames:Array<String> = [];


    public static function createComponentContainerType(componentCls:ComplexType) {
        var componentClsName = componentCls.followName();
        var componentContainerClsName = getClsName('ComponentContainer', componentClsName);
        var componentContainerType = componentContainerTypeCache.get(componentContainerClsName);

        //if (componentContainerType == null) {
        try {

            componentContainerType = Context.getType(componentContainerClsName);

        } catch (err:String) {

            //trace('not found $componentContainerClsName');

            ++componentIndex;

            var componentContainerTypePath = tpath([], componentContainerClsName, []);
            var componentContainerComplexType = TPath(componentContainerTypePath);

            var def = macro class $componentContainerClsName implements echo.macro.IComponentContainer<$componentCls> {

                static var instance = new $componentContainerTypePath();

                @:keep inline public static function inst():$componentContainerComplexType {
                    return instance;
                }

                // instance

                var components = new Map<Int, $componentCls>();

                public function new() {
                    @:privateAccess echo.Echo.regComponentContainer(this);
                }

                inline public function add(id:Int, c:$componentCls) {
                    components[id] = c;
                }

                inline public function get(id:Int) {
                    return components[id];
                }

                inline public function remove(id:Int) {
                    components.remove(id);
                }

                inline public function exists(id:Int) {
                    return components.exists(id);
                }

            }

            Context.defineType(def);

            //componentContainerType = Context.getType(componentContainerClsName);
            componentContainerType = componentContainerComplexType.toType();
            componentContainerTypeCache.set(componentContainerClsName, componentContainerType);

            componentIds[componentClsName] = componentIndex;

            componentNames.push(componentClsName);

        }

        return componentContainerType;
    }


    public static function getComponentContainer(componentCls:ComplexType):ComplexType {
        gen();
        return createComponentContainerType(componentCls).toComplexType();
    }

    public static function getComponentId(componentCls:ComplexType):Int {
        getComponentContainer(componentCls);
        return componentIds[componentCls.followName()];
    }

}
#end