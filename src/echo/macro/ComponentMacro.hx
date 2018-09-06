package echo.macro;

#if macro
import echo.macro.Macro.*;
import echo.macro.MacroBuilder.*;

import haxe.macro.Expr.ComplexType;

using haxe.macro.Context;
using echo.macro.Macro;

class ComponentMacro {


    public static var componentIndex:Int = -1;
    public static var componentIds:Map<String, Int> = new Map();
    public static var componentCache:Map<String, ComplexType> = new Map();

    public static var componentMapCache:Map<String, ComplexType> = new Map();
    public static var componentMapNames:Array<String> = [];


    public static function getComponentHolder(componentCls:ComplexType):ComplexType {
            gen();

            var componentClsName = componentCls.followName();
            var componentHolderClsName = getClsName('ComponentMap', componentClsName);
            var componentHolderCls = componentMapCache.get(componentClsName);
            
            //if (componentHolderCls == null) {
            try {

                componentHolderCls = Context.getType(componentHolderClsName).toComplexType();

            } catch (err:String) {

                componentIndex++;

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

                traceTypeDefenition(def);

                Context.defineType(def);

                componentHolderCls = Context.getType(componentHolderClsName).toComplexType();
                componentIds[componentClsName] = componentIndex;
                componentCache[componentClsName] = componentCls;
                componentMapCache[componentClsName] = componentHolderCls;
                componentMapNames.push(componentHolderClsName);
            }
            return componentHolderCls;
    }

    public static function getComponentId(componentCls:ComplexType):Int {
        getComponentHolder(componentCls);
        return componentIds[componentCls.followName()];
    }

}
#end