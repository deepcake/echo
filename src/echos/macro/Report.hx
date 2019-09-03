package echos.macro;

#if macro
import echos.macro.MacroTools.*;
import echos.macro.ViewBuilder.*;
import echos.macro.ComponentBuilder.*;
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
        #if echos_report
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
