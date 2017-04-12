package;

import data.Name;
import data.NameSystem;
import echo.Echo;
import haxe.unit.TestCase;

/**
 * ...
 * @author octocake1
 */
class TestSystem extends TestCase {	

	public function new() super();
	
	public function test1() {
		var ch = new Echo();
		var id = ch.id();
		var s = new NameSystem();
		
		ch.addSystem(s);
		assertEquals('', NameSystem.ADD_BOARD);
		assertEquals('', NameSystem.BOARD);
		assertEquals('', NameSystem.REM_BOARD);
		
		
		ch.setComponent(id, new Name('ABC'));
		assertEquals('ABC', NameSystem.ADD_BOARD);
		assertEquals('', NameSystem.BOARD);
		assertEquals('', NameSystem.REM_BOARD);
		
		
		ch.update(0);
		assertEquals('ABC', NameSystem.ADD_BOARD);
		assertEquals('ABC', NameSystem.BOARD);
		assertEquals('', NameSystem.REM_BOARD);
		
		
		ch.removeComponent(id, Name);
		assertEquals('ABC', NameSystem.REM_BOARD);
		assertEquals('ABC', NameSystem.BOARD);
		assertEquals('ABC', NameSystem.REM_BOARD);
		
		
		ch.removeSystem(s);
		ch.setComponent(ch.id(), new Name('XYZ'));
		assertEquals('ABC', NameSystem.ADD_BOARD);
		assertEquals('ABC', NameSystem.BOARD);
		assertEquals('ABC', NameSystem.REM_BOARD);
		
		
		ch.addSystem(s);
		assertEquals('ABCXYZ', NameSystem.ADD_BOARD);
		assertEquals('ABC', NameSystem.BOARD);
		assertEquals('ABC', NameSystem.REM_BOARD);
		
		
		ch.update(0);
		assertEquals('ABCXYZ', NameSystem.ADD_BOARD);
		assertEquals('ABCXYZ', NameSystem.BOARD);
		assertEquals('ABC', NameSystem.REM_BOARD);
	}
	
}