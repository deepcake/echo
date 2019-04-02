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

    var incomplete = new Array<Entity>();

    var statuses = new Map<Int, CollectingStatus>();

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
            while (entities.length > 0) statuses.remove(entities.pop());
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
            addToIncomplete(id, QueuedToAdd);
        } else {
            statuses[id] = Collected;
            entities.push(id);
        }
        // macro on add call
    }

    function remove(id:Int) {
        // macro on remove call
        if (iterating) {
            addToIncomplete(id, QueuedToRemove);
        } else {
            statuses.remove(id);
            entities.remove(id);
        }
    }


    inline function status(id:Int):CollectingStatus {
        return statuses.exists(id) ? statuses[id] : Candidate;
    }


    @:allow(echos.Workflow) function addIfMatch(id:Int) {
        if (status(id) < QueuedToAdd && isMatch(id)) add(id);
    }

    @:allow(echos.Workflow) function removeIfMatch(id:Int) {
        if (status(id) > QueuedToRemove) remove(id);
    }


    inline function addToIncomplete(id:Int, status:CollectingStatus) {
        statuses[id] = status;
        if (incomplete.indexOf(id) == -1) incomplete.push(id);
    }

    inline function flush() {
        while (incomplete.length > 0) {
            var id = incomplete.pop();
            var status = status(id);
            if (status == QueuedToRemove) {
                statuses.remove(id);
                entities.remove(id);
            } else if (status == QueuedToAdd) {
                statuses[id] = Collected;
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
    var Candidate = 0;
    var QueuedToRemove = 1;
    var QueuedToAdd = 2;
    var Collected = 3;
    @:op(A > B) static function gt(a:CollectingStatus, b:CollectingStatus):Bool;
    @:op(A < B) static function lt(a:CollectingStatus, b:CollectingStatus):Bool;
}
