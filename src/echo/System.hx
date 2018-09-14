package echo;

/**
 * ...
 * @author https://github.com/deepcake
 */
#if !macro
@:autoBuild(echo.macro.SystemMacro.build())
#end
class System {


    var echo:Echo;

    @:noCompletion public var __id = -1;


    @:noCompletion public function activate(echo:Echo) {
        this.echo = echo;
        onactivate();
    }

    @:noCompletion public function deactivate() {
        ondeactivate();
        this.echo = null;
    }


    public function onactivate() { }

    public function ondeactivate() { }

    public function update(dt:Float) { }


    public function toString():String return 'System';

}
