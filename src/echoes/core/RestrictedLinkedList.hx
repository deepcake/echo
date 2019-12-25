package echoes.core;

@:allow(echoes)
@:forward(head, tail, length, iterator, sort)
abstract RestrictedLinkedList<T>(echoes.utils.LinkedList<T>) to echoes.utils.LinkedList<T> {

    inline function new() this = new echoes.utils.LinkedList<T>();

    inline function add(item:T) this.add(item);
    inline function pop() return this.pop();
    inline function remove(item:T) return this.remove(item);
    inline function exists(item:T) return this.exists(item);

}
