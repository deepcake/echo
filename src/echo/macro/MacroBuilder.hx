package echo.macro;
#if macro
import echo.macro.Macro.*;
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
 * @author https://github.com/wimcake
 */
@:noCompletion
@:final
@:dce
class MacroBuilder {


	static var EXCLUDE_META = ['skip', 'ignore', 'i'];
	static var ONADD_META = ['onadd', 'add', 'a'];
	static var ONREMOVE_META = ['onremove', 'onrem', 'rem', 'r'];
	static var ONEACH_META = ['oneach', 'each', 'e'];


	static public var componentIndex:Int = 0;
	static public var componentHoldersMap:Map<String, String> = new Map();

	static public var viewIndex:Int = 0;

	static var shortenMap:Map<String, String> = new Map();


	static function hasMeta(field:Field, metas:Array<String>) {
		for (m in field.meta) for (meta in metas) if (m.name == meta) return true;
		return false;
	}

	static function getMeta(field:Field, metas:Array<String>) {
		for (m in field.meta) for (meta in metas) if (m.name == meta) return m;
		return null;
	}

	static function getClsNameID(prefix:String, suffix:String) {
		#if !echo_shorten
			return (prefix + '_' + suffix).replace('.', '_');
		#else
			var id = (prefix + '_' + suffix).replace('.', '_');
			var hash = haxe.crypto.Md5.encode(id).toUpperCase();
			if (!shortenMap.exists(hash)) shortenMap.set(hash, 'ECHO' + shortenMap.count());
			return shortenMap.get(hash);
		#end
	}

	static function getClsNameSuffixByComponents(components:Array<{ name:String, cls:ComplexType }>) {
		return getClsNameSuffix(components.map(function(c) return c.cls));
	}

	static function getClsNameSuffix(types:Array<ComplexType>):String {
		var suf = types.map(function(type) return type.fullname());
		suf.sort(function(a, b) {
			a = a.toLowerCase();
			b = b.toLowerCase();
			if (a < b) return -1;
			if (a > b) return 1;
			return 0;
		});
		return suf.join('_').replace('.', '_');
	}

	static public function getViewClsByTypes(types:Array<ComplexType>):ComplexType {
		return getClsNameID('View', getClsNameSuffix(types)).getType().toComplexType();
	}


	static public function getComponentHolder(componentClsName:String):String {
		var componentCls = Context.getType(componentClsName).toComplexType();

		var componentHolderClsName = getClsNameID('ComponentHolder', componentCls.fullname());
		componentHoldersMap.set(componentCls.fullname(), componentHolderClsName);

		try {
			return Context.getType(componentHolderClsName).toComplexType().fullname();
		}catch (er:Dynamic) {

			var def = macro class $componentHolderClsName {
				static public var __ID:Int = $v{componentIndex++};
				static public var __MAP:Map<Int, $componentCls> = new Map();
			}

			traceTypeDefenition(def);

			Context.defineType(def);
			return Context.getType(componentHolderClsName).toComplexType().fullname();
		}
	}


