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
import haxe.macro.Type;

using haxe.macro.ComplexTypeTools;
using haxe.macro.Context;
using Lambda;

/**
 * ...
 * @author https://github.com/deepcake
 */
@:final
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


    public static inline function traceFields(clsname:String, fields:Array<Field>) {
        #if echoes_verbose
        var pr = new Printer();
        var ret = '$clsname\n';
        for (f in fields) ret += pr.printField(f) + '\n';
        trace(ret);
        #end
    }

    public static inline function traceTypeDefenition(def:TypeDefinition) {
        #if echoes_verbose
        trace(new Printer().printTypeDefinition(def));
        #end
    }


	public static function typeof(e:Expr) {
		return switch(e.expr) {
			case ENew(t, _):
				TPath(t).toType();
			default:
				Context.typeof(e);
		}
	}

    public static function followMono(t:Type) {
        return switch(t) {
            case TMono(_.get() => tt):
                followMono(tt);
            case TAbstract(_.get() => {name:"Null"}, [tt]):
                followMono(tt);
            default:
                t;
        }
    }

    public static function followComplexType(ct:ComplexType) {
        return followMono(ct.toType()).toComplexType();
    }

    public static function followName(ct:ComplexType):String {
        return new Printer().printComplexType(followComplexType(ct));
    }


    public static function parseComplexType(e:Expr) {
        switch(e.expr) {
            case EParenthesis({expr:ECheckType(_, ct)}):
                return followComplexType(ct);
            default:
        }

        var type = new Printer().printExpr(e);

        try {

            return followMono(type.getType()).toComplexType();

        } catch (err:String) {
            throw 'Failed to parse `$type`. Try making a typedef, or use the special type check syntax: `entity.get((_:MyType))` instead of `entity.get(MyType)`.';
        }
    }


    static function capitalize(s:String) {
        return s.substr(0, 1).toUpperCase() + (s.length > 1 ? s.substr(1).toLowerCase() : '');
    }

    static function typeParamName(p:TypeParam):String {
        return switch (p) {
            case TPType(ct): typeName(ct);
            case x: 
                #if (haxe_ver < 4) 
                throw 'Unexpected $x!';
                #else
                Context.error('Unexpected $x!', Context.currentPos());
                #end 
        }
    }

    public static function typeName(ct:ComplexType):String {
        return switch (followComplexType(ct)) {
            case TPath(t): 

                (t.pack.length > 0 ? t.pack.map(capitalize).join('') : '') + 
                t.name + 
                (t.sub != null ? t.sub : '') + 
                ((t.params != null && t.params.length > 0) ? t.params.map(typeParamName).join('') : '');

            case x: 
                #if (haxe_ver < 4) 
                throw 'Unexpected $x!';
                #else
                Context.error('Unexpected $x!', Context.currentPos());
                #end 
        }
    }

    public static function compareStrings(a:String, b:String):Int {
        a = a.toLowerCase();
        b = b.toLowerCase();
        if (a < b) return -1;
        if (a > b) return 1;
        return 0;
    }

    public static function packName(types:Array<ComplexType>) {
        var typeNames = types.map(typeName);
        typeNames.sort(compareStrings);
        return typeNames.join('_');
    }

}
#end
