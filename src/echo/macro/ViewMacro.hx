package echo.macro;

#if macro
import echo.macro.Macro.*;
import echo.macro.MacroBuilder.*;
import echo.macro.ComponentMacro.*;

import haxe.macro.Expr;
import haxe.macro.Type.ClassField;

using haxe.macro.ComplexTypeTools;
using haxe.macro.Context;
using echo.macro.Macro;
using Lambda;

typedef ViewMacroData = { cls:ComplexType, components:Array<{ name:String, cls:ComplexType }> };

class ViewMacro {


    public static var viewIndex:Int = -1;
    public static var viewIdsMap:Map<String, Int> = new Map();
    public static var viewCache:Map<String, ComplexType> = new Map();
    public static var viewMasks:Map<Int, Map<Int, Bool>> = new Map();

    //public static var viewTypeCache:Map<String, haxe.macro.Type> = new Map();

    //public static var viewIterCache:Map<String, ComplexType> = new Map();

    //public static var viewDataCache:Map<String, ComplexType> = new Map();

    public static var viewDataCache = new Map<String, ViewMacroData>();


    public static function build() {
        return createViewType(Context.getLocalType());
    }


    static function createViewType(type:haxe.macro.Type) {
        return switch(type) {
            case TInst(_, [x = TType(_, _) | TAnonymous(_) | TFun(_, _)]):
                createViewType(x);

            case TType(_.get() => { type: x }, []):
                createViewType(x);

            case TAnonymous(_.get() => p):
                var components = p.fields.map(function(field:ClassField) return { name: field.name, cls: Context.toComplexType(field.type.follow()) });
                getView(components).toType();

            case TFun(args, _):
                var components = args.mapi(function(i, a) return { name: a.t.follow().toComplexType().tp().name.toLowerCase(), cls: a.t.follow().toComplexType() }).array();
                getView(components).toType();

            case TInst(_, types):
                var components = types.mapi(function(i, t) return { name: t.follow().toComplexType().tp().name.toLowerCase(), cls: t.follow().toComplexType() }).array();
                getView(components).toType();

            case x: throw 'Unexpected $x';
        }
    }


