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

        if (componentContainerType == null) {
        //try componentContainerType = Context.getType(componentContainerClsName) catch (err:String) {

            ++componentIndex;

            var componentContainerTypePath = tpath([], componentContainerClsName, []);
            var componentContainerComplexType = TPath(componentContainerTypePath);

            var def = macro class $componentContainerClsName {

                static var instance = new $componentContainerTypePath();

                @:keep inline public static function inst():$componentContainerComplexType {
                    return instance;
                }

                // instance

                var components = new echo.macro.ComponentMacro.ComponentContainer<$componentCls>();

                function new() {
                    @:privateAccess echo.Echo.regComponentContainer(this.components);
                }

                inline public function get(id:Int):$componentCls {
                    return components.get(id);
                }

                inline public function exists(id:Int):Bool {
                    return components.exists(id);
                }

                inline function add(id:Int, c:$componentCls) {
                    components.add(id, c);
                }

                inline function remove(id:Int) {
                    components.remove(id);
                }

            }

            traceTypeDefenition(def);

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


abstract ArrayComponentContainer<T>(Array<T>) {

    public inline function new() this = new Array<T>();

    public inline function add(id:Int, c:T) {
        this[id] = c;
    }

    public inline function get(id:Int):T {
        return this[id];
    }

    public inline function remove(id:Int) {
        this[id] = null;
    }

    public inline function exists(id:Int) {
        return this[id] != null;
    }

    public function dispose() {
        this.resize(0);
    }

}

abstract IntMapComponentContainer<T>(haxe.ds.IntMap<T>) {

    public function new() this = new haxe.ds.IntMap<T>();

    public inline function add(id:Int, c:T) {
        this.set(id, c);
    }

    public inline function get(id:Int):T {
        return this.get(id);
    }

    public inline function remove(id:Int) {
        this.remove(id);
    }

    public inline function exists(id:Int) {
        return this.exists(id);
    }

    public function dispose() {
        for (k in this.keys()) this.remove(k); 
    }

}

typedef ComponentContainer<T> = #if echo_array_cc ArrayComponentContainer<T> #else IntMapComponentContainer<T> #end;
