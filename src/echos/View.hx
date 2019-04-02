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


    var iterating = false;

    var changed = new Array<Entity>();

    var entitiesMap = new Map<Int, CollectingStatus>();

    /** List of matched entities */
    public var entities(default, null) = new Array<Entity>();


    public function activate() {
        if (!isActive()) {
            Workflow.views.add(this);
            for (e in Workflow.entities) addIfMatch(e);
        }
    }

    public function deactivate() {
        if (isActive()) {
            while (entities.length > 0) entitiesMap.remove(entities.pop());
            Workflow.views.remove(this);
        }
    }

    public function isActive() {
        for (v in Workflow.views) {
            if (v == this) return true;
        }
        return false;
    }


    function isMatch(id:Int):Bool { // macro
        // each required component exists in component map with this id
        return false;
    }

    function isRequire(c:Int):Bool { // macro
        return false;
    }


    function add(id:Int) {
        if (iterating) {
            addToChanged(id, QueuedToAdd);
        } else {
            entitiesMap[id] = Collected;
            entities.push(id);
        }
        // macro on add call
    }

    function remove(id:Int) {
        // macro on remove call
        if (iterating) {
            addToChanged(id, QueuedToRemove);
        } else {
            entitiesMap.remove(id);
            entities.remove(id);
        }
    }


    inline function status(id:Int):CollectingStatus {
        return entitiesMap.exists(id) ? entitiesMap[id] : Unprocessed;
    }


    @:allow(echos.Workflow) function addIfMatch(id:Int) {
        if (status(id) < QueuedToAdd && isMatch(id)) add(id);
    }

    @:allow(echos.Workflow) function removeIfMatch(id:Int) {
        if (status(id) > QueuedToRemove) remove(id);
    }


    inline function addToChanged(id:Int, status:CollectingStatus) {
        entitiesMap[id] = status;
        if (changed.indexOf(id) == -1) changed.push(id);
    }

    inline function flush() {
        while (changed.length > 0) {
            var id = changed.pop();
            var status = status(id);
            if (status == QueuedToRemove) {
                entitiesMap.remove(id);
                entities.remove(id);
            } else if (status == QueuedToAdd) {
                entitiesMap[id] = Collected;
                entities.push(id);
            }
        }
    }


    @:allow(echos.Workflow) function dispose() {
        deactivate();
    }


    public function toString():String return 'ViewBase';

}

@:enum private abstract CollectingStatus(Int) {
    var Unprocessed = 0;
    var QueuedToRemove = 1;
    var QueuedToAdd = 2;
    var Collected = 3;
    @:op(A > B) static function gt(a:CollectingStatus, b:CollectingStatus):Bool;
    @:op(A < B) static function lt(a:CollectingStatus, b:CollectingStatus):Bool;
}
