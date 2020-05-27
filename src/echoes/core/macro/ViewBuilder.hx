package echoes.core.macro;

#if macro
import echoes.core.macro.MacroTools.*;
import echoes.core.macro.ComponentBuilder.*;
import echoes.core.macro.ViewsOfComponentBuilder.*;
import haxe.macro.Expr;
import haxe.macro.Type.ClassField;

using echoes.core.macro.MacroTools;
using haxe.macro.ComplexTypeTools;
using haxe.macro.Context;
using Lambda;

class ViewBuilder {


    static var viewIndex = -1;
    static var viewTypeCache = new Map<String, haxe.macro.Type>();

    public static var viewIds = new Map<String, Int>();
    public static var viewNames = new Array<String>();

    public static var viewCache = new Map<String, { cls:ComplexType, components:Array<{ cls:ComplexType }> }>();


    public static function getView(components:Array<{ cls:ComplexType }>):ComplexType {
        return createViewType(components).toComplexType();
    }

    public static function getViewName(components:Array<{ cls:ComplexType }>) {
        return 'ViewOf_' + components.map(function(c) return c.cls).joinFullName('_');
    }


    public static function build() {
        return createViewType(parseComponents(Context.getLocalType()));
    }


    static function parseComponents(type:haxe.macro.Type) {
        return switch(type) {
            case TInst(_, params = [x = TType(_, _) | TAnonymous(_) | TFun(_, _)]) if (params.length == 1):
                parseComponents(x);

            case TType(_.get() => { type: x }, []):
                parseComponents(x);

            case TAnonymous(_.get() => p):
                p.fields
                    .map(function(f) return { cls: f.type.follow().toComplexType() });

            case TFun(args, ret):
                args
                    .map(function(a) return a.t.follow().toComplexType())
                    .concat([ ret.follow().toComplexType() ])
                    .filter(function(ct) {
                        return switch (ct) {
                            case (macro:StdTypes.Void): false;
                            default: true;
                        }
                    })
                    .map(function(ct) return { cls: ct });

            case TInst(_, types):
                types
                    .map(function(t) return t.follow().toComplexType())
                    .map(function(ct) return { cls: ct });

            case x: 
                Context.error('Unexpected Type Param: $x', Context.currentPos());
        }
    }


    public static function createViewType(components:Array<{ cls:ComplexType }>) {
        var viewClsName = getViewName(components);
        var viewType = viewTypeCache.get(viewClsName);

        if (viewType == null) { 
            // first time call in current build

            var index = ++viewIndex;

            try viewType = Context.getType(viewClsName) catch (err:String) {
                // type was not cached in previous build

                var viewTypePath = tpath([], viewClsName, []);
                var viewComplexType = TPath(viewTypePath);

                // signals
                var signalTypeParamComplexType = TFunction([ macro:echoes.Entity ].concat(components.map(function(c) return c.cls)), macro:Void);
                var signalTypePath = tpath(['echoes', 'utils'], 'Signal', [ TPType(signalTypeParamComplexType) ]);

                // signal args for dispatch() call
                var signalArgs = [ macro id ].concat(components.map(function(c) return macro $i{ getComponentContainer(c.cls).followName() }.inst().get(id)));

                // component related views
                var addViewToViewsOfComponent = components.map(function(c) {
                    var viewsOfComponentName = getViewsOfComponent(c.cls).followName();
                    return macro @:privateAccess $i{ viewsOfComponentName }.inst().addRelatedView(this);
                });

                // type def
                var def:TypeDefinition = macro class $viewClsName extends echoes.core.AbstractView {

                    static var instance = new $viewTypePath();

                    @:keep inline public static function inst():$viewComplexType {
                        return instance;
                    }

                    // instance

                    public var onAdded(default, null) = new $signalTypePath();
                    public var onRemoved(default, null) = new $signalTypePath();

                    function new() {
                        @:privateAccess echoes.Workflow.definedViews.push(this);
                        $b{ addViewToViewsOfComponent }
                    }

                    override function dispatchAddedCallback(id:Int) {
                        onAdded.dispatch($a{ signalArgs });
                    }

                    override function dispatchRemovedCallback(id:Int) {
                        onRemoved.dispatch($a{ signalArgs });
                    }

                    override function reset() {
                        super.reset();
                        onAdded.removeAll();
                        onRemoved.removeAll();
                    }

                }

                //var iteratorTypePath = getViewIterator(components).tp();
                //def.fields.push(ffun([], [APublic, AInline], 'iterator', null, null, macro return new $iteratorTypePath(this.echoes, this.entities.iterator()), Context.currentPos()));

                // iter
                {
                    var funcComplexType = TFunction([ macro:echoes.Entity ].concat(components.map(function(c) return c.cls)), macro:Void);
                    var funcCallArgs = [ macro __entity__ ].concat(components.map(function(c) return macro $i{ getComponentContainer(c.cls).followName() }.inst().get(__entity__)));
                    var body = macro {
                        for (__entity__ in entities) {
                            f($a{ funcCallArgs });
                        }
                    }
                    def.fields.push(ffun([APublic, AInline], 'iter', [arg('f', funcComplexType)], macro:Void, macro $body, Context.currentPos()));
                }

                // isMatched
                {
                    var checks = components.map(function(c) return macro $i{ getComponentContainer(c.cls).followName() }.inst().exists(id));
                    var cond = checks.slice(1).fold(function(check1, check2) return macro $check1 && $check2, checks[0]);
                    var body = macro return $cond;
                    def.fields.push(ffun([AOverride], 'isMatched', [arg('id', macro:Int)], macro:Bool, body, Context.currentPos()));
                }

                // toString
                {
                    var componentNames = components.map(function(c) return c.cls.typeValidShortName()).join(', ');
                    var body = macro return $v{ componentNames };
                    def.fields.push(ffun([AOverride, APublic], 'toString', null, macro:String, body, Context.currentPos()));
                }

                Context.defineType(def);

                viewType = viewComplexType.toType();
            }

            // caching current build
            viewTypeCache.set(viewClsName, viewType);
            viewCache.set(viewClsName, { cls: viewType.toComplexType(), components: components });

            viewIds[viewClsName] = index;
            viewNames.push(viewClsName);
        }

        return viewType;
    }


}
#end