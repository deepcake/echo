package echo;

/**
 * ...
 * @author octocake1
 */
#if !macro
@:autoBuild(echo.macro.MacroBuilder.buildView())
#end
class View {
	// TODO only generic
	
	
	var echo:Echo;
	
	
	public var onAdd = new Signal<Int->Void>();
	public var onRemove = new Signal<Int->Void>();
	
	public var entitiesMap:Map<Int, Int> = new Map(); // map (id : id) // TODO what keep in value ?
	public var entities:Array<Int> = []; // additional array for sorting purposes
	
	
	
	@:allow(echo.Echo) function activate(echo:Echo) {
		this.echo = echo;
		for (e in echo.entities) addIfMatch(e);
	}
	
	@:allow(echo.Echo) function deactivate() {
		while (entities.length > 0) entitiesMap.remove(entities.pop());
		this.echo = null;
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
		entitiesMap.set(id, id);
		entities.push(id);
		onAdd.dispatch(id);
	}
	
	public inline function remove(id:Int) {
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