package echos.core;

@:allow(echos)
@:forward(head, tail, length, iterator)
abstract RestrictedLinkedList<T>(echos.utils.LinkedList<T>) {

    inline function new() this = new echos.utils.LinkedList<T>();

    inline function add(item:T) this.add(item);
    inline function pop() return this.pop();
    inline function remove(item:T) return this.remove(item);
    inline function exists(item:T) return this.exists(item);

}
