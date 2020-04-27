package echoes.core;

/**
 * ...
 * @author https://github.com/deepcake
 */
class AbstractView {


    /** List of matched entities */
    public var entities(default, null) = new RestrictedLinkedList<Entity>();

    var collected = new Array<Bool>();

    var activations = 0;


    public function activate() {
        activations++;
        if (activations == 1) {
            Workflow.views.add(this);
            for (e in Workflow.entities) {
                addIfMatched(e);
            }
        }
    }

    public function deactivate() {
        activations--;
        if (activations == 0) {
            Workflow.views.remove(this);
            while (entities.length > 0) {
                removeIfExists(entities.pop());
            }
        }
    }

    public inline function isActive():Bool {
        return activations > 0;
    }


    public inline function size():Int {
        return entities.length;
    }


    function isMatched(id:Int):Bool {
        // each required component exists in component container with this id
        // macro generated
        return false;
    }


    function dispatchAddedCallback(id:Int) {
        // macro generated
    }

    function dispatchRemovedCallback(id:Int) {
        // macro generated
    }


    @:allow(echoes.Workflow) function addIfMatched(id:Int) {
        if (isMatched(id)) {
            if (collected[id] != true) {
                collected[id] = true;
                entities.add(id);
                dispatchAddedCallback(id);
            }
        }
    }

    @:allow(echoes.Workflow) function removeIfExists(id:Int) {
        if (collected[id] == true) {
            collected[id] = false;
            entities.remove(id);
            dispatchRemovedCallback(id);
        }
    }


    @:allow(echoes.Workflow) function reset() {
        activations = 0;
        Workflow.views.remove(this);
        while (entities.length > 0) {
            removeIfExists(entities.pop());
        }
        collected.splice(0, collected.length);
    }


    public function toString():String {
        return 'AbstractView';
    }


}
