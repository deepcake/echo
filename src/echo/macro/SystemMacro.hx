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


    public static var EXCLUDE_META = ['skip', 'ignore', 'i'];
    public static var ONADD_META = ['onadded', 'added', 'onadd', 'add', 'a'];
    public static var ONREMOVE_META = ['onremoved', 'removed', 'onremove', 'onrem', 'remove', 'rem', 'r'];
    public static var ONEACH_META = ['update', 'upd', 'u'];

    public static var systemIndex:Int = 0;
    public static var systemIdsMap:Map<String, Int> = new Map();


    public static function build() {

        gen();
        var fields = Context.getBuildFields();
        var cls = Context.getLocalType().toComplexType();

        systemIdsMap[cls.followName()] = ++systemIndex;

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
                    if (viewCache.exists(viewCls.followName())) {
                        return { name: field.name, cls: viewCls };
                    }

                case FVar(_, _.expr => ENew(t, _)):
                    var viewCls = TPath(t).followComplexType();
                    if (viewCache.exists(viewCls.followName())) {
                        field.kind = FVar(viewCls, null);
                        return { name: field.name, cls: viewCls };
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
            var viewClsName = getClsName('View', getClsNameSuffixByComponents(components));
            var view = views.find(function(v) return v.cls.followName() == viewClsName);

            if (view == null) {
                var viewName = viewClsName.toLowerCase();
                var viewCls = getViewGenericComplexType(components);
                fields.push(fvar(viewName, viewCls, Context.currentPos()));
                view = { name: viewName, cls: viewCls };
                views.push(view);
            }

            return view.name;
        }


        function notNull(e:Dynamic) return e != null;

        function argToArg(a) {
            return switch (a.type) {
                case macro:Float: macro dt;
                case macro:Int: macro _id_;
                default: macro ${ getComponentHolder(a.type.followComplexType()).expr(Context.currentPos()) }.get(echo.__id)[_id_];
            }
        };

        function argToComponent(a) {
            return switch (a.type) {
                case macro:Int, macro:Float: null;
                default: { name: a.name, cls: a.type.followComplexType() };
            }
        };

        function addViewByMetaAndComponents(components:Array<{ name:String, cls:ComplexType }>, m:MetadataEntry) {
            return switch (m.params) {
                case [ _.expr => EConst(CString(x)) ]: x;
                case [ _.expr => EConst(CInt(x)) ]: views[Std.parseInt(x)].name;
                case [] if (components.length == 0 && views.length > 0): views[0].name;
                case [] if (components.length > 0): requestView(components);
                default: null;
            }
        }

        function findMetaFunc(f:Field, meta:Array<String>) {
            if (hasMeta(f, EXCLUDE_META)) return null; // skip by meta
            else if (hasMeta(f, meta)) {
                var func = extFunc(f);
                if (func == null) return null; // skip if not a func

                var funcName = f.name;
                var funcArgs = func.args.map(argToArg).filter(notNull);
                var components = func.args.map(argToComponent).filter(notNull);
                var view = addViewByMetaAndComponents(components, getMeta(f, meta));

                return { name: funcName, args: funcArgs, components: components, view: view };
            }
            return null;
        }


        var ufuncs = fields.map(findMetaFunc.bind(_, ONEACH_META)).filter(notNull);

        var afuncs = fields.map(findMetaFunc.bind(_, ONADD_META)).filter(notNull);
        var rfuncs = fields.map(findMetaFunc.bind(_, ONREMOVE_META)).filter(notNull);

        afuncs.concat(rfuncs).iter(function(f) {
            //fields.push(ffun([], [], '__${f.name}', [arg('_id_', macro:Int)], null, macro $i{ f.name }($a{ f.args }), Context.currentPos()));
            fields.push(fvar([], [], '__${f.name}', macro:Int->Void, null, Context.currentPos()));
        });


        var updateExprs = new List<Expr>()
            .concat(ufuncs.map(function(f){
                if (f.components.length == 0) {
                    return macro $i{ f.name }($a{ f.args });
                } else {
                    //var viewName = requestView(f.components);
                    return macro {
                        for (_id_ in $i{ f.view }.entities) $i{ f.name }($a{ f.args });
                    }
                }
            }))
            .array();

        var activateExprs = new List<Expr>()
            .concat([ macro this.echo = echo ])
            .concat(
                afuncs.concat(rfuncs)
                    .map(function(f){
                        return macro $i{'__${f.name}'} = function(_id_:Int) $i{ f.name }($a{ f.args });
                    })
            )
            .concat(
                views
                    .map(function(v){
                        var viewCls = v.cls; //getViewGenericComplexType(v.components);
                        var viewType = viewCls.tp();
                        var viewId = viewIdsMap[viewCls.followName()];
                        return [
                            macro if (!echo.viewsMap.exists($v{ viewId })) echo.addView(new $viewType()),
                            macro $i{ v.name } = cast echo.viewsMap[$v{ viewId }]
                        ];
                    })
                    .flatten()
            )
            .concat(
                afuncs.map(function(f){
                    return macro $i{ f.view }.onAdded.add($i{ '__${f.name}' });
                })
            )
            .concat(
                rfuncs.map(function(f){
                    return macro $i{ f.view }.onRemoved.add($i{ '__${f.name}' });
                })
            )
            .concat([ macro onactivate() ])
            .concat(
                afuncs.map(function(f){
                    return macro for (i in $i{ f.view }.entities) $i{ '__${f.name}' }(i);
                })
            )
            .array();

        var deactivateExprs = new List<Expr>()
            .concat([ macro ondeactivate() ])
            .concat(
                afuncs.map(function(f){
                    return macro $i{ f.view }.onAdded.remove($i{ '__${f.name}' });
                })
            )
            .concat(
                rfuncs.map(function(f){
                    return macro $i{ f.view }.onRemoved.remove($i{ '__${f.name}' });
                })
            )
            .concat(
                afuncs.concat(rfuncs)
                    .map(function(f) {
                        return macro $i{'__${f.name}'} = null;
                    })
            )
            .concat([ macro this.echo = null ])
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

        fields.push(ffun([APublic, AOverride], 'activate', [arg('echo', macro:echo.Echo)], null, macro $b{activateExprs}, Context.currentPos()));
        fields.push(ffun([APublic, AOverride], 'deactivate', null, null, macro $b{deactivateExprs}, Context.currentPos()));

        // toString
        fields.push(ffun([AOverride, APublic], 'toString', null, macro:String, macro return $v{ cls.followName() }, Context.currentPos()));

        traceFields(cls.followName(), fields);

        return fields;
    }

}
#end