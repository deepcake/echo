package echos;

/**
 * View  
 * 
 *  A View can be defined manually in the following simple ways:  
 *  `View<T1, T2, TN>`  
 *  `View<T1->T2->TN>`  
 * 
 *  __Note__ that when Entity is removed from the View, it becomes `Entity.INVALID` until the next `Workflow.update()` call. 
 *  Therefore, in some cases, for example, when destroying Entity in a nested loop, you must check `entity.isValid()` to ensure that Entity is valid:  
 *  ```
 *  for (e1 in view.entities) {
 *    for (e2 in view.entities) {
 *      if (e1.isValid() && e2.isValid()) {
 *        if (collided(e1, e2)) {
 *          e1.destroy();
 *          e2.destroy();
 *        }
 *      }
 *    }
 *  }
 * ```
 *  It also means that `entities.length` may not show the actual number of entities. For actual count _right now right here_ you can use `size()` func.  
 *  
 * @author https://github.com/deepcake
 */
#if !macro
@:genericBuild(echos.core.macro.ViewBuilder.build())
#end
class View<Rest> extends echos.core.AbstractView { }
