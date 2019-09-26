package echos.core;

interface ISystem {

    function __activate__():Void;

    function __update__(dt:Float):Void;

    function __deactivate__():Void;

    #if echos_profiling
    function info():String;
    #end

}
