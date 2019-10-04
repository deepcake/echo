package echoes.core;

/**
 * ...
 * @author https://github.com/deepcake
 */
class AbstractView {


    /** List of matched entities */
    public var entities(default, null) = new RestrictedLinkedList<Entity>();

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
                dispatchRemovedCallback(entities.pop());
            }
        }
    }

    public function isActive():Bool {
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
            if (!entities.exists(id)) {
                entities.add(id);
                dispatchAddedCallback(id);
            }
        }
    }

    @:allow(echoes.Workflow) function removeIfExists(id:Int) {
        // if removing is succeed - true returned
        if (entities.remove(id)) {
            dispatchRemovedCallback(id);
        }
    }


    @:allow(echoes.Workflow) function reset() {
        activations = 0;
        Workflow.views.remove(this);
        while (entities.length > 0) {
            dispatchRemovedCallback(entities.pop());
        }
    }


    public function toString():String {
        return 'AbstractView';
    }


}
