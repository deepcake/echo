package echoes.utils;
import echoes.utils.LinkedList.LinkedListIterator;
#if macro
import haxe.macro.Expr;
#end

/**
 * ...
 * @author https://github.com/deepcake
 */
@:forward(length)
abstract Signal<T>(LinkedList<T>) {


    public inline function new() this = new LinkedList<T>();


    public inline function add(listener:T) {
        this.add(listener);
    }

    public inline function has(listener:T):Bool {
        return this.exists(listener);
    }

    public inline function remove(listener:T) {
        this.remove(listener);
    }

    public inline function removeAll() {
        while (this.length > 0) this.pop();
    }

    public inline function size() {
        return this.length;
    }


    public inline function iterator():LinkedListIterator<T> {
        return this.iterator();
    }


    macro public function dispatch(self:Expr, args:Array<Expr>) {
        return macro {
            for (listener in $self) {
                listener($a{args});
            }
        }
    }


}
