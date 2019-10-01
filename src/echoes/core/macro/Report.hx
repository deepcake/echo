package echoes.core.macro;

#if macro
import echoes.core.macro.MacroTools.*;
import echoes.core.macro.ViewBuilder.*;
import echoes.core.macro.ComponentBuilder.*;
import haxe.macro.Context;

using Lambda;

/**
 * ...
 * @author https://github.com/deepcake
 */
@:final
@:dce
class Report {


    static var reportRegistered = false;


    public static function gen() {
        #if echoes_report
        if (!reportRegistered) {
            Context.onGenerate(function(types) {
                function sortedlist(array:Array<String>) {
                    array.sort(compareStrings);
                    return array;
                }

                var ret = 'ECHO BUILD REPORT :';
                
                ret += '\n    COMPONENTS [${componentNames.length}] :';
                ret += '\n        ' + sortedlist(componentNames.mapi(function(i, k) return '$k #${ componentIds.get(k) }').array()).join('\n        ');
                ret += '\n    VIEWS [${viewNames.length}] :';
                ret += '\n        ' + sortedlist(viewNames.mapi(function(i, k) return '$k #${ viewIds.get(k) }').array()).join('\n        ');
                trace('\n$ret');

            });
            reportRegistered = true;
        }
        #end
    }


}
#end
