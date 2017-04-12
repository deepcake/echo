package data;

import echo.GenericView;
import echo.System;

/**
 * ...
 * @author octocake1
 */
class NameSystem extends System {
	
	
	@skip static public var ADD_BOARD = '';
	@skip static public var BOARD = '';
	@skip static public var REM_BOARD = '';
	
	
	var names = new GenericView<{ name:Name }>();
	
	
	override public function onactivate() {
		names.onAdd.add(function(_) {
			ADD_BOARD += names.name.val;
		} );
		names.onRemove.add(function(_) {
			REM_BOARD += names.name.val;
		} );
	}
	
	override public function update(dt:Float) {
		for (e in names) {
			BOARD += e.name.val;
		}
	}
	
	override public function ondeactivate() {
		names.onAdd.removeAll();
		names.onRemove.removeAll();
	}
	
}