package echo;

/**
 * ...
 * @author https://github.com/wimcake
 */
#if !macro
@:autoBuild(echo.macro.MacroBuilder.autoBuildSystem())
#end
class System {


	var echo:Echo;


	@:allow(echo.Echo) function activate(echo:Echo) {
		this.echo = echo;
		onactivate();
	}

	@:allow(echo.Echo) function deactivate() {
		ondeactivate();
		this.echo = null;
	}


	public function onactivate() { }

	public function ondeactivate() { }

	public function update(dt:Float) { }

}
