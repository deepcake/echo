package echos;

/**
 * System  
 * @update, @up, @u - calls on every appropriated entity  
 * @added, @ad, @a - added callback  
 * @removed, @rm, @r - removed callback  
 *  
 * @author https://github.com/deepcake
 */
#if !macro
@:autoBuild(echos.macro.SystemMacro.build())
#end
class System {


    // system types sequence
    @:noCompletion static var sequence = -1;


    @:noCompletion public var __id = ++sequence;


    @:allow(echos.Workflow) function activate() {
        onactivate();
    }

    @:allow(echos.Workflow) function deactivate() {
        ondeactivate();
    }

    /**
    * Calls when system is added to the workflow
     */
    public function onactivate() { }

    /**
    * Calls when system is removed from the workflow
     */
    public function ondeactivate() { }

    /**
    * Calls on every `Workflow.update(dt)` call
    * @param dt deltatime
     */
    public function update(dt:Float) { }


    public function toString():String return 'System';

}
