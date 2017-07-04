package echo;

/**
 * ...
 * @author https://github.com/wimcake
 */
#if !macro
@:genericBuild(echo.macro.MacroBuilder.genericBuildView())
#end
class View<T> { }

/**
 *
 */
@:noCompletion
class ViewBase {


	var echo:Echo;
	var entitiesMap:Map<Int, Int> = new Map(); // map (id : id) // TODO what keep in value ?

	@:noCompletion public var __id = -1;

	/** Signal that dispatched when this view collects a new id (entity) */
	public var onAdded(default, null) = new echo.utils.Signal<Int->Void>();
	/** Signal that dispatched when an id (entity) no more matched and will be removed */
	public var onRemoved(default, null) = new echo.utils.Signal<Int->Void>();

	/** List of matched ids (entities) */
	public var entities(default, null):Array<Int> = []; // additional array for sorting purposes


	@:noCompletion public function activate(echo:Echo) {
		this.echo = echo;
		for (e in echo.entities) addIfMatch(e);
	}

	@:noCompletion public function deactivate() {
		while (entities.length > 0) entitiesMap.remove(entities.pop());
		this.echo = null;
	}


	@:noCompletion function isMatch(id:Int):Bool { // macro
		// each required component exists in global component map with this id
		return false;
	}

	@:noCompletion public function isRequire(c:Int):Bool { // macro
		// this view requires a component
		return false;
	}


	inline function exists(id:Int):Bool {
		return entitiesMap.exists(id);
	}

	inline function add(id:Int) {
		entitiesMap.set(id, id);
		entities.push(id);
		onAdded.dispatch(id);
	}

	inline function remove(id:Int) {
		onRemoved.dispatch(id);
		entities.remove(id);
		entitiesMap.remove(id);
	}


	@:noCompletion public function addIfMatch(id:Int) {
		if (!exists(id) && isMatch(id)) add(id);
	}

	@:noCompletion public function removeIfMatch(id:Int) {
		if (exists(id)) remove(id);
	}


	public function toString():String return 'ViewBase';

}
