package echos;

/**
 * ...
 * @author https://github.com/deepcake
 */
#if !macro
@:autoBuild(echos.macro.SystemMacro.build())
#end
class System {


    // system types sequence
    @:noCompletion static var sequence = -1;


    @:noCompletion public var __id = ++sequence;


    @:allow(echos.Echo) function activate() {
        onactivate();
    }

    @:allow(echos.Echo) function deactivate() {
        ondeactivate();
    }


    public function onactivate() { }

    public function ondeactivate() { }

    public function update(dt:Float) { }


    public function toString():String return 'System';

}
