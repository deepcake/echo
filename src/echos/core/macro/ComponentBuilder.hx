package echos.core.macro;

#if macro
import echos.core.macro.MacroTools.*;
import haxe.macro.Expr.ComplexType;
using echos.core.macro.MacroTools;
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

    public static function createComponentContainerType(componentComplexType:ComplexType) {
        var componentTypeName = componentComplexType.followName();
        var componentContainerTypeName = getComponentContainerName(componentComplexType);
        var componentContainerType = componentContainerTypeCache.get(componentContainerTypeName);

        if (componentContainerType == null) {
            // first time call in current macro phase

            var index = ++componentIndex;

            try componentContainerType = Context.getType(componentContainerTypeName) catch (err:String) {
                // type was not cached in previous macro phases

                var componentContainerTypePath = tpath([], componentContainerTypeName, []);
                var componentContainerComplexType = TPath(componentContainerTypePath);

                var def = macro class $componentContainerTypeName implements echos.core.ICleanableComponentContainer {

                    static var instance = new $componentContainerTypePath();

                    @:keep public static inline function inst():$componentContainerComplexType {
                        return instance;
                    }

                    // instance

                    var storage = new echos.core.Storage<$componentComplexType>();

                    function new() {
                        @:privateAccess echos.Workflow.definedContainers.push(this);
                    }

                    public inline function get(id:Int):$componentComplexType {
                        return storage.get(id);
                    }

                    public inline function exists(id:Int):Bool {
                        return storage.exists(id);
                    }

                    public inline function add(id:Int, c:$componentComplexType) {
                        storage.add(id, c);
                    }

                    public inline function remove(id:Int) {
                        storage.remove(id);
                    }

                    public inline function reset() {
                        storage.reset();
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


    public static function getComponentContainer(componentComplexType:ComplexType):ComplexType {
        return createComponentContainerType(componentComplexType).toComplexType();
    }

    public static function getComponentId(componentComplexType:ComplexType):Int {
        getComponentContainer(componentComplexType);
        return componentIds[componentComplexType.followName()];
    }

}
#end
