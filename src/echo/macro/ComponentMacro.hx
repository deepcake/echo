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

            var def = macro class $componentHolderClsName {
                public static var STACK:Map<Int, $componentCls>;
                static function __init__() {
                    STACK = new Map();
                    echo.Echo.__addComponentStack($v{ componentIndex }, STACK.remove);
                }
                @:keep inline public static function get(i:Int) { // TODO resolve with i
                    return STACK;
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