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


	@:noCompletion static public var __IDSEQUENCE = 0;


	@:noCompletion public var entitiesMap:Map<Int, Int> = new Map(); // map (id : id)
	@:noCompletion public var viewsMap:Map<Int, View.ViewBase> = new Map();

	/** List of added ids (entities) */
	public var entities(default, null):List<Int> = new List();
	/** Array of added views */
	public var views(default, null):Array<View.ViewBase> = [];
	/** Array of added systems */
	public var systems(default, null):Array<System> = [];


	public function new() { }


	#if debug
		var updateStats:Map<System, Float> = new Map();
	#end
	inline public function stats():String {
		var ret = 'Echo:' + ' ( ${systems.length} )' + ' { ${views.length} }' + ' [ ${entities.length} ]' + '\n'; // TODO add version or something
		#if debug
			for (v in views) {
				ret += '\t' + Type.getClassName(Type.getClass(v)) + ' [ ${views.length} ]' + '\n';
			}
			ret += '\n';
			for (s in systems) {
				ret += '\t' + Type.getClassName(Type.getClass(s)) + ' : ' + updateStats.get(s) + ' ms' + '\n';
			}
		#end
		return ret;
	}

	/**
	 *  @param dt - delta time
	 */
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
				return macro $self.__defineView($v{ MacroBuilder.viewIdsMap[viewCls.followName()] }, ${ viewCls.expr() }.new);
			case x: throw 'Unexp $x';
		}
	}

	@:noCompletion public function __defineView(id:Int, constructor:Void->View.ViewBase):View.ViewBase {
		if (!viewsMap.exists(id)) addView(constructor());
		return viewsMap[id];
	}

	macro public function getView(self:Expr, types:Array<ExprOf<Class<Any>>>):ExprOf<View.ViewBase> {
		var viewCls = MacroBuilder.getViewClsByTypes(types.map(function(type) return type.identName().getType().follow().toComplexType()));
		return macro $self.viewsMap[$v{ MacroBuilder.viewIdsMap[viewCls.followName()] }];
	}


	// Entity

	/**
	 *  Gets new id (entity) and adds it to the workflow, and return it
	 *  Equals to call `next()` and then `add()`
	 *  @return Int
	 */
	public function id():Int {
		var id = next();
		entitiesMap.set(id, id);
		entities.add(id);
		return id;
	}

	/**
	 *  Gets new id (entity) without adding it ot the workflow (so it will not be collected by views)
	 *  @return Int
	 */
	public inline function next():Int {
		return ++__IDSEQUENCE;
	}

	/**
	 *  Gets last added id
	 *  @return Int
	 */
	public inline function last():Int {
		return __IDSEQUENCE;
	}

	/**
	 *  If the id (entity) is added to the workflow then return true, otherwise return false
	 *  @param id - the id (entity)
	 *  @return Bool
	 */
	public inline function has(id:Int):Bool {
		return entitiesMap.exists(id);
	}

	/**
	 *  Adds the id (entity) to the workflow
	 *  @param id - the id (entity)
	 */
	public inline function add(id:Int) {
		if (!this.has(id)) {
			entitiesMap.set(id, id);
			entities.add(id);
			for (v in views) v.addIfMatch(id);
		}
	}

	/**
	 *  Removes the id (entity) from the workflow without removing its components
	 *  @param id - the id (entity)
	 */
	public inline function poll(id:Int) {
		if (this.has(id)) {
			for (v in views) v.removeIfMatch(id);
			entitiesMap.remove(id);
			entities.remove(id);
		}
	}

	/**
	 *  Removes the id (entity) from the workflow and removes all it components
	 *  @param id - the id (entity)
	 */
	macro public function remove(self:Expr, id:ExprOf<Int>) {
		var esafe = macro var _id_ = $id;
		var exprs = [
			for (hCls in echo.macro.MacroBuilder.componentCache) {
				macro ${ hCls.expr() }.__MAP.remove(_id_);
			}
		];
		return macro {
			$esafe;
			$self.poll(_id_);
			$b{exprs};
		}
	}


	// Component

	/**
	 *  Adds/sets a components to the id
	 *  @param id - the id (entity)
	 *  @param components - one or many at once
	 */
	macro inline public function setComponent(self:Expr, id:ExprOf<Int>, components:Array<Expr>) {
		var esafe = macro var _id_ = $id; // TODO opt ( if EConst - safe is unnesessary )
		var exprs = [
			for (c in components) {
				var hCls = echo.macro.MacroBuilder.getComponentHolder(c.typeof().follow().toComplexType());
				macro ${ hCls.expr() }.__MAP[_id_] = $c;
			}
		];
		return macro {
			$esafe;
			$b{exprs};
			if ($self.has(_id_)) for (_v_ in $self.views) _v_.addIfMatch(_id_);
		}
	}

	/**
	 *  Removes a component from the id (entity) by its type
	 *  @param id - the id (entity)
	 *  @param type - component type to be removed
	 */
	macro inline public function removeComponent(self:Expr, id:ExprOf<Int>, type:ExprOf<Class<Any>>) {
		var esafe = macro var _id_ = $id;
		var hCls = echo.macro.MacroBuilder.getComponentHolder(type.identName().getType().follow().toComplexType());
		return macro {
			$esafe;
			if (${ hCls.expr() }.__MAP.exists(_id_)) {
				if ($self.has(_id_)) for (_v_ in $self.views) if (_v_.testcomponent(${ hCls.expr() }.__ID)) _v_.removeIfMatch(_id_);
				${ hCls.expr() }.__MAP.remove(_id_);
			}
		}
	}

	/**
	 *  Gets a component from the id (entity) by its type
	 *  @param id - the id (entity)
	 *  @param type - component type to be got
	 *  @return T
	 */
	macro inline public function getComponent<T>(self:Expr, id:ExprOf<Int>, type:ExprOf<Class<T>>):ExprOf<T> {
		var hCls = echo.macro.MacroBuilder.getComponentHolder(type.identName().getType().follow().toComplexType());
		return macro ${ hCls.expr() }.__MAP.get($id);
	}

}
