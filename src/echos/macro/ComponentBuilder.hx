package echos.macro;

#if macro
import echos.macro.MacroTools.*;
import haxe.macro.Expr.ComplexType;
using echos.macro.MacroTools;
using haxe.macro.Context;
using haxe.macro.ComplexTypeTools;
using Lambda;

class ComponentBuilder {


    static var componentIndex = -1;

    // componentContainerTypeName / componentContainerType
    static var componentContainerTypeCache = new Map<String, haxe.macro.Type>();

    public static var componentIds = new Map<String, Int>();
    public static var componentNames = new Array<String>();


    static function getComponentContainerName(ct:ComplexType) {
        return 'ContainerOf' + ct.typeName();
    }

    public static function createComponentContainerType(componentCls:ComplexType) {
        var componentTypeName = componentCls.followName();
        var componentContainerTypeName = getComponentContainerName(componentCls);
        var componentContainerType = componentContainerTypeCache.get(componentContainerTypeName);

        if (componentContainerType == null) {
            // first time call in current macro phase

            var index = ++componentIndex;

            try componentContainerType = Context.getType(componentContainerTypeName) catch (err:String) {
                // type was not cached in previous macro phases

                var componentContainerTypePath = tpath([], componentContainerTypeName, []);
                var componentContainerComplexType = TPath(componentContainerTypePath);

                var def = macro class $componentContainerTypeName implements echos.macro.ComponentBuilder.DestroyableRemovableComponentContainer {

                    static var instance = new $componentContainerTypePath();

                    @:keep public static inline function inst():$componentContainerComplexType {
                        return instance;
                    }

                    // instance

                    var components = new echos.macro.ComponentBuilder.ComponentContainer<$componentCls>();

                    function new() {
                        @:privateAccess echos.Workflow.definedContainers.push(this);
                    }

                    public inline function get(id:Int):$componentCls {
                        return components.get(id);
                    }

                    public inline function exists(id:Int):Bool {
                        return components.exists(id);
                    }

                    public inline function add(id:Int, c:$componentCls) {
                        components.add(id, c);
                    }

                    public inline function remove(id:Int) {
                        components.remove(id);
                    }

                    public inline function dispose() {
                        components.dispose();
                    }

                }

                traceTypeDefenition(def);

                Context.defineType(def);

                componentContainerType = componentContainerComplexType.toType();
            }

            // caching current macro phase
            componentContainerTypeCache.set(componentContainerTypeName, componentContainerType);
            componentIds[componentTypeName] = index;
            componentNames.push(componentTypeName);
        }

        Report.gen();

        return componentContainerType;
    }


    public static function getComponentContainer(componentCls:ComplexType):ComplexType {
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
        var i = @:privateAccess echos.Workflow.nextId;
        while (--i > -1) this.remove(i); 
    }

}
#end

typedef ComponentContainer<T> = #if echos_array_cc ArrayComponentContainer<T> #else IntMapComponentContainer<T> #end;

interface DestroyableRemovableComponentContainer {
    function remove(id:Int):Void;
    function dispose():Void;
}
