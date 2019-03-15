package echo;

/**
 * ...
 * @author https://github.com/deepcake
 */
#if !macro
@:autoBuild(echo.macro.SystemMacro.build())
#end
class System {


    // system types sequence
    @:noCompletion static var sequence = -1;


    @:noCompletion public var __id = ++sequence;


    @:allow(echo.Echo) function activate() {
        onactivate();
    }

    @:allow(echo.Echo) function deactivate() {
        ondeactivate();
    }


    public function onactivate() { }

    public function ondeactivate() { }

    public function update(dt:Float) { }


    public function toString():String return 'System';

}
