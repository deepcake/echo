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


    public static var componentIndex:Int = -1;
    public static var componentIds:Map<String, Int> = new Map();
    public static var componentCache:Map<String, ComplexType> = new Map();

    public static var componentMapCache:Map<String, ComplexType> = new Map();
    public static var componentMapNames:Array<String> = [];


    // componentHolderClsName / componentHolderType
    static var componentHolderTypeCache = new Map<String, haxe.macro.Type>();


    public static function createComponentHolderType(componentCls:ComplexType) {
        var componentClsName = componentCls.followName();
        var componentHolderClsName = getClsName('ComponentMap', componentClsName);
        var componentHolderType = componentHolderTypeCache.get(componentHolderClsName);

        //if (componentHolderType == null) {
        try {

            componentHolderType = Context.getType(componentHolderClsName);

        } catch (err:String) {

            trace('not found $componentHolderClsName');

            ++componentIndex;

            var componentContainerTypePath = tpath([], componentHolderClsName, []);
            var componentContainerComplexType = TPath(componentContainerTypePath);

            var def = macro class $componentHolderClsName implements echo.macro.IComponentContainer {
                // echo id => cc inst
                //static var componentContainers:Map<Int, $componentContainerComplexType>;
                static var componentContainer:$componentContainerComplexType;

                static function __init__() {
                    //componentContainers = new Map();
                    echo.Echo.__addComponentContainerInitializer($v{ componentIndex }, init);
                }

                static function init(eid:Int):echo.macro.IComponentContainer {
                    //componentContainers[eid] = new $componentContainerTypePath();
                    //return componentContainers[eid];
                    if (componentContainer == null) componentContainer = new $componentContainerTypePath();
                    return componentContainer;
                }

                static function terminate(eid:Int):Void {
                }

                inline public static function inst(eid:Int) {
                    //return componentContainers[eid];
                    return componentContainer;
                }

                // cid => c inst
                var components:Map<Int, $componentCls>;

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

            //componentHolderType = Context.getType(componentHolderClsName);
            var componentHolderCls = TPath(tpath([], componentHolderClsName, []));
            componentHolderType = componentHolderCls.toType();

            componentHolderTypeCache.set(componentHolderClsName, componentHolderType);

            componentIds[componentClsName] = componentIndex;
            componentCache[componentClsName] = componentCls;
            componentMapCache[componentClsName] = componentHolderCls;
            componentMapNames.push(componentHolderClsName);

        }

        return componentHolderType;
    }


    public static function getComponentHolder(componentCls:ComplexType):ComplexType {
        gen();
        return createComponentHolderType(componentCls).toComplexType();
    }

    public static function getComponentId(componentCls:ComplexType):Int {
        getComponentHolder(componentCls);
        return componentIds[componentCls.followName()];
    }

}
#end