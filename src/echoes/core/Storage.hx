package echoes.core;

#if echoes_vector_container

class Storage<T> {


    var size:Int;
    var h:haxe.ds.Vector<T>;


    public function new() {
        init(64);
    }


    public function add(id:Int, c:T) {
        if (id >= size) {
            growTo(id);
        }
        h[id] = c;
    }

    public function get(id:Int):T {
        return id < size ? h[id] : null;
    }

    public function remove(id:Int) {
        if (id < size) {
            h[id] = null;
        }
    }

    public function exists(id:Int) {
        return id < size ? h[id] != null : false;
    }

    public function reset() {
        init(64);
    }


    inline function init(size:Int) {
        this.size = size;
        this.h = new haxe.ds.Vector<T>(size);
    }

    inline function growTo(id:Int) {
        var nsize = size;

        while (id >= nsize) {
            nsize *= 2;
        }

        var nh = new haxe.ds.Vector<T>(nsize);

        haxe.ds.Vector.blit(h, 0, nh, 0, size);

        this.h = nh;
        this.size = nsize;
    }


}

#elseif echoes_array_container

abstract Storage<T>(Array<T>) {


    public inline function new() {
        this = new Array<T>();
    }


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
        this.splice(0, this.length);
    }


}

#else

@:forward(get, remove, exists)
abstract Storage<T>(haxe.ds.IntMap<T>) {


    public inline function new() {
        this = new haxe.ds.IntMap<T>();
    }


    public inline function add(id:Int, c:T) {
        this.set(id, c);
    }

    public function reset() {
        // for (k in this.keys()) this.remove(k); // python "dictionary changed size during iteration"
        var i = @:privateAccess echoes.Workflow.nextId;
        while (--i > -1) this.remove(i); 
    }


}

#end
