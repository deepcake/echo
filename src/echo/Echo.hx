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


	@:noCompletion public var __IDSEQUENCE = 0;


	@:noCompletion public var h = new H(); // components holder


	@:noCompletion public var entitiesMap:Map<Int, Int> = new Map(); // map (id : id)
	@:noCompletion public var viewsMap:Map<Int, View.ViewBase> = new Map();
	@:noCompletion public var systemsMap:Map<Int, System> = new Map();

	/** List of added ids (entities) */
	public var entities(default, null):List<Int> = new List();
	/** List of added views */
	public var views(default, null):List<View.ViewBase> = new List();
	/** List of added systems */
	public var systems(default, null):List<System> = new List();


	public function new() { }


	#if echo_debug
		var updateStats:Map<Int, Float> = new Map();
		var timestamp = haxe.Timer.stamp();
	#end
	inline public function toString():String {
		var ret = 'Echo' + ' ( ${systems.length} )' + ' { ${views.length} }' + ' [ ${entities.length} ]'; // TODO add version or something
		#if echo_debug
			ret += '\n    since last update : ' + updateStats.get(-10) + ' ms';
			ret += '\n    echo total update : ' + updateStats.get(-100) + ' ms';
			for (s in systems) {
				ret += '\n        ( $s ) : ' + updateStats.get(s.__id) + ' ms';
			}
			for (v in views) {
				ret += '\n    { $v } [ ${v.entities.length} ]';
			}
		#end
		return ret;
	}


	/**
	 * Update
	 * @param dt `Float` Delta time
	 */
	public function update(dt:Float) {
		#if echo_debug
			updateStats.set(-10, Std.int((haxe.Timer.stamp() - timestamp) * 1000));
			var updateTimestamp = haxe.Timer.stamp();
		#end
		for (s in systems) {
			#if echo_debug
				timestamp = haxe.Timer.stamp();
			#end
			s.update(dt);
			#if echo_debug
				updateStats.set(s.__id, Std.int((haxe.Timer.stamp() - timestamp) * 1000));
			#end
		}
		#if echo_debug
			timestamp = haxe.Timer.stamp();
			updateStats.set(-100, Std.int((timestamp - updateTimestamp) * 1000));
		#end
	}


	// System

	/**
	 * Adds system to the workflow
	 * @param s `System` instance
	 */
	public function addSystem(s:System) {
		if (!systemsMap.exists(s.__id)) {
			systemsMap[s.__id] = s;
			systems.add(s);
			s.activate(this);
		}
	}

	/**
	 * Removes system from the workflow
	 * @param s `System` instance
	 */
	public function removeSystem(s:System) {
		if (systemsMap.exists(s.__id)) {
			s.deactivate();
			systemsMap.remove(s.__id);
			systems.remove(s);
		}
	}

	/**
	 * Returns `true` if system with passed `type` was been added to the workflow, otherwise returns `false`
	 * @param type `Class<T>` system type
	 * @return `Bool`
	 */
	macro public function hasSystem<T:System>(self:Expr, type:ExprOf<Class<T>>):ExprOf<Bool> {
		var cls = type.identName().getType().follow().toComplexType();
		return macro $self.systemsMap.exists($v{ MacroBuilder.systemIdsMap[cls.followName()] });
	}

	/**
	 * Retrives a system from the workflow by its type. If system with passed type will be not founded, `null` will be returned
	 * @param type `Class<T>` system type
	 * @return `System`
	 */
	macro public function getSystem<T:System>(self:Expr, type:ExprOf<Class<T>>):ExprOf<Null<System>> {
		var cls = type.identName().getType().follow().toComplexType();
		return macro $self.systemsMap[$v{ MacroBuilder.systemIdsMap[cls.followName()] }];
	}


	// View

	/**
	 * Adds view to the workflow
	 * @param v `View<T>` instance
	 */
	public function addView(v:View.ViewBase) {
		if (!viewsMap.exists(v.__id)) {
			viewsMap[v.__id] = v;
			views.add(v);
			v.activate(this);
		}
	}

	/**
	 * Removes view to the workflow
	 * @param v `View<T>` instance
	 */
	public function removeView(v:View.ViewBase) {
		if (viewsMap.exists(v.__id)) {
			v.deactivate();
			viewsMap.remove(v.__id);
			views.remove(v);
		}
	}

	/**
	 * Returns `true` if view with passed `type` was been added to the workflow, otherwise returns `false`
	 * @param type `Class<T>` view type
	 * @return `Bool`
	 */
	macro public function hasView<T:View.ViewBase>(self:Expr, type:ExprOf<Class<T>>):ExprOf<Bool> {
		var cls = type.identName().getType().follow().toComplexType();
		return macro $self.viewsMap.exists($v{ MacroBuilder.viewIdsMap[cls.followName()] });
	}

	/**
	 * Retrives a view from the workflow by its type. If view with passed type will be not found, `null` will be returned
	 * @param type `Class<T>` view type
	 * @return `View<T>`
	 */
	macro public function getView<T:View.ViewBase>(self:Expr, type:ExprOf<Class<T>>):ExprOf<Null<View.ViewBase>> {
		var cls = type.identName().getType().follow().toComplexType();
		return macro $self.viewsMap[$v{ MacroBuilder.viewIdsMap[cls.followName()] }];
	}

	macro public function getViewByTypes(self:Expr, types:Array<ExprOf<Class<Any>>>):ExprOf<Null<View.ViewBase>> {
		var viewCls = MacroBuilder.getViewClsByTypes(types.map(function(type) return type.identName().getType().follow().toComplexType()));
		return macro $self.viewsMap[$v{ MacroBuilder.viewIdsMap[viewCls.followName()] }];
	}

	macro public function hasViewByTypes(self:Expr, types:Array<ExprOf<Class<Any>>>):ExprOf<Bool> {
		var viewCls = MacroBuilder.getViewClsByTypes(types.map(function(type) return type.identName().getType().follow().toComplexType()));
		return macro $self.viewsMap.exists($v{ MacroBuilder.viewIdsMap[viewCls.followName()] });
	}


	// Entity

	/**
	 * Creates a new id (entity) and returns it
	 * @param add `Bool` Immediate adds created id to the workflow if `true`, otherwise not. Default `true`
	 * @return `Int`
	 */
	public function id(add:Bool = true):Int {
		var id = ++__IDSEQUENCE;
		if (add) {
			entitiesMap.set(id, id);
			entities.add(id);
		}
		return id;
	}

	/**
	 * Retrives last added id
	 * @return `Int`
	 */
	public inline function last():Int {
		return __IDSEQUENCE;
	}

	/**
	 * Returns `true` if the id (entity) is added to the workflow, otherwise returns `false`
	 * @param id `Int` The id (entity)
	 * @return `Bool`
	 */
	public inline function has(id:Int):Bool {
		return entitiesMap.exists(id);
	}

	/**
	 * Adds the id (entity) to the workflow
	 * @param id `Int` The id (entity)
	 */
	public inline function add(id:Int) {
		if (!this.has(id)) {
			entitiesMap.set(id, id);
			entities.add(id);
			for (v in views) v.addIfMatch(id);
		}
	}

	/**
	 * Removes the id (entity) from the workflow without removing its components
	 * @param id `Int` The id (entity)
	 */
	public inline function poll(id:Int) {
		if (this.has(id)) {
			for (v in views) v.removeIfMatch(id);
			entitiesMap.remove(id);
			entities.remove(id);
		}
	}

	/**
	 * Removes the id (entity) from the workflow and removes all it components
	 * @param id `Int` The id (entity)
	 */
	macro public function remove(self:Expr, id:ExprOf<Int>) {
		var esafe = macro var _id_ = $id;
		var exprs = [
			for (i in echo.macro.MacroBuilder.componentIds) {
				macro $self.h.removeValue($v{ i }, _id_);
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
	 * Adds/Sets a components to the id
	 * @param id `Int` The id (entity)
	 * @param components List of `Any` components to add to the id (entity), one or many at once
	 */
	macro inline public function setComponent(self:Expr, id:ExprOf<Int>, components:Array<Expr>) {
		var esafe = macro var _id_ = $id; // TODO opt ( if EConst - safe is unnesessary )
		var exprs = [
			for (c in components) {
				var i = echo.macro.MacroBuilder.getComponentId(c.typeof().follow().toComplexType());
				macro $self.h.setValue($v{ i }, _id_, $c);
			}
		];
		return macro {
			$esafe;
			$b{exprs};
			if ($self.has(_id_)) for (_v_ in $self.views) _v_.addIfMatch(_id_);
		}
	}

	/**
	 * Removes a component from the id (entity) by its type
	 * @param id `Int` The id (entity)
	 * @param type `Class<T>` component type
	 */
	macro inline public function removeComponent(self:Expr, id:ExprOf<Int>, type:ExprOf<Class<Any>>) {
		var esafe = macro var _id_ = $id;
		var i = echo.macro.MacroBuilder.getComponentId(type.identName().getType().follow().toComplexType());
		return macro {
			$esafe;
			if ($self.h.hasValue($v{ i }, _id_)) {
				if ($self.has(_id_)) for (_v_ in $self.views) if (_v_.isRequire($v{ i })) _v_.removeIfMatch(_id_);
				$self.h.removeValue($v{ i }, _id_);
			}
		}
	}

	/**
	 * Retrives a component from the id (entity) by its type
	 * @param id `Int` The id (entity)
	 * @param type `Class<T>` component type
	 * @return `Any`
	 */
	macro inline public function getComponent<T>(self:Expr, id:ExprOf<Int>, t:ExprOf<Class<T>>):ExprOf<T> {
		var ctype = t.identName().getType().follow().toComplexType();
		var i = echo.macro.MacroBuilder.getComponentId(ctype);
		return macro ( $self.h.getValue($v{ i }, $id) : $ctype );
	}

	/**
	 * Returns true if the id (entity) has a component with this type, otherwise returns false
	 * @param id `Int` The id (entity)
	 * @param type `Class<T>` component type
	 * @return `Bool`
	 */
	macro inline public function hasComponent(self:Expr, id:ExprOf<Int>, type:ExprOf<Class<Any>>):ExprOf<Bool> {
		var i = echo.macro.MacroBuilder.getComponentId(type.identName().getType().follow().toComplexType());
		return macro $self.h.hasValue($v{ i }, $id);
	}

}

typedef IntIntAnyMap = Map<Int, Map<Int, Any>>;

abstract H(IntIntAnyMap) from IntIntAnyMap to IntIntAnyMap {
	public function new() {
		this = new IntIntAnyMap();
	}
	public function setValue(k1:Int, k2:Int, v:Any) {
		if (!this.exists(k1)) this.set(k1, new Map<Int, Any>());
		this.get(k1).set(k2, v);
	}
	public function getValue(k1:Int, k2:Int):Any {
		return this.exists(k1) ? this.get(k1).get(k2) : null;
	}
	public function hasValue(k1:Int, k2:Int):Bool {
		return this.exists(k1) ? this.get(k1).exists(k2) : false;
	}
	public function removeValue(k1:Int, k2:Int) {
		if (this.exists(k1)) this.get(k1).remove(k2);
	}
}
