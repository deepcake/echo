package echo;
import haxe.macro.Expr;

/**
 * ...
 * @author octocake1
 */
@:forward(splice, length)
abstract Signal<T>(Array<T>) {
	
	
    public inline function new() this = [];
	

    public inline function add(listener:T) {
        this.push(listener);
    }
	
	public inline function has(listener:T):Bool {
		return this.indexOf(listener) > -1;
	}
	
	public inline function remove(listener:T) {
		var i = this.indexOf(listener);
		if (i > -1) this[i] = null;
	}
	
	public inline function removeAll() {
		for (i in 0...this.length) this[i] = null;
	}
	
	@:arrayAccess
	public inline function get(i:Int):T {
		return this[i];
	}

    macro public function dispatch(self:Expr, args:Array<Expr>) {
        return macro {
			var i = 0;
			var l = $self.length;
			while (i < l) {
				var listener = $self[i];
				if (listener != null) {
					listener($a{args});
					i++;
				}else {
					$self.splice(i, 1);
					l--;
				}
			}
		}
    }
}