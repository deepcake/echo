package echo.macro;

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
@:noCompletion
@:final
@:dce
class Macro {

	static public function ffun(?meta:Metadata, ?access:Array<Access>, name:String, ?args:Array<FunctionArg>, ?ret:ComplexType, ?body:Expr, pos:Position):Field {
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

	static public function fvar(?meta:Metadata, ?access:Array<Access>, name:String, ?type:ComplexType, ?expr:Expr, pos:Position):Field {
		return {
			meta: meta != null ? meta : [],
			name: name,
			access: access != null ? access : [],
			kind: FVar(type, expr),
			pos: pos
		};
	}


	static public function arg(name:String, type:ComplexType):FunctionArg {
		return {
			name: name,
			type: type
		};
	}

	static public function meta(name:String, ?params:Array<Expr>, pos:Position):MetadataEntry {
		return {
			name: name,
			params: params != null ? params : [],
			pos: pos
		}
	}

	static public function tpath(?pack:Array<String>, name:String, ?params:Array<TypeParam>, ?sub:String):TypePath {
		return {
			pack: pack != null ? pack : [],
			name: name,
			params: params != null ? params : [],
			sub: sub
		}
	}


	static public inline function traceFields(clsname:String, fields:Array<Field>) {
		#if echo_verbose
			var pr = new Printer();
			var ret = '$clsname\n';
			for (f in fields) ret += pr.printField(f) + '\n';
			trace(ret);
		#end
	}

	static public inline function traceTypeDefenition(def:TypeDefinition) {
		#if echo_verbose
			trace(new Printer().printTypeDefinition(def));
		#end
	}

	static public function followComplexType(cls:ComplexType) {
		return ComplexTypeTools.toType(cls).follow().toComplexType();
	}

	static public function followName(cls:ComplexType):String {
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

	static public function tp(t:ComplexType):TypePath {
		return switch(t) {
			case TPath(p): p;
			case x: throw 'Unexpected $x';
		}
	}

	static public function expr(cls:ComplexType, pos:Position):Expr {
		return Context.parse(followName(cls), pos);
	}

	static public function identName(e:Expr) {
		return switch(e.expr) {
			case EConst(CIdent(name)): name;
			case EField(path, name): identName(path) + '.' + name;
			case x: throw 'Unexpected $x';
		}
	}

}
