package echos.macro;

#if macro
import echos.macro.Macro.*;
import echos.macro.MacroBuilder.*;
import echos.macro.ViewMacro.*;
import echos.macro.ComponentMacro.*;

import echos.macro.MacroBuilder;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Printer;
import haxe.macro.Type.ClassField;

using haxe.macro.ComplexTypeTools;
using haxe.macro.Context;
using echos.macro.Macro;
using StringTools;
using Lambda;

class SystemMacro {


    public static var EXCLUDE_META = [ 'skip' ];
    public static var ADD_META = [ 'added', 'ad', 'a' ];
    public static var REMOVE_META = [ 'removed', 'rm', 'r' ];
    public static var UPDATE_META = [ 'update', 'up', 'u' ];

    public static var systemIndex = -1;
    public static var systemIds = new Map<String, Int>();


    public static function build() {
        var fields = Context.getBuildFields();
        var cls = Context.getLocalType().toComplexType();

        var index = ++systemIndex;

        systemIds[cls.followName()] = index;

        // define new() if not exists
        if (!fields.exists(function(f) return f.name == 'new')) {
            fields.push(ffun([APublic], 'new', null, null, null, Context.currentPos()));
        }


        var definedViews = new Array<{ name:String, cls:ComplexType, components:Array<ComponentDef> }>();

        fields.iter(function(field) {
            if (!hasMeta(field, EXCLUDE_META)) {
                switch (field.kind) {
                    case FVar(cls, _) if (cls != null):
                        var fvarComplexType = cls.followComplexType();
                        var fvarClsName = fvarComplexType.followName();

                        // if it is a view
                        if (viewDataCache.exists(fvarClsName)) {
                            definedViews.push({ name: field.name, cls: fvarComplexType, components: viewDataCache.get(fvarClsName).components });
                        }

                    default:
                }
            }
        } );

        function notNull<T>(e:Null<T>) return e != null;

        function metaFuncArgToCallArg(a:FunctionArg) {
            return switch (a.type) {
                case macro:Float : macro dt;
                case macro:Int : macro id;
                default: {
                    return switch (a.type.followComplexType()) {
                        case macro:echos.Entity : macro id;
                        default: macro $i{ a.name };
                    }
                }
            }
        }

        function provideComponentToListenerArg(c:ComponentDef, args:Array<FunctionArg>) {
            var copmonentClsName = c.cls.followName();
            var a = args.find(function(a) return a.type.followName() == copmonentClsName);
            if (a != null) {
                return arg(a.name, a.type);
            } else {
                return arg(c.name, c.cls);
            }
        }

        function metaFuncArgToComponent(a:FunctionArg) {
            return switch (a.type) {
                case macro:Int, macro:Float : null;
                default: {
                    return switch (a.type.followComplexType()) {
                        case macro:echos.Entity : null;
                        default: { name: a.name, cls: a.type.followComplexType() };
                    }
                }
            }
        }

        function procMetaFunc(field:Field, meta:Array<String>) {
            if (!hasMeta(field, EXCLUDE_META) && hasMeta(field, meta)) {
                switch (field.kind) {
                    case FFun(func):
                        var funcName = field.name;
                        var callArgs = func.args.map(metaFuncArgToCallArg).filter(notNull);

                        var components = func.args.map(metaFuncArgToComponent).filter(notNull);

                        if (components.length > 0) {

                            // get defined or define new

                            var viewClsName = getViewName(components);
                            var view = definedViews.find(function(v) return v.cls.followName() == viewClsName);

                            if (view == null) {
                                var viewComplexType = getView(components);

                                fields.push(fvar([], [], viewClsName.toLowerCase(), viewComplexType, null, Context.currentPos()));

                                view = { name: viewClsName.toLowerCase(), cls: viewComplexType, components: viewDataCache.get(viewClsName).components };
                                definedViews.push(view);
                            }

                            var viewArgs = [ arg('id', macro:echos.Entity) ].concat(view.components.map(provideComponentToListenerArg.bind(_, func.args)));

                            return { name: funcName, args: callArgs, view: view, viewargs: viewArgs };

                        } else {

                            return { name: funcName, args: callArgs, view: null, viewargs: null };

                        }

                    default:
                }
            }

            return null;
        }


        var ufuncs = fields.map(procMetaFunc.bind(_, UPDATE_META)).filter(notNull);
        var afuncs = fields.map(procMetaFunc.bind(_, ADD_META)).filter(notNull);
        var rfuncs = fields.map(procMetaFunc.bind(_, REMOVE_META)).filter(notNull);

        var listeners = afuncs.concat(rfuncs);

        listeners.iter(function(f) {
            fields.push(fvar([], [], '__${f.name}', TFunction(f.viewargs.map(function(a) return a.type), macro:Void), null, Context.currentPos()));
        });

        var updateExprs = []
            .concat(
                ufuncs.map(function(f){
                    if (f.view == null) {
                        return macro $i{ f.name }($a{ f.args });
                    } else {
                        var fwrapper = { expr: EFunction(null, { args: f.viewargs, ret: macro:Void, expr: macro $i{ f.name }($a{ f.args }) }), pos: Context.currentPos()};
                        return macro $i{ f.view.name }.iter($fwrapper);
                    }
                })
            );

        var activateExprs = []
            .concat( // init signal wrappers
                listeners.map(function(f){
                    var fwrapper = { expr: EFunction(null, { args: f.viewargs, ret: macro:Void, expr: macro $i{ f.name }($a{ f.args }) }), pos: Context.currentPos()};
                    return macro $i{'__${f.name}'} = $fwrapper;
                })
            )
            .concat( // init views
                definedViews
                    .map(function(v){
                        var viewComplexType = v.cls;
                        return [
                            macro $i{ v.name } = ${ viewComplexType.expr(Context.currentPos()) }.inst(),
                            macro $i{ v.name }.activate()
                        ];
                    })
                    .flatten()
                    #if !haxe4 .array() #end
            )
            .concat( // add added-listeners
                afuncs.map(function(f){
                    return macro $i{ f.view.name }.onAdded.add($i{ '__${f.name}' });
                })
            )
            .concat( // add removed-listeners
                rfuncs.map(function(f){
                    return macro $i{ f.view.name }.onRemoved.add($i{ '__${f.name}' });
                })
            )
            .concat(
                [ macro onactivate() ]
            )
            .concat( // call added-listeners
                afuncs.map(function(f){
                    return macro $i{ f.view.name }.iter($i{ '__${f.name}' });
                })
            );

        var deactivateExprs = []
            .concat( // call removed-listeners
                rfuncs.map(function(f){
                    return macro $i{ f.view.name }.iter($i{ '__${f.name}' });
                })
            )
            .concat(
                [ macro ondeactivate() ]
            )
            .concat( // remove added-listeners
                afuncs.map(function(f){
                    return macro $i{ f.view.name }.onAdded.remove($i{ '__${f.name}' });
                })
            )
            .concat( // remove removed-listeners
                rfuncs.map(function(f){
                    return macro $i{ f.view.name }.onRemoved.remove($i{ '__${f.name}' });
                })
            )
            .concat( // null signal wrappers 
                listeners.map(function(f) {
                    return macro $i{'__${f.name}'} = null;
                })
            );


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