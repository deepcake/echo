package echos;

/**
 * View  
 *  
 * @author https://github.com/deepcake
 */
#if !macro
@:genericBuild(echos.macro.ViewMacro.build())
#end
class View<T> extends ViewBase { }


@:noCompletion
class ViewBase {


    var activated = false;

    var entitiesMap:Map<Int, Int> = new Map(); // map (id : id) // TODO what keep in value ?

    /** List of matched entities */
    public var entities(default, null):List<Entity> = new List();


    public function activate() {
        if (!activated) {
            Workflow.views.add(this);
            for (e in Workflow.entities) addIfMatch(e);
            activated = true;
        }
    }

    public function deactivate() {
        if (activated) {
            while (entities.length > 0) entitiesMap.remove(entities.pop());
            Workflow.views.remove(this);
            activated = false;
        }
    }


    function isMatch(id:Int):Bool { // macro
        // each required component exists in component map with this id
        return false;
    }

    function isRequire(c:Int):Bool { // macro
        return false;
    }


    function add(id:Int) {
        entitiesMap.set(id, id);
        entities.add(id);
    }

    function remove(id:Int) {
        entities.remove(id);
        entitiesMap.remove(id);
    }

    inline function exists(id:Int):Bool {
        return entitiesMap.exists(id);
    }


    @:allow(echos.Workflow) function addIfMatch(id:Int) {
        if (!exists(id) && isMatch(id)) add(id);
    }

    @:allow(echos.Workflow) function removeIfMatch(id:Int) {
        if (exists(id)) remove(id);
    }


    @:allow(echos.Workflow) function dispose() {
        deactivate();
    }


    public function toString():String return 'ViewBase';

}
