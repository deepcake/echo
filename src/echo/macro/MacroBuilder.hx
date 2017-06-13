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
	static var ONADD_META = ['onadded', 'added', 'onadd', 'add', 'a'];
	static var ONREMOVE_META = ['onremoved', 'removed', 'onremove', 'onrem', 'remove', 'rem', 'r'];
	static var ONEACH_META = ['update', 'upd', 'u'];


	static public var componentIndex:Int = 0;
	static public var componentCache:Map<String, ComplexType> = new Map();

	static public var viewIndex:Int = 0;
	static public var viewIdsMap:Map<String, Int> = new Map();
	static public var viewCache:Map<String, ComplexType> = new Map();

	static public var viewIterCache:Map<String, ComplexType> = new Map();

	static public var viewDataCache:Map<String, ComplexType> = new Map();

	static public var systemIndex:Int = 0;
	static public var systemIdsMap:Map<String, Int> = new Map();


	static var reportRegistered = false;

	static var shortenMap:Map<String, String> = new Map();


	static function hasMeta(field:Field, metas:Array<String>) {
		for (m in field.meta) for (meta in metas) if (m.name == meta) return true;
		return false;
	}

	static function getMeta(field:Field, metas:Array<String>) {
		for (m in field.meta) for (meta in metas) if (m.name == meta) return m;
		return null;
	}

	static function report() {
		#if echo_verbose
			if (!reportRegistered) {
				Context.onGenerate(function(types) {
					function sortedlist(array:Array<String>) {
						array.sort(compareStrings);
						return array;
					}

					var ret = 'ECHO BUILD REPORT :';
					ret += '\n    COMPONENTS [${componentCache.count()}] :';
					ret += '\n        ' + sortedlist({ iterator: function() return componentCache.keys() }.mapi(function(i, k) return '$k').array()).join('\n        ');
					ret += '\n    VIEWS [${viewCache.count()}] :';
					ret += '\n        ' + sortedlist({ iterator: function() return viewCache.keys() }.mapi(function(i, k) return '$k').array()).join('\n        ');
					trace('\n$ret');

				});
				reportRegistered = true;
			}
		#end
	}


	static function safename(str:String) {
		return str.replace('.', '_').replace('<', '').replace('>', '');
	}

	static function compareStrings(a:String, b:String):Int {
		a = a.toLowerCase();
		b = b.toLowerCase();
		if (a < b) return -1;
		if (a > b) return 1;
		return 0;
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
		var suf = types.map(function(type) return type.followName());
		suf.sort(compareStrings);
		return safename(suf.join('_'));
	}


	static public function getViewClsByTypes(types:Array<ComplexType>):ComplexType {
		var type = getClsName('View', getClsNameSuffix(types)).getType();
		return type != null ? type.toComplexType() : null;
	}


	static function getViewGenericComplexType(components:Array<{ name:String, cls:ComplexType }>):ComplexType {
		var viewClsParams = components.map(function(c) return fvar([], [], c.name, c.cls.followComplexType()));
		return TPath(tpath(['echo'], 'View', [TPType(TAnonymous(viewClsParams))]));
	}


	static public function autoBuildSystem() {
		report();
		var fields = Context.getBuildFields();
		var cls = Context.getLocalType().toComplexType();

		systemIdsMap[cls.followName()] = ++systemIndex;

		var fnew = fields.find(function(f) return f.name == 'new');
		if (fnew == null) {
			fields.push(ffun([APublic], 'new', null, null, macro __id = $v{ systemIndex }));
		} else {
			switch (fnew.kind) {
				case FFun(func):
					var fnewexprs = [ macro __id = $v{ systemIndex } ];

					switch (func.expr.expr) {
						case EBlock(exprs): for (expr in exprs) fnewexprs.push(expr);
						case e: fnewexprs.push(func.expr);
					}

					func.expr = macro $b{fnewexprs};

				default:
			}
		}

		var views = fields.map(function(field) {
			if (hasMeta(field, EXCLUDE_META)) return null; // skip by meta

			function getComponentsFromAnonTypeParam(t:TypePath) {
				switch (t.params) {
					case [ TPType(TAnonymous(fields)) ]:

						return fields.map(function(field) {
							switch (field.kind) {
								case FVar(cls, _): return { name: field.name, cls: cls.followComplexType() };
								case x: throw 'Unexp $x';
							}
						});

					case [ TPType(a = TPath(_)) ]:

						switch (a.toType().follow()) {
							case TAnonymous(_.get() => p):
								return p.fields.map(function(field:ClassField) return { name: field.name, cls: Context.toComplexType(field.type.follow()) });

							case x: throw 'Unexp $x';
						}

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

		function extFunc(f:Field) {
			return switch (f.kind) {
				case FFun(x): x;
				case x: null;
			}
		}

		fields.iter(function(f) {
			if (hasMeta(f, ONEACH_META)) { // TODO params ? (view name)
				var func = extFunc(f);

				// skip if not a func
				if (func == null) return;

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

				var components = func.args.map(function(a) {
					switch (a.type) {
						case macro:Int, macro:Float: 
							return null;
						default: 
							return { name: a.name, cls: a.type.followComplexType() };
					}
				}).filter(function(el) return el != null);

				if (components.length == 0) { // empty update

					updateExprs.push(macro $i{funcName}($a{funcArgs}));

				} else {
					var viewClsName = getClsName('View', getClsNameSuffixByComponents(components));
					var view = views.find(function(v) return getClsName('View', getClsNameSuffixByComponents(v.components)) == viewClsName);
					var viewName = viewClsName.toLowerCase();

					if (view == null) {
						var viewCls = getViewGenericComplexType(components);
						fields.push(fvar(viewName, viewCls));
						views.push({ name: viewName, components: components });
					} else {
						// this view already defined in this system
						viewName = view.name;
					}

					updateExprs.push(macro for (i in $i{ viewName }) $i{ funcName }($a{ funcArgs }));
				}

			}
		});

		// define view
		views.iter(function(v) {
			var viewCls = getViewGenericComplexType(v.components);
			var viewType = viewCls.tp();
			var viewId = viewIdsMap[viewCls.followName()];
			activateExprs.push(macro if (!echo.viewsMap.exists($v{ viewId })) echo.addView(new $viewType()));
			activateExprs.push(macro $i{ v.name } = cast echo.viewsMap[$v{ viewId }]);
		} );

		// onadd, onremove signals
		function refViewName(m:MetadataEntry) {
			return switch (m.params) {
				case [ _.expr => EConst(CString(x)) ]: x;
				case [ _.expr => EConst(CInt(x)) ]: views[Std.parseInt(x)].name;
				case []: views[0].name;
				case x: throw 'Unexp $x';
			}
		}
		fields.iter(function(f) {
			var onaddMeta = getMeta(f, ONADD_META);
			if (onaddMeta != null) {
				var viewName = refViewName(onaddMeta);
				var func = extFunc(f);

				// skip if not a func
				if (func == null) return;

				var funcName = f.name;

				switch (func) {
					case _.args => []:
						// nothing passed, so create a proxy func with no args
						funcName = '__${f.name}';
						fields.push(ffun([], [], funcName, [arg('id', macro:Int)], null, macro $i{ f.name }()));

					case _.args => (args = [ (arg = { type: TPath({ pack: [], name: 'Int' }) }) ]) if (args.length == 1):
						// only id:Int passed, so add this func to the signal
						funcName = f.name;

					default:
						// some components passed, so build a proxy func
						funcName = '__${f.name}';
						var funcArgs = func.args.map(function(a) {
							switch (a.type) {
								case macro:Int:
									return macro id;
								default:
									return macro echo.getComponent(id, ${ a.type.expr() });
							}
						});
						fields.push(ffun([], [], funcName, [arg('id', macro:Int)], null, macro $i{ f.name }($a{ funcArgs })));
				}

				activateExprs.push(macro $i{ viewName }.onAdded.add($i{ funcName }));
				activateExprs.push(macro for (i in $i{ viewName }.entities) $i{ funcName }(i));
				deactivateExprs.push(macro $i{ viewName }.onAdded.remove($i{ funcName }));
			}

			var onremMeta = getMeta(f, ONREMOVE_META);
			if (onremMeta != null) {
				var viewName = refViewName(onremMeta);
				var func = extFunc(f);

				if (func == null) return;

				var funcName = f.name;

				switch (func) {
					case _.args => []:
						funcName = '__${f.name}';
						fields.push(ffun([], [], funcName, [arg('id', macro:Int)], null, macro $i{ f.name }()));

					case _.args => (args = [ (arg = { type: TPath({ pack: [], name: 'Int' }) }) ]) if (args.length == 1):
						funcName = f.name;

					default:
						funcName = '__${f.name}';
						var funcArgs = func.args.map(function(a) {
							switch (a.type) {
								case macro:Int:
									return macro id;
								default:
									return macro echo.getComponent(id, ${ a.type.expr() });
							}
						});
						fields.push(ffun([], [], funcName, [arg('id', macro:Int)], null, macro $i{ f.name }($a{ funcArgs })));
				}

				activateExprs.push(macro $i{ viewName }.onRemoved.add($i{ funcName }));
				deactivateExprs.push(macro $i{ viewName }.onRemoved.remove($i{ funcName }));
			}
		} );

		// onactivate, ondeactivate
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

		traceFields(cls.followName(), fields);

		return fields;
	}


	static public function genericBuildView() {
		switch (Context.getLocalType()) {
			case TInst(_.get() => cls, [TAnonymous(_.get() => p)]):
				var components = p.fields.map(function(field:ClassField) return { name: field.name, cls: Context.toComplexType(field.type.follow()) });
				return getView(components).toType();

			case TInst(_.get() => cls, [TType(_.get() => { type:TAnonymous(_.get() => p) }, [])]):
				var components = p.fields.map(function(field:ClassField) return { name: field.name, cls: Context.toComplexType(field.type.follow()) });
				return getView(components).toType();

			case x: throw 'Unexpected $x! Require TAnonymous(_) or TType(TAnonymous(_))';
		}
	}


	static public function getView(components:Array<{ name:String, cls:ComplexType }>):ComplexType {
		report();
		var viewClsName = getClsName('View', getClsNameSuffixByComponents(components));
		var viewCls = viewCache.get(viewClsName);
		if (viewCls == null) {

			viewIdsMap[viewClsName] = ++viewIndex;

			var def:TypeDefinition = macro class $viewClsName extends echo.View.ViewBase {
				public function new() { __id = $v{ viewIndex }; }
			}

			var iteratorTypePath = getViewIterator(components).tp();
			def.fields.push(ffun([APublic, AInline], 'iterator', null, null, macro return new $iteratorTypePath(this.entities)));

			var testBody = Context.parse('return ' + components.map(function(c) return '${getComponentHolder(c.cls).followName()}.__MAP.exists(id)').join(' && '), Context.currentPos());
			def.fields.push(ffun([meta(':noCompletion')], [APublic, AOverride], 'test', [arg('id', macro:Int)], macro:Bool, testBody));

			// testcomponent
			def.fields.push(ffun([meta(':noCompletion')], [APublic, AOverride], 'testcomponent', [arg('c', macro:Int)], macro:Bool, macro return __MASK.exists(c)));

			var maskBody = Context.parse('[' + components.map(function(c) return '${getComponentHolder(c.cls).followName()}.__ID => true').join(', ') + ']', Context.currentPos());
			def.fields.push(fvar([meta(':noCompletion')], [AStatic], '__MASK', null, maskBody));

			traceTypeDefenition(def);

			Context.defineType(def);

			viewCls = Context.getType(viewClsName).toComplexType();
			viewCache.set(viewClsName, viewCls);
		}
		return viewCls;
	}


	static public function getViewIterator(components:Array<{ name:String, cls:ComplexType }>):ComplexType {
		var viewDataCls = getViewData(components);
		var viewIterClsName = getClsName('ViewIterator', viewDataCls.followName());
		var viewIterCls = viewIterCache.get(viewIterClsName);
		if (viewIterCls == null) {

			var viewDataType = viewDataCls.tp();

			var def = macro class $viewIterClsName {
				var i:Int;
				var list:Array<Int>;
				var vd:$viewDataCls;
				public inline function new(list:Array<Int>) {
					this.i = -1;
					this.list = list;
					this.vd = new $viewDataType(); // TODO opt js ( Object ? )
				}
				public inline function hasNext():Bool return ++i < list.length;
				//public inline function next():$dataViewCls return vd;
			}

			var nextExprs = [];
			nextExprs.push(macro this.vd.id = this.list[i]);
			components.iter(function(c) nextExprs.push(Context.parse('this.vd.${c.name} = ${getComponentHolder(c.cls).followName()}.__MAP.get(this.vd.id)', Context.currentPos())));
			nextExprs.push(macro return this.vd);
			def.fields.push(ffun([APublic, AInline], 'next', null, viewDataCls, macro $b{nextExprs}));

			traceTypeDefenition(def);

			Context.defineType(def);

			viewIterCls = Context.getType(viewIterClsName).toComplexType();
			viewIterCache.set(viewIterClsName, viewIterCls);
		}
		return viewIterCls;
	}


	static public function getViewData(components:Array<{ name:String, cls:ComplexType }>):ComplexType {
		var viewDataClsName = getClsName('ViewData', getClsNameSuffixByComponents(components));
		var viewDataCls = viewDataCache.get(viewDataClsName);
		if (viewDataCls == null) {

			var def:TypeDefinition = macro class $viewDataClsName {
				inline public function new() { }
				public var id:Int;
			}

			for (c in components) def.fields.push(fvar([APublic], c.name, c.cls));

			traceTypeDefenition(def);

			Context.defineType(def);

			viewDataCls = Context.getType(viewDataClsName).toComplexType();
			viewDataCache.set(viewDataClsName, viewDataCls);
		}
		return viewDataCls;
	}


	static public function getComponentHolder(componentCls:ComplexType):ComplexType {
		report();
		var componentHolderClsName = getClsName('ComponentHolder', componentCls.followName());
		var componentHolderCls = componentCache.get(componentCls.followName());
		if (componentHolderCls == null) {

			var def = macro class $componentHolderClsName {
				static public var __ID:Int = $v{componentIndex++};
				static public var __MAP:Map<Int, $componentCls> = new Map();
			}

			traceTypeDefenition(def);

			Context.defineType(def);

			componentHolderCls = Context.getType(componentHolderClsName).toComplexType();
			componentCache[componentCls.followName()] = componentHolderCls;
		}
		return componentHolderCls;
	}

}
#end
