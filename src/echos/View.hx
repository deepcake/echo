package echos;

/**
 * View  
 * 
 *  A View can be defined manually in the following simple ways:  
 *  View<T1, T2, TN>  
 *  View<T1->T2->TN>  
 * 
 *  __Note__ that when Entity is removed from the View, it becomes `Entity.INVALID` until the next `Workflow.update()` call. 
 *  So be careful when iterating without using `iter()`, and if so, be sure to check `entity.isValid()`. 
 *  It also means that `entities.length` may not show the actual number of entities. For actual count _right now right here_ you can use `size()` func.  
 *  
 * @author https://github.com/deepcake
 */
#if !macro
@:genericBuild(echos.macro.ViewBuilder.build())
#end
class View<Rest> extends ViewBase { }


@:noCompletion
class ViewBase {


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
            while (entities.length > 0) entities.pop();
            Workflow.views.remove(this);
        }
    }

    public function isActive() {
        for (v in Workflow.views) {
            if (v == this) return true;
        }
        return false;
    }

    public function size() {
        var i = 0;
        for (e in entities) {
            if (e != Entity.INVALID) i++;
        }
        return i;
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
            var index = entities.indexOf(id);
            if (index == -1) {
                entities.push(id);
                add(id);
            }
        }
    }

    @:allow(echos.Workflow) function removeIfMatch(id:Int) {
        var index = entities.indexOf(id);
        if (index > -1) {
            remove(id);
            entities[index] = Entity.INVALID;
        }
    }


    @:allow(echos.Workflow) function flush() {
        var i = 0;
        var length = entities.length;
        while (i < length) {
            if (entities[i] == Entity.INVALID) {
                entities.splice(i, 1);
                length--;
            } else {
                i++;
            }
        }
    }


    @:allow(echos.Workflow) function dispose() {
        deactivate();
    }


    public function toString():String return 'View';


}
