package echo;
#if macro
import echo.macro.MacroBuilder;
import haxe.macro.Expr;
using haxe.macro.Context;
using echo.macro.Macro;
using Lambda;
#end

/**
 * ...
 * @author https://github.com/wimcake
 */
class Echo {


	@:noCompletion static public var __SEQUENCE = 0;


	@:noCompletion public var entitiesMap:Map<Int, Int> = new Map(); // map (id : id)
	@:noCompletion public var viewsMap:Map<Int, View.ViewBase> = new Map();

	public var entities(default, null):List<Int>;
	public var views(default, null):Array<View.ViewBase>;
	public var systems(default, null):Array<System>;


	public function new() {
		entities = new List();
		views = [];
		systems = [];
	}


	#if debug
		var updateStats:Map<System, Float> = new Map();
	#end
	inline public function stats():String {
		var ret = 'Echo' + ' [${entities.length}]' + '\n'; // TODO add version or something
		#if debug
			for (s in systems) {
				ret += '\t' + Type.getClassName(Type.getClass(s)) + ' : ' + updateStats.get(s) + ' ms\n';
			}
		#end
		return ret;
	}


	public function update(dt:Float) {
		for (s in systems) {
			#if debug
				var stamp = haxe.Timer.stamp();
			#end
			s.update(dt);
			#if debug
				updateStats.set(s, Std.int((haxe.Timer.stamp() - stamp) * 1000));
			#end
		}
	}


	// System

	public function addSystem(s:System) {
		s.activate(this);
		systems.push(s);
	}

	public function removeSystem(s:System) {
		s.deactivate();
		systems.remove(s);
	}


	// View

	public function addView(view:View.ViewBase) {
		if (!viewsMap.exists(view.__id)) {
			viewsMap[view.__id] = view;
			views.push(view);
			view.activate(this);
		}
	}

	public function removeView(view:View.ViewBase) {
		if (viewsMap.exists(view.__id)) {
			view.deactivate();
			viewsMap.remove(view.__id);
			views.remove(view);
		}
	}

	macro public function defineView(self:Expr, components:Expr):ExprOf<View.ViewBase> {
		switch (components.expr) {
			case EObjectDecl(fields):
				var components = fields.map(function(field) return { name: field.field, cls: field.expr.identName().getType().follow().toComplexType() });
				var viewCls = MacroBuilder.getView(components);
				var viewType = viewCls.tp();
				var v = Context.parse(viewCls.fullname(), Context.currentPos());
				return macro $self.__defineView($v.__ID, new $viewType());
			case x: throw 'Unexp $x';
		}
	}

	macro public function createView(self:Expr, components:Expr):ExprOf<View.ViewBase> {
		switch (components.expr) {
			case EObjectDecl(fields):
				var components = fields.map(function(field) return { name: field.field, cls: field.expr.identName().getType().follow().toComplexType() });
				var viewCls = MacroBuilder.getView(components);
				var viewType = viewCls.tp();
				return macro new $viewType();
			case x: throw 'Unexp $x';
		}
	}

	macro public function getView(self:Expr, types:Array<ExprOf<Class<Any>>>):ExprOf<View.ViewBase> {
		var viewCls = MacroBuilder.getViewClsByTypes(types.map(function(type) return type.identName().getType().follow().toComplexType()));
		var v = Context.parse(viewCls.fullname(), Context.currentPos());
		return macro $self.viewsMap[$v.__ID];
	}

	@:noCompletion public function __defineView(id:Int, view:View.ViewBase):View.ViewBase {
		addView(view);
		return viewsMap[id];
	}


	// Entity

	public function id():Int {
		var id = next();
		entitiesMap.set(id, id);
		entities.add(id);
		return id;
	}

	public inline function next():Int {
		return ++__SEQUENCE;
	}

	public inline function last():Int {
		return __SEQUENCE;
	}

	public inline function has(id:Int):Bool {
		return entitiesMap.exists(id);
	}

	public inline function add(id:Int) {
		if (!this.has(id)) {
			entitiesMap.set(id, id);
			entities.add(id);
			for (v in views) v.addIfMatch(id);
		}
	}

	public inline function poll(id:Int) {
		if (this.has(id)) {
			for (v in views) v.removeIfMatch(id);
			entitiesMap.remove(id);
			entities.remove(id);
		}
	}

	macro public function remove(self:Expr, id:ExprOf<Int>) {
		var esafe = macro var _id_ = $id;
		var exprs = [
			for (n in echo.macro.MacroBuilder.componentHoldersMap) {
				var n = Context.parse(n, Context.currentPos());
				macro $n.__MAP.remove(_id_);
			}
		];

		Macro.traceExprs('remove', exprs);

		return macro {
			$esafe;
			$self.poll(_id_);
			$b{exprs};
		}
	}


	// Component

	macro inline public function setComponent(self:Expr, id:ExprOf<Int>, components:Array<Expr>) {
		var esafe = macro var _id_ = $id; // TODO opt ( if EConst - safe is unnesessary )
		var exprs = [
			for (c in components) {
				var h = echo.macro.MacroBuilder.getComponentHolder(c.typeof().follow().toComplexType().fullname());
				//if (h == null) continue; // TODO define ?
				var n = Context.parse(h, Context.currentPos());
				macro $n.__MAP[_id_] = $c;
			}
		];

		Macro.traceExprs('setComponent', exprs);

		return macro {
			$esafe;
			$b{exprs};
			if ($self.has(_id_)) for (_v_ in $self.views) _v_.addIfMatch(_id_);
		}
	}

	macro inline public function removeComponent<T>(self:Expr, id:ExprOf<Int>, type:ExprOf<Class<T>>) {
		var esafe = macro var _id_ = $id;
		var h = echo.macro.MacroBuilder.getComponentHolder(type.identName().getType().follow().toComplexType().fullname());
		//if (h == null) return macro null;
		var n = Context.parse(h, Context.currentPos());
		return macro {
			$esafe;
			if ($n.__MAP.exists(_id_)) {
				if ($self.has(_id_)) for (_v_ in $self.views) if (_v_.testcomponent($n.__ID)) _v_.removeIfMatch(_id_);
				$n.__MAP.remove(_id_);
			}
		}
	}

	macro inline public function getComponent<T>(self:Expr, id:ExprOf<Int>, type:ExprOf<Class<T>>):ExprOf<T> {
		var h = echo.macro.MacroBuilder.getComponentHolder(type.identName().getType().follow().toComplexType().fullname());
		//if (h == null) return macro null;
		var n = Context.parse(h, Context.currentPos());
		return macro $n.__MAP.get($id);
	}

}