	static public function autoBuildSystem() {
		var fields = Context.getBuildFields();
		var cls = Context.getLocalType().toComplexType();

		if (fields.filter(function(f) return f.name == 'new').length == 0) fields.push(ffun([APublic], 'new', null, null, null));

		var activateExprs = [];
		var deactivateExprs = [];
		var updateExprs = [];

		fields.iter(function(f) {
			if (hasMeta(f, ONEACH_META)) { // TODO params ? (view name)
				var func = switch (f.kind) {
					case FFun(x): x;
					case x: throw "Unexp $x";
				}
				var components = func.args.map(function(a) {
					return { name: a.name, cls: a.type };
				});

				var params = components.map(function(c) return '${c.name}:${c.cls.fullname()}').join(', ');
				var viewBody = Context.parse('new echo.View<{$params}>()', Context.currentPos());
				var viewName = getClsNameSuffixByComponents(components).toLowerCase();

				fields.push(fvar([], null, viewName, viewBody));

				var funcName = f.name;
				var funcParams = components.map(function(c) {
					return Context.parse('i.${c.name}', Context.currentPos());
				});

				updateExprs.push(macro for (i in $i{viewName}) $i{funcName}($a{funcParams})); // TODO inline ?
			}
		});

		var views = fields.map(function(field) {
			if (field.access != null) if (field.access.indexOf(AStatic) > -1) return null; // only non-static
			if (hasMeta(field, EXCLUDE_META)) return null; // skip by meta

			function getComponentsFromAnonTypeParam(t:TypePath) {
				switch (t.params) {
					case [ TPType(TAnonymous(fields)) ]:

						return fields.map(function(field) {
							switch (field.kind) {
								case FVar(cls, _): return { name: field.name, cls: cls };
								case x: throw 'Unexp $x';
							}
						});

					case x: throw 'Unexp $x';
				}
			}

			switch (field.kind) {
				case FVar(_, _.expr => ENew(t, _)):
					if (t.name.toLowerCase() == 'view') {
						field.kind = FVar(TPath(t), null); // remove new call, just define type
						return { name: field.name, components: getComponentsFromAnonTypeParam(t) };
					}

				case FVar(TPath(t), _):
					if (t.name.toLowerCase() == 'view') {
						return { name: field.name, components: getComponentsFromAnonTypeParam(t) };
					}
					
				default:
			}

			return null;
			
		} ).filter(function(el) return el != null);


		// create, remove view
		views.iter(function(v) {
			var viewname = v.name;
			var params = v.components.map(function(c) return '${c.name}:${c.cls.fullname()}').join(', ');
			activateExprs.push(Context.parse('$viewname = cast echo.createView({$params})', Context.currentPos()));
			deactivateExprs.push(Context.parse('echo.removeView($viewname)', Context.currentPos()));
		} );

		// onadd, onremove signals
		fields.iter(function(f) {
			var onaddMeta = getMeta(f, ONADD_META);
			if (onaddMeta != null) {
				var viewname = switch (onaddMeta.params) {
					case [ _.expr => EConst(CString(x)) ]: x;
					case [ _.expr => EConst(CInt(x)) ]: views[Std.parseInt(x)].name;
					case []: views[0].name;
					case x: throw 'Unexp $x';
				}
				activateExprs.push(macro $i{viewname}.onAdd.add($i{f.name}));
				deactivateExprs.push(macro $i{viewname}.onAdd.remove($i{f.name}));
			}
			var onremMeta = getMeta(f, ONREMOVE_META);
			if (onremMeta != null) {
				var viewname = switch (onremMeta.params) {
					case [ _.expr => EConst(CString(x)) ]: x;
					case [ _.expr => EConst(CInt(x)) ]: views[Std.parseInt(x)].name;
					case []: views[0].name;
					case x: throw 'Unexp $x';
				}
				activateExprs.push(macro $i{viewname}.onRemove.add($i{f.name}));
				deactivateExprs.push(macro $i{viewname}.onRemove.remove($i{f.name}));
			}
		} );

		// add view (onadd, onremove singnals executes at this moment)
		views.iter(function(v) activateExprs.push(macro echo.addView($i{v.name})));

		// onactivate,  ondeactivate
		activateExprs.push(macro super.activate(echo)); // after view added
		deactivateExprs.unshift(macro super.deactivate()); // before view removed

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
				fields.push(ffun([APublic, AOverride], 'update', [arg('dt', macro:Float)], null, macro $b{updateExprs}));
			}
		}

		fields.push(ffun([APublic, AOverride], 'activate', [arg('echo', macro:echo.Echo)], null, macro $b{activateExprs}));
		fields.push(ffun([APublic, AOverride], 'deactivate', null, null, macro $b{deactivateExprs}));

		traceFields(cls.fullname(), fields);

		return fields;
	}


	static public function genericBuildView() {
		switch (Context.getLocalType()) {
			case TInst(_.get() => cls, [TAnonymous(_.get() => p)]):

				var components = p.fields.map(
					function(field:ClassField) return { name: field.name, cls: Context.toComplexType(field.type.follow()) }
				);

				return getView(components).toType();

			case x: throw 'Expected: TInst(_.get() => cls, [TAnonymous(_.get() => p)]); Actual: $x';
		}
	}


	static public function getView(components:Array<{ name:String, cls:ComplexType }>):ComplexType {
		var clsname = getClsNameID('View', getClsNameSuffixByComponents(components));
		try {
			return Context.getType(clsname).toComplexType();
		}catch (er:Dynamic) {

			var def:TypeDefinition = macro class $clsname extends echo.View.ViewBase {
				public function new() {}
			}

			var iteratorTypePath = getViewIterator(components).tp();
			def.fields.push(ffun([APublic, AInline], 'iterator', null, null, macro return new $iteratorTypePath(this.entities)));

			var testBody = Context.parse('return ' + components.map(function(c) return '${getComponentHolder(c.cls.fullname())}.__MAP.exists(id)').join(' && '), Context.currentPos());
			def.fields.push(ffun([meta(':noCompletion')], [APublic, AOverride], 'test', [arg('id', macro:Int)], macro:Bool, testBody));

			// testcomponent
			def.fields.push(ffun([meta(':noCompletion')], [APublic, AOverride], 'testcomponent', [arg('c', macro:Int)], macro:Bool, macro return __MASK.exists(c)));

			var maskBody = Context.parse('[' + components.map(function(c) return '${getComponentHolder(c.cls.fullname())}.__ID => true').join(', ') + ']', Context.currentPos());
			def.fields.push(fvar([meta(':noCompletion')], [AStatic], '__MASK', null, maskBody));

			def.fields.push(fvar([], [AStatic, APublic], '__ID', null, macro $v{viewIndex++}));

			traceTypeDefenition(def);

			Context.defineType(def);
			return Context.getType(clsname).toComplexType();
		}
	}


	static public function getViewData(components:Array<{ name:String, cls:ComplexType }>):ComplexType {
		var viewdataClsName = getClsNameID('ViewData', getClsNameSuffixByComponents(components));
		try {
			return Context.getType(viewdataClsName).toComplexType();
		}catch (er:Dynamic) {

			var def:TypeDefinition = macro class $viewdataClsName {
				inline public function new() { }
				public var id:Int;
			}

			for (c in components) def.fields.push(fvar([APublic], c.name, c.cls));

			traceTypeDefenition(def);

			Context.defineType(def);
			return Context.getType(viewdataClsName).toComplexType();
		}
	}


	static public function getViewIterator(components:Array<{ name:String, cls:ComplexType }>):ComplexType {
		var viewdataCls = getViewData(components);
		var iteratorClsName = getClsNameID('ViewIterator', viewdataCls.fullname());
		try {
			return Context.getType(iteratorClsName).toComplexType();
		}catch (er:Dynamic) {

			var viewdataTypePath = viewdataCls.tp();

			var def = macro class $iteratorClsName {
				var i:Int;
				var list:Array<Int>;
				var vd:$viewdataCls;
				public inline function new(list:Array<Int>) {
					this.i = -1;
					this.list = list;
					this.vd = new $viewdataTypePath(); // TODO opt js ( Object ? )
				}
				public inline function hasNext():Bool return ++i < list.length;
				//public inline function next():$dataViewCls return vd;
			}

			var nextExprs = [];
			nextExprs.push(macro this.vd.id = this.list[i]);
			components.iter(function(c) nextExprs.push(Context.parse('this.vd.${c.name} = ${getComponentHolder(c.cls.fullname())}.__MAP.get(this.vd.id)', Context.currentPos())));
			nextExprs.push(macro return this.vd);
			def.fields.push(ffun([APublic, AInline], 'next', null, viewdataCls, macro $b{nextExprs}));

			traceTypeDefenition(def);

			Context.defineType(def);
			return Context.getType(iteratorClsName).toComplexType();
		}
	}

}
#end
