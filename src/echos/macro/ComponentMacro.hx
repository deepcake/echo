package echos.macro;

#if macro
import echos.macro.Macro.*;
import echos.macro.MacroBuilder.*;

import haxe.macro.Expr.ComplexType;

using haxe.macro.Context;
using echos.macro.Macro;
using haxe.macro.ComplexTypeTools;
using Lambda;

class ComponentMacro {


    static var componentIndex = -1;

    // componentContainerClsName / componentContainerType
    static var componentContainerTypeCache = new Map<String, haxe.macro.Type>();

    public static var componentIds = new Map<String, Int>();
    public static var componentNames = new Array<String>();


    public static function createComponentContainerType(componentCls:ComplexType) {
        var componentClsName = componentCls.followName();
        var componentContainerClsName = getClsName('ComponentContainer', componentClsName);
        var componentContainerType = componentContainerTypeCache.get(componentContainerClsName);

        if (componentContainerType == null) {
            // first time call in current macro phase

            var index = ++componentIndex;

            try componentContainerType = Context.getType(componentContainerClsName) catch (err:String) {
                // type was not cached in previous macro phases

                var componentContainerTypePath = tpath([], componentContainerClsName, []);
                var componentContainerComplexType = TPath(componentContainerTypePath);

                var def = macro class $componentContainerClsName {

                    static var instance = new $componentContainerTypePath();

                    @:keep inline public static function inst():$componentContainerComplexType {
                        return instance;
                    }

                    // instance

                    var components = new echos.macro.ComponentMacro.ComponentContainer<$componentCls>();

                    function new() {
                        @:privateAccess echos.Workflow.regComponentContainer(this.components);
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

                componentContainerType = componentContainerComplexType.toType();
            }

            // caching current macro phase
            componentContainerTypeCache.set(componentContainerClsName, componentContainerType);
            componentIds[componentClsName] = index;
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

#if echos_array_cc
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
        #if haxe4 
        this.resize(0);
        #else 
        this.splice(0, this.length);
        #end
    }

}

#else

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
        // for (k in this.keys()) this.remove(k); // python "dictionary changed size during iteration"
        var i = @:privateAccess echos.Workflow.__nextEntityId;
        while (--i > -1) this.remove(i); 
    }

}
#end

typedef ComponentContainer<T> = #if echos_array_cc ArrayComponentContainer<T> #else IntMapComponentContainer<T> #end;
