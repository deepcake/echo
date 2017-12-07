package echo.macro;

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
	#if macro


	static var EXCLUDE_META = ['skip', 'ignore', 'i'];
	static var ONADD_META = ['onadded', 'added', 'onadd', 'add', 'a'];
	static var ONREMOVE_META = ['onremoved', 'removed', 'onremove', 'onrem', 'remove', 'rem', 'r'];
	static var ONEACH_META = ['update', 'upd', 'u'];


	static public var componentIndex:Int = 0;
	static public var componentIds:Map<String, Int> = new Map();
	static public var componentCache:Map<String, ComplexType> = new Map();

	static public var componentMapCache:Map<String, ComplexType> = new Map();
	static public var componentMapNames:Array<String> = [];

	static public var viewIndex:Int = 0;
	static public var viewIdsMap:Map<String, Int> = new Map();
	static public var viewCache:Map<String, ComplexType> = new Map();
	static public var viewMasks:Map<Int, Map<Int, Bool>> = new Map();

	static public var viewIterCache:Map<String, ComplexType> = new Map();

	static public var viewDataCache:Map<String, ComplexType> = new Map();

	static public var systemIndex:Int = 0;
	static public var systemIdsMap:Map<String, Int> = new Map();


	static var reportRegistered = false;
	static var metaRegistered = false;


	static function hasMeta(field:Field, metas:Array<String>) {
		for (m in field.meta) for (meta in metas) if (m.name == meta) return true;
		return false;
	}

	static function getMeta(field:Field, metas:Array<String>) {
		for (m in field.meta) for (meta in metas) if (m.name == meta) return m;
		return null;
	}

	static function gen() {
		Context.onMacroContextReused(function() {
			#if echo_verbose 
			trace('macro context reused');
			#end

			reportRegistered = false;
			metaRegistered = false;
			return true;
		});

		#if echo_report
		if (!reportRegistered) {
			Context.onGenerate(function(types) {
				function sortedlist(array:Array<String>) {
					array.sort(compareStrings);
					return array;
				}

				var ret = 'ECHO BUILD REPORT :';
				ret += '\n    COMPONENTS [${componentMapCache.count()}] :';
				ret += '\n        ' + sortedlist({ iterator: function() return componentMapCache.keys() }.mapi(function(i, k) return '$k').array()).join('\n        ');
				ret += '\n    VIEWS [${viewCache.count()}] :';
				ret += '\n        ' + sortedlist({ iterator: function() return viewCache.keys() }.mapi(function(i, k) return '$k').array()).join('\n        ');
				trace('\n$ret');

			});
			reportRegistered = true;
		}
		#end

		if (!metaRegistered) {
			Context.onGenerate(function(types) {

				switch (Context.getType("echo.Echo")) {
					case TInst(_.get() => ct, _):
						if (ct.meta.has('components')) ct.meta.remove('components');
						ct.meta.add('components', componentMapNames.map(function(s) return macro $v{s}), Context.currentPos());
					default:
				}

			});
			metaRegistered = true;
		}
	}


	static function safename(str:String) {
		return str.replace('.', '_').replace('<', '').replace('>', '').replace(',', '');
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
		return id;
	}

	static function getClsNameSuffixByComponents(components:Array<{ name:String, cls:ComplexType }>) {
		return getClsNameSuffix(components.map(function(c) return c.cls));
	}

	static function getClsNameSuffix(types:Array<ComplexType>, safe:Bool = true):String {
		var suf = types.map(function(type) return type.followName());
		suf.sort(compareStrings);
		return safe ? safename(suf.join('_')) : suf.join(',');
	}


	static public function getViewClsByTypes(types:Array<ComplexType>):ComplexType {
		var type = getClsName('View', getClsNameSuffix(types)).getType();
		return type != null ? type.toComplexType() : null;
	}


	static function getViewGenericComplexType(components:Array<{ name:String, cls:ComplexType }>):ComplexType {
		var viewClsParams = components.map(function(c) return fvar([], [], c.name, c.cls.followComplexType(), Context.currentPos()));
		return TPath(tpath(['echo'], 'View', [TPType(TAnonymous(viewClsParams))]));
	}


	static public function autoBuildSystem() {
		gen();
		var fields = Context.getBuildFields();
		var cls = Context.getLocalType().toComplexType();

		systemIdsMap[cls.followName()] = ++systemIndex;

		var fnew = fields.find(function(f) return f.name == 'new');
		if (fnew == null) {
			fields.push(ffun([APublic], 'new', null, null, macro __id = $v{ systemIndex }, Context.currentPos()));
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

			switch (field.kind) {
				case FVar(cls, e) if (e == null):
					var viewCls = cls.followComplexType();
					if (viewCache.exists(viewCls.followName())) {
						return { name: field.name, cls: viewCls };
					}

				case FVar(_, _.expr => ENew(t, _)):
					var viewCls = TPath(t).followComplexType();
					if (viewCache.exists(viewCls.followName())) {
						field.kind = FVar(viewCls, null);
						return { name: field.name, cls: viewCls };
					}

				default:
			}

			return null;

		} ).filter(function(el) return el != null);


		function extFunc(f:Field) {
			return switch (f.kind) {
				case FFun(x): x;
				case x: null;
			}
		}

		function requestView(components) {
			var viewClsName = getClsName('View', getClsNameSuffixByComponents(components));
			var view = views.find(function(v) return v.cls.followName() == viewClsName);

			if (view == null) {
				var viewName = viewClsName.toLowerCase();
				var viewCls = getViewGenericComplexType(components);
				fields.push(fvar(viewName, viewCls, Context.currentPos()));
				view = { name: viewName, cls: viewCls };
				views.push(view);
			}

			return view.name;
		}


		function notNull(e:Dynamic) return e != null;

		function argToArg(a) {
			return switch (a.type) {
				case macro:Float: macro dt;
				case macro:Int: macro _id_;
				default: macro ${ getComponentHolder(a.type.followComplexType()).expr(Context.currentPos()) }.get(echo.__id)[_id_];
			}
		};

		function argToComponent(a) {
			return switch (a.type) {
				case macro:Int, macro:Float: null;
				default: { name: a.name, cls: a.type.followComplexType() };
			}
		};

		function addViewByMetaAndComponents(components:Array<{ name:String, cls:ComplexType }>, m:MetadataEntry) {
			return switch (m.params) {
				case [ _.expr => EConst(CString(x)) ]: x;
				case [ _.expr => EConst(CInt(x)) ]: views[Std.parseInt(x)].name;
				case [] if (components.length == 0 && views.length > 0): views[0].name;
				case [] if (components.length > 0): requestView(components);
				default: null;
			}
		}

		function findMetaFunc(f:Field, meta:Array<String>) {
			if (hasMeta(f, EXCLUDE_META)) return null; // skip by meta
			else if (hasMeta(f, meta)) {
				var func = extFunc(f);
				if (func == null) return null; // skip if not a func

				var funcName = f.name;
				var funcArgs = func.args.map(argToArg).filter(notNull);
				var components = func.args.map(argToComponent).filter(notNull);
				var view = addViewByMetaAndComponents(components, getMeta(f, meta));

				return { name: funcName, args: funcArgs, components: components, view: view };
			}
			return null;
		}


		var ufuncs = fields.map(findMetaFunc.bind(_, ONEACH_META)).filter(notNull);

		var afuncs = fields.map(findMetaFunc.bind(_, ONADD_META)).filter(notNull);
		var rfuncs = fields.map(findMetaFunc.bind(_, ONREMOVE_META)).filter(notNull);

		afuncs.concat(rfuncs).iter(function(f) {
			//fields.push(ffun([], [], '__${f.name}', [arg('_id_', macro:Int)], null, macro $i{ f.name }($a{ f.args }), Context.currentPos()));
			fields.push(fvar([], [], '__${f.name}', macro:Int->Void, null, Context.currentPos()));
		});


		var updateExprs = new List<Expr>()
			.concat(ufuncs.map(function(f){
				if (f.components.length == 0) {
					return macro $i{ f.name }($a{ f.args });
				} else {
					//var viewName = requestView(f.components);
					return macro for (_id_ in $i{ f.view }.entities) $i{ f.name }($a{ f.args });
				}
			}))
			.array();

		var activateExprs = new List<Expr>()
			.concat([ macro this.echo = echo ])
			.concat(
				afuncs.concat(rfuncs)
					.map(function(f){
						return macro $i{'__${f.name}'} = function(_id_:Int) $i{ f.name }($a{ f.args });
					})
			)
			.concat(
				views
					.map(function(v){
						var viewCls = v.cls; //getViewGenericComplexType(v.components);
						var viewType = viewCls.tp();
						var viewId = viewIdsMap[viewCls.followName()];
						return [
							macro if (!echo.viewsMap.exists($v{ viewId })) echo.addView(new $viewType()),
							macro $i{ v.name } = cast echo.viewsMap[$v{ viewId }]
						];
					})
					.flatten()
			)
			.concat(
				afuncs.map(function(f){
					return macro $i{ f.view }.onAdded.add($i{ '__${f.name}' });
				})
			)
			.concat(
				rfuncs.map(function(f){
					return macro $i{ f.view }.onRemoved.add($i{ '__${f.name}' });
				})
			)
			.concat([ macro onactivate() ])
			.concat(
				afuncs.map(function(f){
					return macro for (i in $i{ f.view }.entities) $i{ '__${f.name}' }(i);
				})
			)
			.array();

		var deactivateExprs = new List<Expr>()
			.concat([ macro ondeactivate() ])
			.concat(
				afuncs.map(function(f){
					return macro $i{ f.view }.onAdded.remove($i{ '__${f.name}' });
				})
			)
			.concat(
				rfuncs.map(function(f){
					return macro $i{ f.view }.onRemoved.remove($i{ '__${f.name}' });
				})
			)
			.concat(
				afuncs.concat(rfuncs)
					.map(function(f) {
						return macro $i{'__${f.name}'} = null;
					})
			)
			.concat([ macro this.echo = null ])
			.array();


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
				fields.push(ffun([APublic, AOverride], 'update', [arg('dt', macro:Float)], null, macro $b{updateExprs}, Context.currentPos()));
			}
		}

		fields.push(ffun([APublic, AOverride], 'activate', [arg('echo', macro:echo.Echo)], null, macro $b{activateExprs}, Context.currentPos()));
		fields.push(ffun([APublic, AOverride], 'deactivate', null, null, macro $b{deactivateExprs}, Context.currentPos()));

		// toString
		fields.push(ffun([AOverride, APublic], 'toString', null, macro:String, macro return $v{ cls.followName() }, Context.currentPos()));

		traceFields(cls.followName(), fields);

		return fields;
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

	static public function genericBuildView() {
		return createViewType(Context.getLocalType());
	}


	static public function getView(components:Array<{ name:String, cls:ComplexType }>):ComplexType {
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


	static public function getViewIterator(components:Array<{ name:String, cls:ComplexType }>):ComplexType {
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


	static public function getViewData(components:Array<{ name:String, cls:ComplexType }>):ComplexType {
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

	static public function getComponentHolder(componentCls:ComplexType):ComplexType {
			gen();
			var componentClsName = componentCls.followName();
			var componentHolderClsName = getClsName('ComponentMap', componentClsName);
			var componentHolderCls = componentMapCache.get(componentClsName);
			
			if (componentHolderCls == null) {

				componentIndex++;

				var def = macro class $componentHolderClsName {
					static var __tl:Map<Int, Map<Int, $componentCls>> = new Map();
					public static function get(i:Int) return __tl[i] != null ? __tl[i] : __tl[i] = new Map<Int, $componentCls>();
				}

				traceTypeDefenition(def);

				Context.defineType(def);

				componentHolderCls = Context.getType(componentHolderClsName).toComplexType();
				componentIds[componentClsName] = componentIndex;
				componentCache[componentClsName] = componentCls;
				componentMapCache[componentClsName] = componentHolderCls;
				componentMapNames.push(componentHolderClsName);
			}
			return componentHolderCls;
	}

	static public function getComponentId(componentCls:ComplexType):Int {
		getComponentHolder(componentCls);
		return componentIds[componentCls.followName()];
	}

	#end
}
