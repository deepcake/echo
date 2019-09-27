package echos.core;

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
                addIfMatch(e);
            }
        }
    }

    public function deactivate() {
        activations--;
        if (activations == 0) {
            Workflow.views.remove(this);
            while (entities.length > 0) {
                remove(entities.pop());
            }
        }
    }

    public function isActive():Bool {
        return activations > 0;
    }


    public inline function size():Int {
        return entities.length;
    }


    function isMatch(id:Int):Bool { // macro
        // each required component exists in component map with this id
        return false;
    }

    function isRequire(c:Int):Bool { // macro
        // check that this component type is required
        return false;
    }


    function add(id:Int) {
        // macro on add call
    }

    function remove(id:Int) {
        // macro on remove call
    }


    @:allow(echos.Workflow) function addIfMatch(id:Int) {
        if (isMatch(id)) {
            if (!entities.exists(id)) {
                entities.add(id);
                add(id);
            }
        }
    }

    @:allow(echos.Workflow) function removeIfMatch(id:Int) {
        // if remove is success - true returned
        if (entities.remove(id)) {
            remove(id);
        }
    }


    @:allow(echos.Workflow) function reset() {
        activations = 0;
        Workflow.views.remove(this);
        while (entities.length > 0) {
            remove(entities.pop());
        }
    }


    public function toString():String {
        return 'AbstractView';
    }


}