    public static function getView(components:Array<{ name:String, cls:ComplexType }>):ComplexType {
        gen();

        var viewClsName = getClsName('View', getClsNameSuffixByComponents(components));
        var viewCls = viewCache.get(viewClsName);

        //if (viewCls == null) {
        try {

            viewCls = Context.getType(viewClsName).toComplexType();

        } catch (err:String) {

            viewIdsMap[viewClsName] = ++viewIndex;

            var viewTypePath = tpath([], viewClsName, []);
            var viewComplexType = TPath(viewTypePath);

            var def:TypeDefinition = macro class $viewClsName extends echo.View.ViewBase {

                static var views:Map<Int, $viewComplexType>; // echo id => v inst

                @:access(echo.Echo) static function __init__() {
                    views = new Map();
                    echo.Echo.__initView($v{ viewIndex }, create, destroy);
                }

                static function create(eid:Int):$viewComplexType {
                    views[eid] = new $viewTypePath();
                    return views[eid];
                }

                static function destroy(eid:Int):Void {
                    views.remove(eid);
                }

                @:keep inline public static function inst(eid:Int):$viewComplexType {
                    return views[eid];
                }

                // instance

                public function new() {
                    __id = $v{ viewIndex };
                }

                inline function exists(id:Int):Bool {
                    return entitiesMap.exists(id);
                }

                override function addIfMatch(id:Int) {
                    if (!exists(id) && isMatch(id)) add(id);
                }

                override function removeIfMatch(id:Int) {
                    if (exists(id)) remove(id);
                }

            }

            //var iteratorTypePath = getViewIterator(components).tp();
            //def.fields.push(ffun([], [APublic, AInline], 'iterator', null, null, macro return new $iteratorTypePath(this.echo, this.entities.iterator()), Context.currentPos()));

            function ccref(ct:ComplexType) {
                return ct.shortName().toLowerCase(); // TODO use names
            }

            // signals
            var signalTypeParamComplexType = TFunction([ macro:Int ].concat(components.map(function(c) return c.cls)), macro:Void);
            var signalTypePath = tpath(['echo', 'utils'], 'Signal', [ TPType(signalTypeParamComplexType) ]);
            var signalComplexType = macro:echo.utils.Signal<$signalTypeParamComplexType>;
            def.fields.push(fvar([#if haxe-ver >= 4.000 AFinal, #end APublic], 'onAdded', signalComplexType, macro new $signalTypePath(), Context.currentPos()));
            def.fields.push(fvar([#if haxe-ver >= 4.000 AFinal, #end APublic], 'onRemoved', signalComplexType, macro new $signalTypePath(), Context.currentPos()));

            // add/remove
            var callArgs = [ macro id ].concat(components.map(function(c) return macro $i{ ccref(c.cls) }.get(id)));

            var addExprs = [
                    macro entitiesMap.set(id, id), 
                    macro entities.add(id)
                ].concat([
                    macro onAdded.dispatch($a{ callArgs })
                ]);
            def.fields.push(ffun([AInline], 'add', [arg('id', macro:Int)], macro:Void, macro $b{ addExprs }, Context.currentPos()));

            var removeExprs = [
                    macro onRemoved.dispatch($a{ callArgs })
                ].concat([
                    macro entities.remove(id),
                    macro entitiesMap.remove(id)
                ]);
            def.fields.push(ffun([AInline], 'remove', [arg('id', macro:Int)], macro:Void, macro $b{ removeExprs }, Context.currentPos()));

            // def cc
            components.mapi(function(i, c) {
                var name = ccref(c.cls);
                def.fields.push(fvar([APublic], name, getComponentContainer(c.cls), null, Context.currentPos()));
            });

            // activate
            var activateExprs = new List<Expr>()
                .concat(
                    components.mapi(function(i, c) return macro $i{ ccref(c.cls) } = ${ getComponentContainer(c.cls).expr(Context.currentPos()) }.inst(echo.__id))
                )
                .concat(
                    [ macro super.activate(echo) ]
                )
                .array();
            def.fields.push(ffun([AOverride], 'activate', [arg('echo', macro:echo.Echo)], macro:Void, macro $b{ activateExprs }, Context.currentPos()));

            // deact
            var deactivateExprs = new List<Expr>()
                .concat(
                    components.mapi(function(i, c) return macro $i{ ccref(c.cls) } = null)
                )
                .concat(
                    [ macro super.deactivate() ]
                )
                .array();
            def.fields.push(ffun([AOverride], 'deactivate', [], macro:Void, macro $b{ deactivateExprs }, Context.currentPos()));

            // iter
            var ctypes = [ macro:Int ].concat(components.map(function(c) return c.cls));
            var cargs = [ macro e ].concat(components.map(function(c) return macro $i{ ccref(c.cls) }.get(e)));
            var iterBody = macro for (e in entities) f($a{ cargs });
            def.fields.push(ffun([APublic, AInline], 'iter', [arg('f', TFunction(ctypes, macro:Void))], macro:Void, macro $iterBody, Context.currentPos()));

            // isMatch
            var testBody = Context.parse('return ' + components.map(function(c) return '${ccref(c.cls)}.get(id) != null').join(' && '), Context.currentPos());
            def.fields.push(ffun([AOverride], 'isMatch', [arg('id', macro:Int)], macro:Bool, testBody, Context.currentPos()));

            // isRequire
            def.fields.push(ffun([AOverride], 'isRequire', [arg('c', macro:Int)], macro:Bool, macro return __mask[c] != null, Context.currentPos()));

            // mask
            var maskBody = Context.parse('[' + components.map(function(c) return '${getComponentId(c.cls)} => true').join(', ') + ']', Context.currentPos());
            def.fields.push(fvar([AStatic], '__mask', null, maskBody, Context.currentPos()));

            // toString
            var stringBody = getClsNameSuffix(components.map(function(c) return c.cls), false);
            def.fields.push(ffun([AOverride, APublic], 'toString', null, macro:String, macro return $v{ stringBody }, Context.currentPos()));

            traceTypeDefenition(def);

            Context.defineType(def);

            viewMasks.set(viewIndex, new Map<Int, Bool>());
            components.iter(function(c) viewMasks[viewIndex].set(getComponentId(c.cls), true));

            viewCls = Context.getType(viewClsName).toComplexType();
            viewCache.set(viewClsName, viewCls);
            viewDataCache.set(viewClsName, { cls: viewCls, components: components.map(function(c) return { name: ccref(c.cls), cls: c.cls }) });
        }

        return viewCls;
    }


    /*public static function getViewIterator(components:Array<{ name:String, cls:ComplexType }>):ComplexType {
        var viewDataCls = getViewData(components);
        var viewIterClsName = getClsName('ViewIterator', viewDataCls.followName());
        var viewIterCls = viewIterCache.get(viewIterClsName);
        if (viewIterCls == null) {

            var viewDataType = viewDataCls.tp();

            var def = macro class $viewIterClsName {
                var ch:echo.Echo;
                var it:Iterator<Int>;
                var vd:$viewDataCls;
                public inline function new(ch:echo.Echo, it:Iterator<Int>) {
                    this.ch = ch;
                    this.it = it;
                    this.vd = new $viewDataType(); // TODO opt js ( Object ? )
                }
                public inline function hasNext():Bool return it.hasNext();
                //public inline function next():$dataViewCls return vd;
            }

            var nextExprs = [];
            nextExprs.push(macro this.vd.id = this.it.next());
            components.iter(function(c) nextExprs.push(Context.parse('this.vd.${c.name} = ${getComponentContainer(c.cls).followName()}.get(ch.__id)[this.vd.id]', Context.currentPos())));
            nextExprs.push(macro return this.vd);
            def.fields.push(ffun([APublic, AInline], 'next', null, viewDataCls, macro $b{nextExprs}, Context.currentPos()));

            traceTypeDefenition(def);

            Context.defineType(def);

            viewIterCls = Context.getType(viewIterClsName).toComplexType();
            viewIterCache.set(viewIterClsName, viewIterCls);
        }
        return viewIterCls;
    }*/


    /*public static function getViewData(components:Array<{ name:String, cls:ComplexType }>):ComplexType {
        var viewDataClsName = getClsName('ViewData', getClsNameSuffixByComponents(components));
        var viewDataCls = viewDataCache.get(viewDataClsName);

        if (viewDataCls == null) {
            try {
                Context.getType(viewDataClsName);

            } catch(error:String) {

                trace('#view $error');

            var def:TypeDefinition = macro class $viewDataClsName {
                inline public function new() { }
                public var id:Int;
            }

            for (c in components) def.fields.push(fvar([APublic], c.name, c.cls, Context.currentPos()));

            traceTypeDefenition(def);

            Context.defineType(def);
            }

            viewDataCls = Context.getType(viewDataClsName).toComplexType();
            viewDataCache.set(viewDataClsName, viewDataCls);
        }
        return viewDataCls;
    }*/

}
#end