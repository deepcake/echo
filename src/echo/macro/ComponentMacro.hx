package echo.macro;


import echo.macro.Macro.*;
import echo.macro.MacroBuilder.*;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Printer;
import haxe.macro.Type.ClassField;
import haxe.macro.Expr.ComplexType;

using haxe.macro.ComplexTypeTools;
using haxe.macro.Context;
using echo.macro.Macro;
using StringTools;
using Lambda;

class ComponentMacro {


    public static var componentIndex:Int = 0;
    public static var componentIds:Map<String, Int> = new Map();
    public static var componentCache:Map<String, ComplexType> = new Map();

    public static var componentMapCache:Map<String, ComplexType> = new Map();
    public static var componentMapNames:Array<String> = [];


    public static function getComponentHolder(componentCls:ComplexType):ComplexType {
            gen();

            var componentClsName = componentCls.followName();
            var componentHolderClsName = getClsName('ComponentMap', componentClsName);
            var componentHolderCls = componentMapCache.get(componentClsName);
            
            if (componentHolderCls == null) {

                componentIndex++;

                var def = macro class $componentHolderClsName {
                    public static var __tl:Map<Int, Map<Int, $componentCls>>;

                    static function __init__() {
                        __tl = new Map<Int, Map<Int, $componentCls>>();
                        if (echo.Echo.__inits == null) echo.Echo.__inits = new Map<Int, Int->(Int->Void)>();
                        echo.Echo.__inits[$v{ componentIndex }] = init;
                    }

                    public static function init(i:Int):(Int->Void) {
                        __tl[i] = new Map<Int, $componentCls>();
                        return __tl[i].remove;
                    }

                    @:keep
                    inline public static function get(i:Int) {
                        return __tl[i];
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