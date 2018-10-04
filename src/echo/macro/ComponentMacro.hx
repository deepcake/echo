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

            var def = macro class $componentContainerClsName implements echo.macro.IComponentContainer {

                #if echo_multi_instance

                static var componentContainers:Map<Int, $componentContainerComplexType>; // echo id => cc inst
                @:access(echo.Echo) static function __init__() {
                    componentContainers = new Map();
                    echo.Echo.__initComponentContainer($v{ componentIndex }, create, destroy);
                }
                static function create(eid:Int):echo.macro.IComponentContainer {
                    componentContainers[eid] = new $componentContainerTypePath();
                    return componentContainers[eid];
                }
                static function destroy(eid:Int):Void {
                    componentContainers.remove(eid);
                }
                @:keep inline public static function inst(eid:Int) {
                    return componentContainers[eid];
                }

                #else

                static var componentContainer:$componentContainerComplexType;
                @:access(echo.Echo) static function __init__() {
                    echo.Echo.__initComponentContainer($v{ componentIndex }, create, destroy);
                }
                static function create(eid:Int):echo.macro.IComponentContainer {
                    if (componentContainer == null) componentContainer = new $componentContainerTypePath();
                    return componentContainer;
                }
                static function destroy(eid:Int):Void {
                    componentContainer = null;
                }
                @:keep inline public static function inst(eid:Int) {
                    return componentContainer;
                }

                #end


                var components:Map<Int, $componentCls>; // cid => c inst

                public function new() {
                    components = new Map();
                }

                inline public function get(cid:Int) {
                    return components[cid];
                }

                inline public function set(cid:Int, c:$componentCls) {
                    components[cid] = c;
                }

                inline public function remove(cid:Int) {
                    components.remove(cid);
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