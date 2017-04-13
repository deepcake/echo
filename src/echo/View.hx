package echo;

/**
 * ...
 * @author octocake1
 */
#if !macro
@:autoBuild(echo.macro.MacroBuilder.buildView())
#end
class View {
	
	
	var echo:Echo;
	
	
	public var onAdd = new Signal<Int->Void>();
	public var onRemove = new Signal<Int->Void>();
	
	public var entitiesMap:Map<Int, Int> = new Map(); // map (id : index)
	public var entities:Array<Int> = []; // additional array for sorting purposes
	
	
	public var id:Int;
	
	
	public function new() { }
	
	
	@:allow(echo.Echo) function activate(echo:Echo) {
		this.echo = echo;
		for (e in echo.entities) addIfMatch(e);
	}
	
	@:allow(echo.Echo) function deactivate() {
		while (entities.length > 0) entitiesMap.remove(entities.pop());
		this.echo = null;
	}
	
	
	public function select(id:Int):View { // macro
		this.id = id;
		return this;
	}
	
	
	@:noCompletion function test(id:Int):Bool { // macro
		// each component map exists(e) 
		return false;
	}
	
	@:noCompletion public function testcomponent(c:Int):Bool { // macro
		// this view has a component
		return false;
	}
	
	
	public inline function exists(id:Int):Bool {
		return entitiesMap.exists(id);
	}
	
	public inline function add(id:Int) {
		entitiesMap.set(id, entities.length);
		entities.push(id);
		
		select(id);
		onAdd.dispatch(id);
	}
	
	public inline function remove(id:Int) {
		select(id);
		onRemove.dispatch(id);
		
		entities.remove(id);
		entitiesMap.remove(id);
	}
	
	
	@:noCompletion public function addIfMatch(id:Int) {
		if (!exists(id) && test(id)) add(id);
	}
	
	@:noCompletion public function removeIfMatch(id:Int) {
		if (exists(id)) remove(id);
	}
	
}

@:noCompletion
#if !js @:generic #end
class ViewIterator<T:View> {
	
	var v:T;
	var i:Int;
	
	public inline function new(v:T) {
		this.v = v;
		this.i = -1;
	}

	public inline function hasNext():Bool {
		return ++i < v.entities.length;
	}

	public inline function next():T {
		v.select(v.entities[i]);
		return v;
	}
	
}