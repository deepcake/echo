package echoes.utils;

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

    /**
     * Sorts this LinkedList according to the comparison function `f`, where `f(x,y)` returns 0 if `x == y`, a positive Int if `x > y` and a negative Int if `x < y`  
     * 
     * __Based on `haxe.ds.ListSort.sortSingleLinked()` function with minor changes__.
     */
    public function sort(f:T->T->Int) {
        var insize = 1, nmerges, psize = 0, qsize = 0;
        var p, q, e:LinkedNode<T>;
        while (true) {
            p = head;
            head = null;
            tail = null;
            nmerges = 0;
            while (p != null) {
                nmerges++;
                q = p;
                psize = 0;
                for (i in 0...insize) {
                    psize++;
                    q = q.next;
                    if (q == null) {
                        break;
                    }
                }
                qsize = insize;
                while (psize > 0 || (qsize > 0 && q != null)) {
                    if (psize == 0) {
                        e = q;
                        q = q.next;
                        qsize--;
                    } else if (qsize == 0 || q == null || f(p.value, q.value) <= 0) {
                        e = p;
                        p = p.next;
                        psize--;
                    } else {
                        e = q;
                        q = q.next;
                        qsize--;
                    }
                    if (tail != null) {
                        tail.next = e;
                    } else {
                        head = e;
                    }
                    tail = e;
                }
                p = q;
            }
            tail.next = null;
            if (nmerges <= 1) {
                break;
            }
            insize *= 2;
        }
    }


}

@:allow(echoes.utils.LinkedList)
@:generic
class LinkedNode<T> {

    public var next:LinkedNode<T>;

    public var value(default, null):T;

    function new(value:T) {
        this.value = value;
    }

}

@:allow(echoes.utils.LinkedList)
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
