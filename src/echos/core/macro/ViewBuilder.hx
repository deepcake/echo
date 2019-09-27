package echos.core.macro;

#if macro
import echos.core.macro.MacroTools.*;
import echos.core.macro.ComponentBuilder.*;
import haxe.macro.Expr;
import haxe.macro.Type.ClassField;

using echos.core.macro.MacroTools;
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
        return 'ViewOf' + components.map(function(c) return c.cls).packName();
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
            // first time call in current macro phase

            var index = ++viewIndex;

            try viewType = Context.getType(viewClsName) catch (err:String) {
                // type was not cached in previous macro phases

                var viewTypePath = tpath([], viewClsName, []);
                var viewComplexType = TPath(viewTypePath);

                // signals
                var signalTypeParamComplexType = TFunction([ macro:echos.Entity ].concat(components.map(function(c) return c.cls)), macro:Void);
                var signalTypePath = tpath(['echos', 'utils'], 'Signal', [ TPType(signalTypeParamComplexType) ]);

                // signal args for dispatch() call
                var signalArgs = [ macro id ].concat(components.map(function(c) return macro $i{ getComponentContainer(c.cls).followName() }.inst().get(id)));

                // type def
                var def:TypeDefinition = macro class $viewClsName extends echos.core.AbstractView {

                    static var instance = new $viewTypePath();

                    @:keep inline public static function inst():$viewComplexType {
                        return instance;
                    }

                    // instance

                    public var onAdded(default, null) = new $signalTypePath();
                    public var onRemoved(default, null) = new $signalTypePath();

                    function new() {
                        @:privateAccess echos.Workflow.definedViews.push(this);
                    }

                    override function add(id:Int) {
                        super.add(id);
                        onAdded.dispatch($a{ signalArgs });
                    }

                    override function remove(id:Int) {
                        onRemoved.dispatch($a{ signalArgs });
                        super.remove(id);
                    }

                    override function reset() {
                        super.reset();
                        onAdded.removeAll();
                        onRemoved.removeAll();
                    }

                }

                //var iteratorTypePath = getViewIterator(components).tp();
                //def.fields.push(ffun([], [APublic, AInline], 'iterator', null, null, macro return new $iteratorTypePath(this.echos, this.entities.iterator()), Context.currentPos()));

                // iter
                {
                    var funcComplexType = TFunction([ macro:echos.Entity ].concat(components.map(function(c) return c.cls)), macro:Void);
                    var funcCallArgs = [ macro __entity__ ].concat(components.map(function(c) return macro $i{ getComponentContainer(c.cls).followName() }.inst().get(__entity__)));
                    var body = macro {
                        for (__entity__ in entities) {
                            f($a{ funcCallArgs });
                        }
                    }
                    def.fields.push(ffun([APublic, AInline], 'iter', [arg('f', funcComplexType)], macro:Void, macro $body, Context.currentPos()));
                }

                // isMatch
                {
                    var checks = components.map(function(c) return macro $i{ getComponentContainer(c.cls).followName() }.inst().get(id) != null);
                    var cond = checks.slice(1).fold(function(check1, check2) return macro $check1 && $check2, checks[0]);
                    var body = macro return $cond;
                    def.fields.push(ffun([AOverride], 'isMatch', [arg('id', macro:Int)], macro:Bool, body, Context.currentPos()));
                }

                // isRequire
                {
                    var body = macro return __mask[c] != null;
                    def.fields.push(ffun([AOverride], 'isRequire', [arg('c', macro:Int)], macro:Bool, body, Context.currentPos()));
                }

                // mask
                {
                    var flags = components.map(function(c) return macro $v{ getComponentId(c.cls) } => true);
                    var body = macro [ $a{ flags } ];
                    def.fields.push(fvar([AStatic], '__mask', null, body, Context.currentPos()));
                }

                // toString
                {
                    var componentNames = components.map(function(c) return c.cls.followName()).join('+');
                    var body = macro return $v{ componentNames };
                    def.fields.push(ffun([AOverride, APublic], 'toString', null, macro:String, body, Context.currentPos()));
                }

                traceTypeDefenition(def);

                Context.defineType(def);

                viewType = viewComplexType.toType();
            }

            // caching current macro phase
            viewTypeCache.set(viewClsName, viewType);
            viewCache.set(viewClsName, { cls: viewType.toComplexType(), components: components });

            viewIds[viewClsName] = index;
            viewNames.push(viewClsName);
        }

        return viewType;
    }


}
#end