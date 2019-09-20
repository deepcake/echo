package echos.utils;

/**
 * ...
 * @author https://github.com/deepcake
 */
@:generic
class LinkedList<T> {


    public var head(default, null):LinkedNode<T> = null;
    public var tail(default, null):LinkedNode<T> = null;

    public var length(default, null) = 0;


    public function new() { }


    public inline function iterator():LinkedListIterator<T> {
        return new LinkedListIterator<T>(head);
    }

    public function add(value:T) {
        var node = new LinkedNode<T>(value);
        if (head == null) {
            head = node;
        } else {
            tail.next = node;
        }
        tail = node;
        length++;
    }

    public function pop():Null<T> {
        if (head != null) {
            var value = head.value;
            head = head.next;
            if (head == null) {
                tail = null;
            }
            length--;
            return value;
        } else {
            return null;
        }
    }

    public function remove(value:T):Bool {
        var prev:LinkedNode<T> = null;
        var node = head;
        while (node != null) {
            if (node.value == value) {
                if (prev == null) {
                    head = node.next;
                } else {
                    prev.next = node.next;
                }
                if (node == tail) {
                    tail = prev;
                }
                length--;
                return true;
            }
            prev = node;
            node = node.next;
        }
        return false;
    }

    public function exists(value:T):Bool {
        var node = head;
        while (node != null) {
            if (node.value == value) return true;
            node = node.next;
        }
        return false;
    }

}

@:allow(echos.utils.LinkedList)
@:generic
class LinkedNode<T> {

    public var next:LinkedNode<T>;

    public var value(default, null):T;

    function new(value:T) {
        this.value = value;
    }

}

@:allow(echos.utils.LinkedList)
@:generic
class LinkedListIterator<T> {

    var node:LinkedNode<T>;

    inline function new(node:LinkedNode<T>) {
        this.node = node;
    }

    public inline function hasNext():Bool {
        return node != null;
    }

    public inline function next():T {
        var value = node.value;
        node = node.next;
        return value;
    }

}
