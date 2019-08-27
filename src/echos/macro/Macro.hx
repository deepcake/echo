package echos.macro;

#if macro
import haxe.macro.ComplexTypeTools;
import haxe.macro.Expr;
import haxe.macro.Expr.Access;
import haxe.macro.Expr.ComplexType;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.FunctionArg;
import haxe.macro.Expr.TypePath;
import haxe.macro.Expr.Position;
import haxe.macro.Printer;
using haxe.macro.Context;
using Lambda;

/**
 * ...
 * @author https://github.com/deepcake
 */
@:final
@:dce
class Macro {

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


    public static inline function traceFields(clsname:String, fields:Array<Field>) {
        #if echos_verbose
        var pr = new Printer();
        var ret = '$clsname\n';
        for (f in fields) ret += pr.printField(f) + '\n';
        trace(ret);
        #end
    }

    public static inline function traceTypeDefenition(def:TypeDefinition) {
        #if echos_verbose
        trace(new Printer().printTypeDefinition(def));
        #end
    }

    

    public static function followComplexType(cls:ComplexType) {
        return ComplexTypeTools.toType(cls).follow().toComplexType();
    }

    public static function followName(cls:ComplexType):String {
        var t = tp(followComplexType(cls));

        function paramFollowName(p:TypeParam):String {
            switch (p) {
                case TPType(cls):
                    return followName(cls);
                case x: throw 'Unexp $x';
            }
        }
        var params = '';
        if (t.params != null && t.params.length > 0) params = '<' + t.params.map(paramFollowName).join(', ') + '>';

        return (t.pack.length > 0 ? t.pack.join('.') + '.' : '') + t.name + (t.sub != null ? '.' + t.sub : '') + params;
    }

    public static function tp(t:ComplexType):TypePath {
        return switch(t) {
            case TPath(p): p;
            case x: throw 'Unexpected $x';
        }
    }

    public static function identName(e:Expr) {
        return switch(e.expr) {
            case EConst(CIdent(name)): name;
            case EField(path, name): identName(path) + '.' + name;
            case x: throw 'Unexpected $x';
        }
    }

}
#end
