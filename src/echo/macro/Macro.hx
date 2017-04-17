package echo.macro;
#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Expr.Access;
import haxe.macro.Expr.ComplexType;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.FunctionArg;
import haxe.macro.Expr.TypePath;
import haxe.macro.Printer;

/**
 * ...
 * @author octocake1
 */
@:noCompletion
@:final
@:dce
class Macro {
	
	
	static public function ffun(?meta:Metadata, ?access:Array<Access>, name:String, ?args:Array<FunctionArg>, ?ret:ComplexType, ?body:Expr):Field {
		return {
			meta: meta != null ? meta : [],
			name: name,
			access: access != null ? access : [],
			kind: FFun({
				args: args != null ? args : [],
				expr: body != null ? body : macro { },
				ret: ret
			}),
			pos: Context.currentPos()
		};
	}
	
	static public function fvar(?meta:Metadata, ?access:Array<Access>, name:String, ?type:ComplexType, ?expr:Expr):Field {
		return {
			meta: meta != null ? meta : [],
			name: name,
			access: access != null ? access : [],
			kind: FVar(type, expr),
			pos: Context.currentPos()
		};
	}
	
	
	static public function arg(name:String, type:ComplexType):FunctionArg {
		return {
			name: name,
			type: type
		};
	}
	
	static public function meta(name:String):MetadataEntry {
		return {
			name: name,
			pos: Context.currentPos()
		}
	}
	
	
	static public inline function traceFields(clsname:String, fields:Array<Field>) {
		#if debug
			var pr = new Printer();
			var ret = '$clsname\n';
			for (f in fields) ret += pr.printField(f) + '\n';
			trace(ret);
		#end
	}
	
	static public inline function traceExprs(name:String, exprs:Array<Expr>) {
		#if debug
			trace('$name:\n' + new Printer().printExprs(exprs, '\n'));
		#end
	}
	
	static public inline function traceTypeDefenition(def:TypeDefinition) {
		#if debug
			trace(new Printer().printTypeDefinition(def));
		#end
	}
	
	
	static public function fullname(ct:ComplexType):String {
		var t = tp(ct);
		return (t.pack.length > 0 ? t.pack.join('.') + '.' : '') + t.name + (t.sub != null ? '.' + t.sub : '');
	}
	
	static public function shortname(ct:ComplexType):String {
		var t = tp(ct);
		return t.sub != null ? t.sub : t.name;
	}
	
	static public function tp(t:ComplexType):TypePath {
		return switch(t) {
			case TPath(p): p;
			case x: throw 'Unexpected $x';
		}
	}
	
	static public function identName(e:Expr) {
		return switch(e.expr) {
			case EConst(CIdent(name)): name;
			case x: throw 'Unexpected $x';
		}
	}
	
}
#end