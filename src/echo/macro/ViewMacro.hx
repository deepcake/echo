package echo.macro;

import echo.macro.Macro.*;
import echo.macro.MacroBuilder.*;
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

class ViewMacro {


    public static var viewIndex:Int = 0;
    public static var viewIdsMap:Map<String, Int> = new Map();
    public static var viewCache:Map<String, ComplexType> = new Map();
    public static var viewMasks:Map<Int, Map<Int, Bool>> = new Map();

    public static var viewIterCache:Map<String, ComplexType> = new Map();

    public static var viewDataCache:Map<String, ComplexType> = new Map();


    public static function build() {
        return createViewType(Context.getLocalType());
    }


    static function createViewType(type:haxe.macro.Type) {
        return switch(type) {
            case TInst(_, [x]):
                createViewType(x);

            case TType(_.get() => { type: x }, []):
                createViewType(x);

            case TAnonymous(_.get() => p):
                var components = p.fields.map(function(field:ClassField) return { name: field.name, cls: Context.toComplexType(field.type.follow()) });
                getView(components).toType();

            case x: throw 'Unexpected $x';
        }
    }


    public static function getView(components:Array<{ name:String, cls:ComplexType }>):ComplexType {
        gen();
        
        var viewClsName = getClsName('View', getClsNameSuffixByComponents(components));
        var viewCls = viewCache.get(viewClsName);
        if (viewCls == null) {

            viewIdsMap[viewClsName] = ++viewIndex;

            var def:TypeDefinition = macro class $viewClsName extends echo.View.ViewBase {
                public function new() {
                    __id = $v{ viewIndex };
                }
            }

            var iteratorTypePath = getViewIterator(components).tp();
            def.fields.push(ffun([APublic, AInline], 'iterator', null, null, macro return new $iteratorTypePath(this.echo, this.entities.iterator()), Context.currentPos()));

            // isMatch
            var testBody = Context.parse('return ' + components.map(function(c) return '${getComponentHolder(c.cls).followName()}.get(echo.__id)[id] != null').join(' && '), Context.currentPos());
            def.fields.push(ffun([meta(':noCompletion', Context.currentPos())], [APublic, AOverride], 'isMatch', [arg('id', macro:Int)], macro:Bool, testBody, Context.currentPos()));

            // isRequire
            def.fields.push(ffun([meta(':noCompletion', Context.currentPos())], [APublic, AOverride], 'isRequire', [arg('c', macro:Int)], macro:Bool, macro return __mask[c] != null, Context.currentPos()));

            // mask
            var maskBody = Context.parse('[' + components.map(function(c) return '${getComponentId(c.cls)} => true').join(', ') + ']', Context.currentPos());
            def.fields.push(fvar([meta(':noCompletion', Context.currentPos())], [AStatic], '__mask', null, maskBody, Context.currentPos()));

            // toString
            var stringBody = getClsNameSuffix(components.map(function(c) return c.cls), false);
            def.fields.push(ffun([AOverride, APublic], 'toString', null, macro:String, macro return $v{ stringBody }, Context.currentPos()));

            traceTypeDefenition(def);

            Context.defineType(def);

            viewMasks.set(viewIndex, new Map<Int, Bool>());
            components.iter(function(c) viewMasks[viewIndex].set(getComponentId(c.cls), true));

            viewCls = Context.getType(viewClsName).toComplexType();
            viewCache.set(viewClsName, viewCls);
        }
        return viewCls;
    }


    public static function getViewIterator(components:Array<{ name:String, cls:ComplexType }>):ComplexType {
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
            components.iter(function(c) nextExprs.push(Context.parse('this.vd.${c.name} = ${getComponentHolder(c.cls).followName()}.get(ch.__id)[this.vd.id]', Context.currentPos())));
            nextExprs.push(macro return this.vd);
            def.fields.push(ffun([APublic, AInline], 'next', null, viewDataCls, macro $b{nextExprs}, Context.currentPos()));

            traceTypeDefenition(def);

            Context.defineType(def);

            viewIterCls = Context.getType(viewIterClsName).toComplexType();
            viewIterCache.set(viewIterClsName, viewIterCls);
        }
        return viewIterCls;
    }


    public static function getViewData(components:Array<{ name:String, cls:ComplexType }>):ComplexType {
        var viewDataClsName = getClsName('ViewData', getClsNameSuffixByComponents(components));
        var viewDataCls = viewDataCache.get(viewDataClsName);
        if (viewDataCls == null) {

            var def:TypeDefinition = macro class $viewDataClsName {
                inline public function new() { }
                public var id:Int;
            }

            for (c in components) def.fields.push(fvar([APublic], c.name, c.cls, Context.currentPos()));

            traceTypeDefenition(def);

            Context.defineType(def);

            viewDataCls = Context.getType(viewDataClsName).toComplexType();
            viewDataCache.set(viewDataClsName, viewDataCls);
        }
        return viewDataCls;
    }

}