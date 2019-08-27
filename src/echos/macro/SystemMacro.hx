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
using echos.macro.MacroBuilder;
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

        // prevent wrong override
        for (field in fields) {
            switch (field.kind) {
                case FFun(func): 
                    switch (field.name) {
                        case '__update':
                            Context.error('Do not override the `__update` function! Use `@update` meta instead! More info at README example', field.pos);
                        case '__activate':
                            Context.error('Do not override the `__activate` function! `onactivate` can be overrided instead!', field.pos);
                        case '__deactivate':
                            Context.error('Do not override the `__deactivate` function! `ondeactivate` can be overrided instead!', field.pos);
                        default:
                    }
                default:
            }
        }


        function notNull<T>(e:Null<T>) return e != null;

        function metaFuncArgToCallArg(a:FunctionArg) {
            return switch (a.type.followComplexType()) {
                case macro:StdTypes.Float : macro dt;
                case macro:StdTypes.Int : macro id;
                case macro:echos.Entity : macro id;
                default: macro $i{ a.name };
            }
        }

        function refComponentDefToFuncArg(c:ComponentDef, args:Array<FunctionArg>) {
            var copmonentClsName = c.cls.followName();
            var a = args.find(function(a) return a.type.followName() == copmonentClsName);
            if (a != null) {
                return arg(a.name, a.type);
            } else {
                return arg(c.name, c.cls);
            }
        }

        function metaFuncArgToComponentDef(a:FunctionArg) {
            return switch (a.type.followComplexType()) {
                case macro:StdTypes.Float : null;
                case macro:StdTypes.Int : null;
                case macro:echos.Entity : null;
                default: { name: a.name, cls: a.type.followComplexType() };
            }
        }


        var definedViews = new Array<{ name:String, cls:ComplexType, components:Array<ComponentDef> }>();

        // find and init manually defined views
        fields
            .filter(function(field) {
                return !hasMeta(field, EXCLUDE_META);
            })
            .iter(function(field) {
                switch (field.kind) {
                    // defined var only
                    case FVar(cls, _) if (cls != null): {
                        var complexType = cls.followComplexType();
                        switch (complexType) {
                            // tpath only
                            case TPath(_): {
                                var clsName = complexType.followName();
                                // if it is a view, it was built (and collected to cache) when followComplexType() was called
                                if (viewDataCache.exists(clsName)) {
                                    // init
                                    field.kind = FVar(complexType, macro $i{clsName}.inst());

                                    definedViews.push({ name: field.name, cls: complexType, components: viewDataCache.get(clsName).components });
                                }
                            }
                            default:
                        }
                    }
                    default:
                }
            } );



        // find and init meta defined views
        fields
            .filter(function(field) {
                return field.hasMeta(UPDATE_META) || field.hasMeta(ADD_META) || field.hasMeta(REMOVE_META);
            })
            .filter(function(field) {
                return !hasMeta(field, EXCLUDE_META);
            })
            .iter(function(field) {
                switch (field.kind) {
                    case FFun(func): {

                        var components = func.args.map(metaFuncArgToComponentDef).filter(notNull);

                        if (components.length > 0) {

                            var viewClsName = getViewName(components);
                            var view = definedViews.find(function(v) return v.cls.followName() == viewClsName);

                            if (view == null) {
                                var viewComplexType = getView(components);

                                // instant define and init
                                fields.push(fvar([], [], viewClsName.toLowerCase(), viewComplexType, macro $i{viewClsName}.inst(), Context.currentPos()));

                                definedViews.push({ name: viewClsName.toLowerCase(), cls: viewComplexType, components: viewDataCache.get(viewClsName).components });
                            }

                        }
                    }
                    default:
                }
            } );


        function procMetaFunc(field:Field, meta:Array<String>) {
            if (!hasMeta(field, EXCLUDE_META) && hasMeta(field, meta)) {
                switch (field.kind) {
                    case FFun(func):
                        var funcName = field.name;
                        var callArgs = func.args.map(metaFuncArgToCallArg).filter(notNull);

                        var components = func.args.map(metaFuncArgToComponentDef).filter(notNull);

                        if (components.length > 0) {

                            var viewClsName = getViewName(components);
                            var view = definedViews.find(function(v) return v.cls.followName() == viewClsName);
                            var viewArgs = [ arg('id', macro:echos.Entity) ].concat(view.components.map(refComponentDefToFuncArg.bind(_, func.args)));

                            return { name: funcName, args: callArgs, view: view, viewargs: viewArgs };

                        } else {

                            return { name: funcName, args: callArgs, view: null, viewargs: null };

                        }
                    default:
                }
            }

            return null;
        }


        // define new() if not exists (just for comfort)
        if (!fields.exists(function(f) return f.name == 'new')) {
            fields.push(ffun([APublic], 'new', null, null, null, Context.currentPos()));
        }


        var ufuncs = fields.map(procMetaFunc.bind(_, UPDATE_META)).filter(notNull);
        var afuncs = fields.map(procMetaFunc.bind(_, ADD_META)).filter(notNull);
        var rfuncs = fields.map(procMetaFunc.bind(_, REMOVE_META)).filter(notNull);

        var listeners = afuncs.concat(rfuncs);

        // define signal listener wrappers
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
            .concat( // init signal listener wrappers
                listeners.map(function(f){
                    var fwrapper = { expr: EFunction(null, { args: f.viewargs, ret: macro:Void, expr: macro $i{ f.name }($a{ f.args }) }), pos: Context.currentPos()};
                    return macro $i{'__${f.name}'} = $fwrapper;
                })
            )
            .concat( // activate views
                definedViews.map(function(v){
                    return macro $i{ v.name }.activate();
                })
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

            fields.push(ffun([APublic, AOverride], '__update', [arg('dt', macro:Float)], null, macro $b{ updateExprs }, Context.currentPos()));

        }

        fields.push(ffun([APublic, AOverride], '__activate', [], null, macro $b{ activateExprs }, Context.currentPos()));
        fields.push(ffun([APublic, AOverride], '__deactivate', [], null, macro $b{ deactivateExprs }, Context.currentPos()));

        // toString
        fields.push(ffun([AOverride, APublic], 'toString', null, macro:String, macro return $v{ cls.followName() }, Context.currentPos()));

        traceFields(cls.followName(), fields);

        return fields;
    }

}
#end