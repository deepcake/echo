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
	static public var componentHoldersMap:Map<String, ComplexType> = new Map();

	static public var viewIndex:Int = 0;
	static public var viewIdsMap:Map<String, Int> = new Map();

	static var shortenMap:Map<String, String> = new Map();


	static function hasMeta(field:Field, metas:Array<String>) {
		for (m in field.meta) for (meta in metas) if (m.name == meta) return true;
		return false;
	}

	static function getMeta(field:Field, metas:Array<String>) {
		for (m in field.meta) for (meta in metas) if (m.name == meta) return m;
		return null;
	}


	static function safename(str:String) {
		return str.replace('.', '_').replace('<', '').replace('>', '');
	}

	static function getClsName(prefix:String, suffix:String) {
		var id = safename(prefix + '_' + suffix);
		#if !echo_shorten
			return id;
		#else
			if (!shortenMap.exists(id)) shortenMap.set(id, 'ECHO' + shortenMap.count());
			return shortenMap.get(id);
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
		return safename(suf.join('_'));
	}


	static public function getViewClsByTypes(types:Array<ComplexType>):ComplexType {
		var type = getClsName('View', getClsNameSuffix(types)).getType();
		return type != null ? type.toComplexType() : null;
	}


	static public function getViewGenericComplexType(components:Array<{ name:String, cls:ComplexType }>):ComplexType {
		var viewClsParams = components.map(function(c) return fvar([], [], c.name, c.cls.fullComplexType()));
		return TPath(tpath(['echo'], 'View', [TPType(TAnonymous(viewClsParams))]));
	}


	static public function autoBuildSystem() {
		var fields = Context.getBuildFields();
		var cls = Context.getLocalType().toComplexType();

		if (fields.filter(function(f) return f.name == 'new').length == 0) fields.push(ffun([APublic], 'new', null, null, null));

		var views = fields.map(function(field) {
			if (hasMeta(field, EXCLUDE_META)) return null; // skip by meta

			function getComponentsFromAnonTypeParam(t:TypePath) {
				switch (t.params) {
					case [ TPType(TAnonymous(fields)) ]:

						return fields.map(function(field) {
							switch (field.kind) {
								case FVar(cls, _): return { name: field.name, cls: cls.fullComplexType() };
								case x: throw 'Unexp $x';
							}
						});

					case x: throw 'Unexp $x';
				}
			}

			switch (field.kind) {
				case FVar(TPath(t), e) if (e == null):
					if (t.name.toLowerCase() == 'view') {
						return { name: field.name, components: getComponentsFromAnonTypeParam(t) };
					}

				case FVar(_, _.expr => ENew(t, _)):
					if (t.name.toLowerCase() == 'view') {
						field.kind = FVar(TPath(t), null); // remove new call, just define type
						return { name: field.name, components: getComponentsFromAnonTypeParam(t) };
					}

				default:
			}

			return null;
			
		} ).filter(function(el) return el != null);


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
					switch (a.type) {
						case macro:Int, macro:Float: 
							return null;
						default: 
							return { name: a.name, cls: a.type.fullComplexType() };
					}
				}).filter(function(el) return el != null);

				var viewClsName = getClsName('View', getClsNameSuffixByComponents(components));
				var view = views.find(function(v) return getClsName('View', getClsNameSuffixByComponents(v.components)) == viewClsName);
				var viewName = viewClsName.toLowerCase();

				if (view == null) {
					var viewCls = getViewGenericComplexType(components);
					fields.push(fvar(viewName, viewCls, null));
					views.push({ name: viewName, components: components });
				} else {
					// this view already defined in this system
					viewName = view.name;
				}

				var funcName = f.name;
				var funcArgs = func.args.map(function(a) {
					switch (a.type) {
						case macro:Float: 
							return macro dt;
						case macro:Int: 
							return macro i.id;
						default: 
							return Context.parse('i.${a.name}', Context.currentPos());
					}
				});

				updateExprs.push(macro for (i in $i{viewName}) $i{funcName}($a{funcArgs})); // TODO inline ?
			}
		});

		// define view
		views.iter(function(v) {
			var viewCls = getViewGenericComplexType(v.components);
			var viewType = viewCls.tp();
			var viewId = viewIdsMap[viewCls.fullname()];
			activateExprs.push(macro if (!echo.viewsMap.exists($v{ viewId })) echo.addView(new $viewType()));
			activateExprs.push(macro $i{ v.name } = cast echo.viewsMap[$v{ viewId }]);
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
				activateExprs.push(macro for (i in $i{viewname}.entities) $i{f.name}(i));
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

			case TInst(_.get() => cls, [TType(_.get() => { type:TAnonymous(_.get() => p) }, [])]):

				var components = p.fields.map(
					function(field:ClassField) return { name: field.name, cls: Context.toComplexType(field.type.follow()) }
				);
				return getView(components).toType();

			case x: throw 'Unexp $x';
		}
	}


	static public function getView(components:Array<{ name:String, cls:ComplexType }>):ComplexType {
		var clsname = getClsName('View', getClsNameSuffixByComponents(components));
		
		try {
			return Context.getType(clsname).toComplexType();
		}catch (er:Dynamic) {

			viewIndex++;
			viewIdsMap[clsname] = viewIndex;

			var def:TypeDefinition = macro class $clsname extends echo.View.ViewBase {
				public function new() { 
					__id = $v{viewIndex};
				}
			}

			var iteratorTypePath = getViewIterator(components).tp();
			def.fields.push(ffun([APublic, AInline], 'iterator', null, null, macro return new $iteratorTypePath(this.entities)));

			var testBody = Context.parse('return ' + components.map(function(c) return '${getComponentHolder(c.cls).fullname()}.__MAP.exists(id)').join(' && '), Context.currentPos());
			def.fields.push(ffun([meta(':noCompletion')], [APublic, AOverride], 'test', [arg('id', macro:Int)], macro:Bool, testBody));

			// testcomponent
			def.fields.push(ffun([meta(':noCompletion')], [APublic, AOverride], 'testcomponent', [arg('c', macro:Int)], macro:Bool, macro return __MASK.exists(c)));

			var maskBody = Context.parse('[' + components.map(function(c) return '${getComponentHolder(c.cls).fullname()}.__ID => true').join(', ') + ']', Context.currentPos());
			def.fields.push(fvar([meta(':noCompletion')], [AStatic], '__MASK', null, maskBody));

			traceTypeDefenition(def);

			Context.defineType(def);
			return Context.getType(clsname).toComplexType();
		}
	}


	static public function getViewIterator(components:Array<{ name:String, cls:ComplexType }>):ComplexType {
		var viewdataCls = getViewData(components);
		var iteratorClsName = getClsName('ViewIterator', viewdataCls.fullname());
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
			components.iter(function(c) nextExprs.push(Context.parse('this.vd.${c.name} = ${getComponentHolder(c.cls).fullname()}.__MAP.get(this.vd.id)', Context.currentPos())));
			nextExprs.push(macro return this.vd);
			def.fields.push(ffun([APublic, AInline], 'next', null, viewdataCls, macro $b{nextExprs}));

			traceTypeDefenition(def);

			Context.defineType(def);
			return Context.getType(iteratorClsName).toComplexType();
		}
	}


	static public function getViewData(components:Array<{ name:String, cls:ComplexType }>):ComplexType {
		var viewdataClsName = getClsName('ViewData', getClsNameSuffixByComponents(components));
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


	static public function getComponentHolder(componentCls:ComplexType):ComplexType {
		var componentHolderClsName = getClsName('ComponentHolder', componentCls.fullname());
		try {
			return Context.getType(componentHolderClsName).toComplexType();
		}catch (er:Dynamic) {

			var def = macro class $componentHolderClsName {
				static public var __ID:Int = $v{componentIndex++};
				static public var __MAP:Map<Int, $componentCls> = new Map();
			}

			traceTypeDefenition(def);

			Context.defineType(def);

			componentHoldersMap[componentCls.fullname()] = Context.getType(componentHolderClsName).toComplexType();

			return componentHoldersMap[componentCls.fullname()];
		}
	}

}
#end
