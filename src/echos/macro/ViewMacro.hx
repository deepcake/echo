package echos.macro;

#if macro
import echos.macro.Macro.*;
import echos.macro.MacroBuilder.*;
import echos.macro.ComponentMacro.*;
import echos.macro.MacroBuilder;

import haxe.macro.Expr;
import haxe.macro.Type.ClassField;

using haxe.macro.ComplexTypeTools;
using haxe.macro.Context;
using echos.macro.Macro;
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
        return macro ${ getComponentContainer(ct).expr(Context.currentPos()) }.inst();
    }


    public static function createViewType(components:Array<ComponentDef>) {
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
                var signalArgs = [ macro id ].concat(components.map(function(c) return macro ${ ccref(c.cls) }.get(id)));

                // type def
                var def:TypeDefinition = macro class $viewClsName extends echos.View.ViewBase {

                    static var instance = new $viewTypePath();

                    @:keep inline public static function inst():$viewComplexType {
                        return instance;
                    }

                    // instance

                    public var onAdded(default, null) = new $signalTypePath();
                    public var onRemoved(default, null) = new $signalTypePath();

                    function new() {
                        activate();
                    }

                    override function add(id:Int) {
                        super.add(id);
                        onAdded.dispatch($a{ signalArgs });
                    }

                    override function remove(id:Int) {
                        onRemoved.dispatch($a{ signalArgs });
                        super.remove(id);
                    }

                    override function dispose() {
                        super.dispose();
                        onAdded.dispose();
                        onRemoved.dispose();
                    }

                }

                //var iteratorTypePath = getViewIterator(components).tp();
                //def.fields.push(ffun([], [APublic, AInline], 'iterator', null, null, macro return new $iteratorTypePath(this.echos, this.entities.iterator()), Context.currentPos()));


                // iter
                {
                    var funcComplexType = TFunction([ macro:echos.Entity ].concat(components.map(function(c) return c.cls)), macro:Void);
                    var funcCallArgs = [ macro e ].concat(components.map(function(c) return macro ${ ccref(c.cls) }.get(e)));
                    var body = macro for (e in entities) f($a{ funcCallArgs });
                    def.fields.push(ffun([APublic, AInline], 'iter', [arg('f', funcComplexType)], macro:Void, macro $body, Context.currentPos()));
                }

                // isMatch
                {
                    var checks = components.map(function(c) return macro ${ ccref(c.cls) }.get(id) != null);
                    var cond = checks.slice(1).fold(function(check1, check2) return macro $check1 && $check2, checks[0]);
                    var body = macro return $cond;
                    def.fields.push(ffun([AOverride], 'isMatch', [arg('id', macro:Int)], macro:Bool, body, Context.currentPos()));
                }

                // isRequire
                def.fields.push(ffun([AOverride], 'isRequire', [arg('c', macro:Int)], macro:Bool, macro return __mask[c] != null, Context.currentPos()));

                // mask
                {
                    var flags = components.map(function(c) return macro $v{ getComponentId(c.cls) } => true);
                    var body = macro [ $a{ flags } ];
                    def.fields.push(fvar([AStatic], '__mask', null, body, Context.currentPos()));
                }

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
            viewDataCache.set(viewClsName, { cls: viewType.toComplexType(), components: components });
            viewComponentsCache.set(viewClsName, components);

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