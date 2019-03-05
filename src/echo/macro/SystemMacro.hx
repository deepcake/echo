package echo.macro;

#if macro
import echo.macro.Macro.*;
import echo.macro.MacroBuilder.*;
import echo.macro.ViewMacro.*;
import echo.macro.ComponentMacro.*;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Printer;
import haxe.macro.Type.ClassField;

using haxe.macro.ComplexTypeTools;
using haxe.macro.Context;
using echo.macro.Macro;
using StringTools;
using Lambda;

class SystemMacro {


    public static var EXCLUDE_META = [ 'skip' ];
    public static var ADD_META = [ 'added', 'ad', 'a' ];
    public static var REMOVE_META = [ 'removed', 'rm', 'r' ];
    public static var UPDATE_META = [ 'update', 'up', 'u' ];

    public static var systemIndex:Int = 0;
    public static var systemIds:Map<String, Int> = new Map();


    public static function build() {
        var fields = Context.getBuildFields();
        var cls = Context.getLocalType().toComplexType();

        systemIds[cls.followName()] = ++systemIndex;

        var fnew = fields.find(function(f) return f.name == 'new');
        if (fnew == null) {
            fields.push(ffun([APublic], 'new', null, null, macro __id = $v{ systemIndex }, Context.currentPos()));
        } else {
            switch (fnew.kind) {
                case FFun(func):
                    var fnewexprs = [ macro __id = $v{ systemIndex } ];

                    switch (func.expr.expr) {
                        case EBlock(exprs): for (expr in exprs) fnewexprs.push(expr);
                        case e: fnewexprs.push(func.expr);
                    }

                    func.expr = macro $b{fnewexprs};

                default:
            }
        }

        var views = fields.map(function(field) {
            if (hasMeta(field, EXCLUDE_META)) return null; // skip by meta

            switch (field.kind) {
                case FVar(cls, e) if (e == null):
                    var viewCls = cls.followComplexType();
                    var viewClsName = viewCls.followName();
                    if (viewDataCache.exists(viewClsName)) {
                        return { name: field.name, cls: viewCls, components: viewDataCache.get(viewClsName).components };
                    }

                case FVar(_, _.expr => ENew(t, _)):
                    var viewCls = TPath(t).followComplexType();
                    var viewClsName = viewCls.followName();
                    if (viewDataCache.exists(viewClsName)) {
                        field.kind = FVar(viewCls, null); // TODO only if exists ?
                        return { name: field.name, cls: viewCls, components: viewDataCache.get(viewClsName).components };
                    }

                default:
            }

            return null;

        } ).filter(function(el) return el != null);


        function extFunc(f:Field) {
            return switch (f.kind) {
                case FFun(x): x;
                case x: null;
            }
        }

        function requestView(components) {
            var viewClsName = getViewName(components);
            var view = views.find(function(v) return v.cls.followName() == viewClsName);

            if (view == null) {
                var viewName = viewClsName.toLowerCase();
                var viewCls = getView(components);

                fields.push(fvar(viewName, viewCls, Context.currentPos()));

                view = { name: viewName, cls: viewCls, components: viewDataCache.get(viewClsName).components };
                views.push(view);
            }

            return view;
        }


        function notNull(e:Dynamic) return e != null;

        function argToCallArg(a:FunctionArg) {
            return switch (a.type) {
                case macro:Float : macro dt;
                case macro:Int : macro id;
                default: {
                    return switch (a.type.followComplexType()) {
                        case macro:echo.Entity : macro id;
                        default: macro $i{ a.name };
                    }
                }
            }
        }

        function componentToViewArg(c:{ name:String, cls:ComplexType }, args:Array<FunctionArg>) {
            var copmonentClsName = c.cls.followName();
            var a = args.find(function(a) return a.type.followName() == copmonentClsName);
            if (a != null) {
                return arg(a.name, a.type);
            } else {
                return arg(c.name, c.cls);
            }
        }

        function argToComponent(a) {
            return switch (a.type) {
                case macro:Int, macro:Float : null;
                default: {
                    return switch (a.type.followComplexType()) {
                        case macro:echo.Entity : null;
                        default: { name: a.name, cls: a.type.followComplexType() };
                    }
                }
            }
        }

        function addViewByMetaAndComponents(components:Array<{ name:String, cls:ComplexType }>, m:MetadataEntry) {
            return switch (m.params) {
                //case [ _.expr => EConst(CString(x)) ]: views.find(function(v) return v.name == x);
                //case [ _.expr => EConst(CInt(x)) ]: views[Std.parseInt(x)];
                case [] if (components.length == 0 && views.length == 1): views[0];
                case [] if (components.length > 0): requestView(components);
                default: null;
            }
        }

        function findMetaFunc(f:Field, meta:Array<String>) {
            if (hasMeta(f, EXCLUDE_META)) {
                return null; // skip by meta
            } else if (hasMeta(f, meta)) {
                var func = extFunc(f);
                if (func == null) return null; // skip if not a func

                var components = func.args.map(argToComponent).filter(notNull);

                var view = addViewByMetaAndComponents(components, getMeta(f, meta));
                var viewArgs = view != null ? [ arg('id', macro:echo.Entity) ].concat(view.components.map(componentToViewArg.bind(_, func.args))) : [];

                var funcName = f.name;
                var funcArgs = func.args.map(argToCallArg).filter(notNull);

                return { name: funcName, args: funcArgs, components: components, view: view, viewargs: viewArgs };
            }
            return null;
        }


        var ufuncs = fields.map(findMetaFunc.bind(_, UPDATE_META)).filter(notNull);

        var afuncs = fields.map(findMetaFunc.bind(_, ADD_META)).filter(notNull);
        var rfuncs = fields.map(findMetaFunc.bind(_, REMOVE_META)).filter(notNull);

        afuncs.concat(rfuncs).iter(function(f) {
            //fields.push(ffun([], [], '__${f.name}', [arg('_id_', macro:Int)], null, macro $i{ f.name }($a{ f.args }), Context.currentPos()));
            fields.push(fvar([], [], '__${f.name}', TFunction(f.viewargs.map(function(a) return a.type), macro:Void), null, Context.currentPos()));
        });


        var updateExprs = new List<Expr>()
            .concat(ufuncs.map(function(f){
                if (f.components.length == 0) {
                    return macro $i{ f.name }($a{ f.args });
                } else {
                    var fwrapper = { expr: EFunction(null, { args: f.viewargs, ret: macro:Void, expr: macro $i{ f.name }($a{ f.args }) }), pos: Context.currentPos()};
                    return macro $i{ f.view.name }.iter($fwrapper);
                }
            }))
            .array();

        var activateExprs = new List<Expr>()
            .concat(
                afuncs.concat(rfuncs)
                    .map(function(f){
                        var fwrapper = { expr: EFunction(null, { args: f.viewargs, ret: macro:Void, expr: macro $i{ f.name }($a{ f.args }) }), pos: Context.currentPos()};
                        return macro $i{'__${f.name}'} = $fwrapper;
                    })
            )
            .concat(
                views
                    .map(function(v){
                        var viewCls = v.cls; //getViewGenericComplexType(v.components);
                        var viewType = viewCls.tp();
                        var viewId = viewIds[viewCls.followName()];
                        return [
                            macro $i{ v.name } = ${ viewCls.expr(Context.currentPos()) }.inst(),
                            macro $i{ v.name }.activate()
                        ];
                    })
                    .flatten()
            )
            .concat(
                afuncs.map(function(f){
                    return macro $i{ f.view.name }.onAdded.add($i{ '__${f.name}' });
                })
            )
            .concat(
                rfuncs.map(function(f){
                    return macro $i{ f.view.name }.onRemoved.add($i{ '__${f.name}' });
                })
            )
            .concat([ macro onactivate() ])
            .concat(
                afuncs.map(function(f){
                    var fwrapper = { expr: EFunction(null, { args: f.viewargs, ret: macro:Void, expr: macro $i{ f.name }($a{ f.args }) }), pos: Context.currentPos()};
                    return macro $i{ f.view.name }.iter($fwrapper);
                })
            )
            .array();

        var deactivateExprs = new List<Expr>()
            .concat([ macro ondeactivate() ])
            .concat(
                afuncs.map(function(f){
                    return macro $i{ f.view.name }.onAdded.remove($i{ '__${f.name}' });
                })
            )
            .concat(
                rfuncs.map(function(f){
                    return macro $i{ f.view.name }.onRemoved.remove($i{ '__${f.name}' });
                })
            )
            .concat(
                afuncs.concat(rfuncs)
                    .map(function(f) {
                        return macro $i{'__${f.name}'} = null;
                    })
            )
            .array();


        if (updateExprs.length > 0) {
            var func = (function() {
                for (field in fields) {
                    switch (field.kind) {
                        case FFun(func): if (field.name == 'update') return func;
                        default:
                    }
                }
                return null;
            })();

            if (func != null) {
                switch (func.expr.expr) {
                    case EBlock(exprs): for (expr in exprs) updateExprs.push(expr);
                    case e: updateExprs.push(func.expr);
                }
                func.expr = macro $b{updateExprs};
            } else {
                fields.push(ffun([APublic, AOverride], 'update', [arg('dt', macro:Float)], null, macro $b{updateExprs}, Context.currentPos()));
            }
        }

        fields.push(ffun([APublic, AOverride], 'activate', [], null, macro $b{activateExprs}, Context.currentPos()));
        fields.push(ffun([APublic, AOverride], 'deactivate', [], null, macro $b{deactivateExprs}, Context.currentPos()));

        // toString
        fields.push(ffun([AOverride, APublic], 'toString', null, macro:String, macro return $v{ cls.followName() }, Context.currentPos()));

        traceFields(cls.followName(), fields);

        return fields;
    }

}
#end