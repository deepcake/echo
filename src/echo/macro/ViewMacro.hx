package echo.macro;

#if macro
import echo.macro.Macro.*;
import echo.macro.MacroBuilder.*;
import echo.macro.ComponentMacro.*;
import echo.macro.MacroBuilder;

import haxe.macro.Expr;
import haxe.macro.Type.ClassField;

using haxe.macro.ComplexTypeTools;
using haxe.macro.Context;
using echo.macro.Macro;
using Lambda;

typedef ViewMacroData = { cls:ComplexType, components:Array<{ name:String, cls:ComplexType }> }; // TODO

class ViewMacro {


    static var viewIndex = -1;
    static var viewTypeCache = new Map<String, haxe.macro.Type>();

    public static var viewIds = new Map<String, Int>();
    public static var viewNames = new Array<String>();

    public static var viewDataCache = new Map<String, ViewMacroData>();
    public static var viewComponentsCache = new Map<String, Array<ComponentDef>>();


    public static function getViewName(components:Array<ComponentDef>) {
        return getClsName('View', getClsNameSuffixByComponents(components));
    }


    public static function build() {
        return genViewType(Context.getLocalType());
    }


    static function genViewType(type:haxe.macro.Type) {
        return switch(type) {
            case TInst(_, [x = TType(_, _) | TAnonymous(_) | TFun(_, _)]):
                genViewType(x);

            case TType(_.get() => { type: x }, []):
                genViewType(x);

            case TAnonymous(_.get() => p):
                var components = p.fields.map(function(field:ClassField) return { name: field.name, cls: Context.toComplexType(field.type.follow()) });
                createViewType(components);

            case TFun(args, _):
                var components = args.mapi(function(i, a) return { name: a.t.follow().toComplexType().tp().name.toLowerCase(), cls: a.t.follow().toComplexType() }).array();
                createViewType(components);

            case TInst(_, types):
                var components = types.mapi(function(i, t) return { name: t.follow().toComplexType().tp().name.toLowerCase(), cls: t.follow().toComplexType() }).array();
                createViewType(components);

            case x: throw 'Unexpected $x';
        }
    }


    static function ccref(ct:ComplexType) {
        return ct.shortName().toLowerCase(); // TODO use names ?
    }


