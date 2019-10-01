package echos.core;


#if echos_array_cc

abstract Storage<T>(Array<T>) {

    public inline function new() this = new Array<T>();

    public inline function add(id:Int, c:T) {
        this[id] = c;
    }

    public inline function get(id:Int):T {
        return this[id];
    }

    public inline function remove(id:Int) {
        this[id] = null;
    }

    public inline function exists(id:Int) {
        return this[id] != null;
    }

    public inline function reset() {
        #if (haxe_ver < 4) 
        this.splice(0, this.length);
        #else 
        this.resize(0);
        #end
    }

}

#else

@:forward(get, remove, exists)
abstract Storage<T>(haxe.ds.IntMap<T>) {

    public inline function new() this = new haxe.ds.IntMap<T>();

    public inline function add(id:Int, c:T) {
        this.set(id, c);
    }

    public function reset() {
        // for (k in this.keys()) this.remove(k); // python "dictionary changed size during iteration"
        var i = @:privateAccess echos.Workflow.nextId;
        while (--i > -1) this.remove(i); 
    }

}

#end
