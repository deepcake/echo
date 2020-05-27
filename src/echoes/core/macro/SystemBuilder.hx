package echoes.core.macro;

import haxe.Log;
#if macro
import echoes.core.macro.MacroTools.*;
import echoes.core.macro.ViewBuilder.*;
import echoes.core.macro.ComponentBuilder.*;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Printer;
import haxe.macro.Type.ClassField;

using haxe.macro.ComplexTypeTools;
using haxe.macro.TypeTools;
using haxe.macro.Context;
using echoes.core.macro.MacroTools;
using StringTools;
using Lambda;

class SystemBuilder {


    static var SKIP_META = [ 'skip' ];

    static var PRINT_META = [ 'print' ];

    static var AD_META = [ 'added', 'ad', 'a' ];
    static var RM_META = [ 'removed', 'rm', 'r' ];
    static var UPD_META = [ 'update', 'up', 'u' ];

    public static var systemIndex = -1;
    public static var systemIds = new Map<String, Int>();


    static function notSkipped(field:Field) {
        return !containsMeta(field, SKIP_META);
    }

    static function containsMeta(field:Field, metas:Array<String>) {
        return field.meta
            .exists(function(me) {
                return metas.exists(function(name) return me.name == name);
            });
    }


    public static function build() {
        var fields = Context.getBuildFields();

        var ct = Context.getLocalType().toComplexType();

        var index = ++systemIndex;

        systemIds[ct.followName()] = index;

        // prevent wrong override
        for (field in fields) {
            switch (field.kind) {
                case FFun(func): 
                    switch (field.name) {
                        case '__update__':
                            Context.error('Do not override the `__update__` function! Use `@update` meta instead! More info at README example', field.pos);
                        case '__activate__':
                            Context.error('Do not override the `__activate__` function! `onactivate` can be overrided instead!', field.pos);
                        case '__deactivate__':
                            Context.error('Do not override the `__deactivate__` function! `ondeactivate` can be overrided instead!', field.pos);
                        default:
                    }
                default:
            }
        }


        function notNull<T>(e:Null<T>) return e != null;

        // @meta f(a:T1, b:T2, deltatime:Float) --> a, b, __dt__
        function metaFuncArgToCallArg(a:FunctionArg) {
            return switch (a.type.followComplexType()) {
                case macro:StdTypes.Float : macro __dt__;
                case macro:StdTypes.Int : macro __entity__;
                case macro:echoes.Entity : macro __entity__;
                default: macro $i{ a.name };
            }
        }

        function metaFuncArgIsEntity(a:FunctionArg) {
            return switch (a.type.followComplexType()) {
                case macro:StdTypes.Int, macro:echoes.Entity : true;
                default: false;
            }
        }

        function refComponentDefToFuncArg(c:{ cls:ComplexType }, args:Array<FunctionArg>) {
            var copmonentClsName = c.cls.followName();
            var a = args.find(function(a) return a.type.followName() == copmonentClsName);
            if (a != null) {
                return arg(a.name, a.type);
            } else {
                return arg(c.cls.typeFullName().toLowerCase(), c.cls);
            }
        }

        function metaFuncArgToComponentDef(a:FunctionArg) {
            return switch (a.type.followComplexType()) {
                case macro:StdTypes.Float : null;
                case macro:StdTypes.Int : null;
                case macro:echoes.Entity : null;
                default: { cls: a.type.followComplexType() };
            }
        }


        var definedViews = new Array<{ name:String, cls:ComplexType, components:Array<{ cls:ComplexType }> }>();

        // find and init manually defined views
        fields
            .filter(notSkipped)
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
                                if (viewCache.exists(clsName)) {
                                    // init
                                    field.kind = FVar(complexType, macro $i{clsName}.inst());

                                    definedViews.push({ name: field.name, cls: complexType, components: viewCache.get(clsName).components });
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
            .filter(notSkipped)
            .filter(containsMeta.bind(_, UPD_META.concat(AD_META).concat(RM_META)))
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

                                definedViews.push({ name: viewClsName.toLowerCase(), cls: viewComplexType, components: viewCache.get(viewClsName).components });
                            }

                        }
                    }
                    default:
                }
            } );


        function procMetaFunc(field:Field) {
            return switch (field.kind) {
                case FFun(func): {
                    var funcName = field.name;
                    var funcCallArgs = func.args.map(metaFuncArgToCallArg).filter(notNull);
                    var components = func.args.map(metaFuncArgToComponentDef).filter(notNull);

                    if (components.length > 0) {
                        // view iterate

                        var viewClsName = getViewName(components);
                        var view = definedViews.find(function(v) return v.cls.followName() == viewClsName);
                        var viewArgs = [ arg('__entity__', macro:echoes.Entity) ].concat(view.components.map(refComponentDefToFuncArg.bind(_, func.args)));

                        { name: funcName, args: funcCallArgs, view: view, viewargs: viewArgs, type: VIEW_ITER };

                    } else {

                        if (func.args.exists(metaFuncArgIsEntity)) {
                            // every entity iterate
                            Context.warning("Are you sure you want to iterate over all the entities? If not, you should add some components or remove the Entity / Int argument", field.pos);

                            { name: funcName, args: funcCallArgs, view: null, viewargs: null, type: ENTITY_ITER };

                        } else {
                            // single call
                            { name: funcName, args: funcCallArgs, view: null, viewargs: null, type: SINGLE_CALL };
                        }

                    }
                }
                default: null;
            }
        }


        // define new() if not exists (just for comfort)
        if (!fields.exists(function(f) return f.name == 'new')) {
            fields.push(ffun([APublic], 'new', null, null, null, Context.currentPos()));
        }


        var ufuncs = fields.filter(notSkipped).filter(containsMeta.bind(_, UPD_META)).map(procMetaFunc).filter(notNull);
        var afuncs = fields.filter(notSkipped).filter(containsMeta.bind(_, AD_META)).map(procMetaFunc).filter(notNull);
        var rfuncs = fields.filter(notSkipped).filter(containsMeta.bind(_, RM_META)).map(procMetaFunc).filter(notNull);

        var listeners = afuncs.concat(rfuncs);

        // define signal listener wrappers
        listeners.iter(function(f) {
            fields.push(fvar([], [], '__${f.name}_listener__', TFunction(f.viewargs.map(function(a) return a.type), macro:Void), null, Context.currentPos()));
        });

        var uexprs = []
            #if echoes_profiling
            .concat(
                [
                    macro var __timestamp__ = Date.now().getTime()
                ]
            )
            #end
            .concat(
                ufuncs.map(function(f) {
                    return switch (f.type) {
                        case SINGLE_CALL: {
                            macro $i{ f.name }($a{ f.args });
                        }
                        case VIEW_ITER: {
                            var fwrapper = { expr: EFunction(null, { args: f.viewargs, ret: macro:Void, expr: macro $i{ f.name }($a{ f.args }) }), pos: Context.currentPos()};
                            macro $i{ f.view.name }.iter($fwrapper);
                        }
                        case ENTITY_ITER: {
                            macro for (__entity__ in echoes.Workflow.entities) {
                                $i{ f.name }($a{ f.args });
                            }
                        }
                    }
                })
            )
            #if echoes_profiling
            .concat(
                [
                    macro this.__updateTime__ = Std.int(Date.now().getTime() - __timestamp__)
                ]
            )
            #end;

        var aexpr = macro if (!activated) $b{
            [].concat(
                [
                    macro activated = true
                ]
            )
            .concat(
                // init signal listener wrappers
                listeners.map(function(f) {
                    var fwrapper = { expr: EFunction(null, { args: f.viewargs, ret: macro:Void, expr: macro $i{ f.name }($a{ f.args }) }), pos: Context.currentPos()};
                    return macro $i{'__${f.name}_listener__'} = $fwrapper;
                })
            )
            .concat(
                // activate views
                definedViews.map(function(v) {
                    return macro $i{ v.name }.activate();
                })
            )
            .concat(
                // add added-listeners
                afuncs.map(function(f) {
                    return macro $i{ f.view.name }.onAdded.add($i{ '__${f.name}_listener__' });
                })
            )
            .concat(
                // add removed-listeners
                rfuncs.map(function(f) {
                    return macro $i{ f.view.name }.onRemoved.add($i{ '__${f.name}_listener__' });
                })
            )
            .concat(
                // call added-listeners
                afuncs.map(function(f) {
                    return macro $i{ f.view.name }.iter($i{ '__${f.name}_listener__' });
                })
            )
            .concat(
                [
                    macro onactivate()
                ]
            )
        };


        var dexpr = macro if (activated) $b{
            [].concat(
                [
                    macro activated = false,
                    macro ondeactivate()
                ]
            )
            .concat(
                // deactivate views
                definedViews.map(function(v) {
                    return macro $i{ v.name }.deactivate();
                })
            )
            .concat(
                // remove added-listeners
                afuncs.map(function(f) {
                    return macro $i{ f.view.name }.onAdded.remove($i{ '__${f.name}_listener__' });
                })
            )
            .concat(
                // remove removed-listeners
                rfuncs.map(function(f) {
                    return macro $i{ f.view.name }.onRemoved.remove($i{ '__${f.name}_listener__' });
                })
            )
            .concat(
                // null signal wrappers 
                listeners.map(function(f) {
                    return macro $i{'__${f.name}_listener__'} = null;
                })
            )
        };


        if (uexprs.length > 0) {

            fields.push(ffun([APublic, AOverride], '__update__', [arg('__dt__', macro:Float)], null, macro $b{ uexprs }, Context.currentPos()));

        }

        fields.push(ffun([APublic, AOverride], '__activate__', [], null, macro { $aexpr; }, Context.currentPos()));
        fields.push(ffun([APublic, AOverride], '__deactivate__', [], null, macro { $dexpr; }, Context.currentPos()));

        // toString
        fields.push(ffun([AOverride, APublic], 'toString', null, macro:String, macro return $v{ ct.followName() }, Context.currentPos()));


        var clsType = Context.getLocalClass().get();

        if (PRINT_META.exists(function(m) return clsType.meta.has(m))) {
            switch (ct) {
                case TPath(p): {
                    var td:TypeDefinition = {
                        pack: p.pack,
                        name: p.name,
                        pos: clsType.pos,
                        kind: TDClass(tpath("echoes", "System")),
                        fields: fields
                    }
                    trace(new Printer().printTypeDefinition(td));
                }
                default: {
                    Context.warning("Fail @print", clsType.pos);
                }
            }
        }

        return fields;
    }

}

@:enum abstract MetaFuncType(Int) {
    var SINGLE_CALL = 1;
    var VIEW_ITER = 2;
    var ENTITY_ITER = 3;
}

#end
