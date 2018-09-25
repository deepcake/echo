package echo.macro;

#if macro
import echo.macro.Macro.*;
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

/**
 * ...
 * @author https://github.com/deepcake
 */
@:noCompletion
@:final
@:dce
class MacroBuilder {


    public static var reportRegistered = false;
    public static var metaRegistered = false;
    public static var contextReusedRegistered = false;


    public static function hasMeta(field:Field, metas:Array<String>) {
        for (m in field.meta) for (meta in metas) if (m.name == meta) return true;
        return false;
    }

    public static function getMeta(field:Field, metas:Array<String>) {
        for (m in field.meta) for (meta in metas) if (m.name == meta) return m;
        return null;
    }

    public static function gen() {
        /*Context.onMacroContextReused(function() {
            #if echo_verbose 
            trace('macro context reused');
            #end

            reportRegistered = false;
            metaRegistered = false;
            return true;
        });*/

        #if echo_report
        if (!reportRegistered) {
            Context.onGenerate(function(types) {
                function sortedlist(array:Array<String>) {
                    array.sort(compareStrings);
                    return array;
                }

                var ret = 'ECHO BUILD REPORT :';
                
                ret += '\n    COMPONENTS [${componentContainerNames.length}] :';
                ret += '\n        ' + sortedlist(componentContainerNames.mapi(function(i, k) return '$k [${ componentIds.get(k) }]').array()).join('\n        ');
                ret += '\n    VIEWS [${viewCache.count()}] :';
                ret += '\n        ' + sortedlist({ iterator: function() return viewCache.keys() }.mapi(function(i, k) return '$k [${ viewIdsMap.get(k) }]').array()).join('\n        ');
                trace('\n$ret');

            });
            reportRegistered = true;
        }
        #end
    }


    public static function safename(str:String) {
        return str.replace('.', '_').replace('<', '').replace('>', '').replace(',', '');
    }

    public static function compareStrings(a:String, b:String):Int {
        a = a.toLowerCase();
        b = b.toLowerCase();
        if (a < b) return -1;
        if (a > b) return 1;
        return 0;
    }

    public static function getClsName(prefix:String, suffix:String) {
        var id = safename(prefix + '_' + suffix);
        return id;
    }

    public static function getClsNameSuffixByComponents(components:Array<{ name:String, cls:ComplexType }>) {
        return getClsNameSuffix(components.map(function(c) return c.cls));
    }

    public static function getClsNameSuffix(types:Array<ComplexType>, safe:Bool = true):String {
        var suf = types.map(function(type) return type.followName());
        suf.sort(compareStrings);
        return safe ? safename(suf.join('_')) : suf.join(',');
    }


    public static function getViewClsByTypes(types:Array<ComplexType>):ComplexType {
        var type = getClsName('View', getClsNameSuffix(types)).getType();
        return type != null ? type.toComplexType() : null;
    }


    public static function getViewGenericComplexType(components:Array<{ name:String, cls:ComplexType }>):ComplexType {
        var viewClsParams = components.map(function(c) return fvar([], [], c.name, c.cls.followComplexType(), Context.currentPos()));
        return TPath(tpath(['echo'], 'View', [TPType(TAnonymous(viewClsParams))]));
    }


}
#end
