package echo.macro;

interface IComponentContainer<T> {
    function add(id:Int, value:T):Void;
    function get(id:Int):T;
    function remove(id:Int):Void;
    function exists(id:Int):Bool;
}