    static function createViewType(components:Array<ComponentDef>) {
        var viewClsName = getViewName(components);
        var viewType = viewTypeCache.get(viewClsName);

        if (viewType == null) { 
            // first time call in current macro phase

            var index = ++viewIndex;

            try viewType = Context.getType(viewClsName) catch (err:String) {
                // type was not cached in previous macro phases

                var viewTypePath = tpath([], viewClsName, []);
                var viewComplexType = TPath(viewTypePath);

                var def:TypeDefinition = macro class $viewClsName extends echo.View.ViewBase {

                    static var instance = new $viewTypePath();

                    @:keep inline public static function inst():$viewComplexType {
                        return instance;
                    }

                    // instance

                    function new() {
                        __id = $v{ index }; // TODO
                        activate();
                    }

                }

                //var iteratorTypePath = getViewIterator(components).tp();
                //def.fields.push(ffun([], [APublic, AInline], 'iterator', null, null, macro return new $iteratorTypePath(this.echo, this.entities.iterator()), Context.currentPos()));

                // signals
                var signalTypeParamComplexType = TFunction([ macro:echo.Entity ].concat(components.map(function(c) return c.cls)), macro:Void);
                var signalTypePath = tpath(['echo', 'utils'], 'Signal', [ TPType(signalTypeParamComplexType) ]);
                var signalComplexType = macro:echo.utils.Signal<$signalTypeParamComplexType>;
                def.fields.push(fvar([#if haxe4 AFinal, #end APublic], 'onAdded', signalComplexType, macro new $signalTypePath(), Context.currentPos()));
                def.fields.push(fvar([#if haxe4 AFinal, #end APublic], 'onRemoved', signalComplexType, macro new $signalTypePath(), Context.currentPos()));

                // add/remove
                var signalArgs = [ macro id ].concat(components.map(function(c) return macro $i{ ccref(c.cls) }.get(id)));

                {
                    var exprs = [ macro super.add(id) , macro onAdded.dispatch($a{ signalArgs }) ];
                    def.fields.push(ffun([AOverride], 'add', [arg('id', macro:Int)], macro:Void, macro $b{ exprs }, Context.currentPos()));
                }

                {
                    var exprs = [ macro onRemoved.dispatch($a{ signalArgs }) , macro super.remove(id) ];
                    def.fields.push(ffun([AOverride], 'remove', [arg('id', macro:Int)], macro:Void, macro $b{ exprs }, Context.currentPos()));
                }

                // def cc
                components.mapi(function(i, c) {
                    var name = ccref(c.cls);
                    def.fields.push(fvar([APublic], name, getComponentContainer(c.cls), null, Context.currentPos()));
                });

                // activate/deactivate
                {
                    var exprs = []
                        .concat(
                            components.map(function(c) return macro $i{ ccref(c.cls) } = ${ getComponentContainer(c.cls).expr(Context.currentPos()) }.inst())
                        )
                        .concat(
                            [ macro super.activate() ]
                        );
                    def.fields.push(ffun([AOverride], 'activate', [], macro:Void, macro $b{ exprs }, Context.currentPos()));
                }

                {
                    var exprs = []
                        .concat(
                            components.map(function(c) return macro $i{ ccref(c.cls) } = null)
                        )
                        .concat(
                            [ macro super.deactivate() ]
                        );
                    def.fields.push(ffun([AOverride], 'deactivate', [], macro:Void, macro $b{ exprs }, Context.currentPos()));
                }


                // iter
                {
                    var funcComplexType = TFunction([ macro:echo.Entity ].concat(components.map(function(c) return c.cls)), macro:Void);
                    var funcCallArgs = [ macro e ].concat(components.map(function(c) return macro $i{ ccref(c.cls) }.get(e)));
                    var body = macro for (e in entities) f($a{ funcCallArgs });
                    def.fields.push(ffun([APublic, AInline], 'iter', [arg('f', funcComplexType)], macro:Void, macro $body, Context.currentPos()));
                }

                // isMatch
                var testBody = Context.parse('return ' + components.map(function(c) return '${ccref(c.cls)}.get(id) != null').join(' && '), Context.currentPos());
                def.fields.push(ffun([AOverride], 'isMatch', [arg('id', macro:Int)], macro:Bool, testBody, Context.currentPos()));

                // isRequire
                def.fields.push(ffun([AOverride], 'isRequire', [arg('c', macro:Int)], macro:Bool, macro return __mask[c] != null, Context.currentPos()));

                // mask
                var maskBody = Context.parse('[' + components.map(function(c) return '${getComponentId(c.cls)} => true').join(', ') + ']', Context.currentPos());
                def.fields.push(fvar([AStatic], '__mask', null, maskBody, Context.currentPos()));

                // toString
                {
                    var body = getClsNameSuffix(components.map(function(c) return c.cls), false);
                    def.fields.push(ffun([AOverride, APublic], 'toString', null, macro:String, macro return $v{ body }, Context.currentPos()));
                }

                traceTypeDefenition(def);

                Context.defineType(def);

                viewType = viewComplexType.toType();
            }

            // caching current macro phase
            viewTypeCache.set(viewClsName, viewType);
            viewDataCache.set(viewClsName, { cls: viewType.toComplexType(), components: components.map(function(c) return { name: ccref(c.cls), cls: c.cls }) });
            viewComponentsCache.set(viewClsName, components.map(function(c) return { name: ccref(c.cls), cls: c.cls }));

            viewIds[viewClsName] = index;
            viewNames.push(viewClsName);
        }

        return viewType;
    }


    public static function getView(components:Array<ComponentDef>):ComplexType {
        return createViewType(components).toComplexType();
    }


}
#end