package echoes;

/**
 * System  
 * 
 * You must extend this class to make your own system.  
 * 
 * Functions with `@update` (or `@up`, or `@u`) meta are called for each entity that contains all the defined components.  
 * So, a function like: 
 * ```
 *   @u function f(a:A, b:B, entity:Entity) { }
 * ```
 * does a two things: 
 * - Defines and initializes a `View<A, B>` (if the `View<A, B>` has not been previously defined)  
 * - Creates a loop in the system update method  
 * ```
 *   for (entity in viewOfAB.entities) {  
 *     f(entity.get(A), entity.get(B), entity);  
 *   }  
 * ```
 * 
 * Functions with `@added`, `@ad`, `@a` meta become callbacks that will be called on each entity to be assembled by the view.  
 * Functions with `@removed`, `@rm`, `@r` does the same but when entity is removed.  
 * 
 * You can define the `View` manually (no initialization required)  
 * 
 * @author https://github.com/deepcake
 */
#if !macro
@:autoBuild(echoes.core.macro.SystemBuilder.build())
#end
class System implements echoes.core.ISystem {


    #if echoes_profiling
    var __updateTime__ = .0;
    #end


    var activated = false;


    @:noCompletion public function __activate__() {
        onactivate();
    }

    @:noCompletion public function __deactivate__() {
        ondeactivate();
    }

    @:noCompletion public function __update__(dt:Float) {
        // macro
    }

    public function isActive():Bool {
        return activated;
    }

    public function info(indent = '    ', level = 0):String {
        var span = StringTools.rpad('', indent, indent.length * level);

        #if echoes_profiling
        return '$span$this : $__updateTime__ ms';
        #else
        return '$span$this';
        #end
    }

    /**
     * Calls when system is added to the workflow
     */
    public function onactivate() { }

    /**
     * Calls when system is removed from the workflow
     */
    public function ondeactivate() { }


    public function toString():String return 'System';


}
