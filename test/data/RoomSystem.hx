package data;

import echo.GenericView;
import echo.System;

/**
 * ...
 * @author octocake1
 */
class RoomSystem extends System {
	
	
	static public var LOG:Array<String> = [];
	
	
	var names = new GenericView<{ name:Name }>();
	var namesAndGreetings = new GenericView<{ name:Name, greeting:Greeting }>();
	
	
	override public function onactivate() {
		names.onAdd.add(function(id) {
			var val = echo.getComponent(id, Name).val;
			LOG.push('${val} enter the room');
		} );
		names.onRemove.add(function(id) {
			var val = echo.getComponent(id, Name).val;
			LOG.push('${val} leave the room');
		} );
	}
	
	override public function update(dt:Float) {
		for (ng in namesAndGreetings) {
			for (n in names) {
				if (ng.name != n.name) LOG.push('${ng.name.val} say ${ng.greeting.val} to ${n.name.val}');
			}
		}
	}
	
	override public function ondeactivate() {
		names.onAdd.removeAll();
		names.onRemove.removeAll();
	}
	
}