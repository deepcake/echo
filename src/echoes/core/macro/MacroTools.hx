package echoes.core.macro;

#if macro
import haxe.macro.Expr;
import haxe.macro.Expr.Access;
import haxe.macro.Expr.ComplexType;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.FunctionArg;
import haxe.macro.Expr.TypePath;
import haxe.macro.Expr.Position;
import haxe.macro.Printer;

using haxe.macro.ComplexTypeTools;
using haxe.macro.Context;
using Lambda;

/**
 * ...
 * @author https://github.com/deepcake
 */
@:dce
class MacroTools {

    public static function ffun(?meta:Metadata, ?access:Array<Access>, name:String, ?args:Array<FunctionArg>, ?ret:ComplexType, ?body:Expr, pos:Position):Field {
        return {
            meta: meta != null ? meta : [],
            name: name,
            access: access != null ? access : [],
            kind: FFun({
                args: args != null ? args : [],
                expr: body != null ? body : macro { },
                ret: ret
            }),
            pos: pos
        };
    }

    public static function fvar(?meta:Metadata, ?access:Array<Access>, name:String, ?type:ComplexType, ?expr:Expr, pos:Position):Field {
        return {
            meta: meta != null ? meta : [],
            name: name,
            access: access != null ? access : [],
            kind: FVar(type, expr),
            pos: pos
        };
    }


    public static function arg(name:String, type:ComplexType):FunctionArg {
        return {
            name: name,
            type: type
        };
    }

    public static function meta(name:String, ?params:Array<Expr>, pos:Position):MetadataEntry {
        return {
            name: name,
            params: params != null ? params : [],
            pos: pos
        }
    }

    public static function tpath(?pack:Array<String>, name:String, ?params:Array<TypeParam>, ?sub:String):TypePath {
        return {
            pack: pack != null ? pack : [],
            name: name,
            params: params != null ? params : [],
            sub: sub
        }
    }


    public static function followComplexType(ct:ComplexType) {
        return ComplexTypeTools.toType(ct).follow().toComplexType();
    }

    public static function followName(ct:ComplexType):String {
        return new Printer().printComplexType(followComplexType(ct));
    }


    public static function parseComplexType(e:Expr):ComplexType {
        var type = new Printer().printExpr(e);

        try {

            return type.getType().follow().toComplexType();

        } catch (err:String) {
            error('Fail to parse `$type` as allowed Type. You can try to use Typedef, this will probably help.', e.pos);
            return null;
        }
    }


    static function error(msg:String, pos:Position) {
        #if (haxe_ver < 4) 
        throw msg;
        #else
        Context.error(msg, pos);
        #end
    }


    static function capitalize(s:String) {
        return s.substr(0, 1).toUpperCase() + (s.length > 1 ? s.substr(1).toLowerCase() : '');
    }

    static function typeParamName(p:TypeParam, f:ComplexType->String):String {
        return switch (p) {
            case TPType(ct): {
                f(ct);
            }
            case x: {
                error('Unexpected $x!', Context.currentPos());
                null;
            }
        }
    }

    public static function typeValidShortName(ct:ComplexType):String {
        return typeName(ct, true, false);
    }

    public static function typeName(ct:ComplexType, shortify = false, escape = true):String {
        return switch (followComplexType(ct)) {
            case TFunction(args, ret): {

                args.map(typeName.bind(_, shortify, escape)).join(escape ? '' : '->') + (escape ? '' : '->') + typeName(ret, shortify, escape);

            }
            case TParent(t): {

                (escape ? '' : '(') + typeName(t, shortify, escape) + (escape ? '' : ')');

            }
            case TPath(t): {
                var ret = '';

                // package
                ret += shortify ? '' : (t.pack.length > 0 ? t.pack.map(capitalize).join('') : '');
                // class name
                ret += shortify ? (t.sub != null ? t.sub : t.name) : (t.name + (t.sub != null ? t.sub : ''));

                // type params
                if (t.params != null && t.params.length > 0) {

                    var tpName = typeParamName.bind(_, typeName.bind(_, shortify, escape));
                    ret += (escape ? '' : '<') + t.params.map(tpName).join(escape ? '' : ',') + (escape ? '' : '>');

                }

                ret;
            }
            case x: {
                error('Unexpected $x!', Context.currentPos());
                null;
            }
        }
    }

    public static function compareStrings(a:String, b:String):Int {
        a = a.toLowerCase();
        b = b.toLowerCase();
        return (a < b) ? -1 : (a > b) ? 1 : 0;
    }

    public static function joinFullName(types:Array<ComplexType>, sep:String) {
        var typeNames = types.map(typeName.bind(_, false, true));
        typeNames.sort(compareStrings);
        return typeNames.join(sep);
    }

}
#end
