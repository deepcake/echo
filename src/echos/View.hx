package echos;

/**
 * View  
 * 
 *  A View can be defined manually in the following simple ways:  
 *  View<T1, T2, TN>  
 *  View<T1->T2->TN>  
 * 
 *  __Note__ that when Entity is removed from the View, it becomes `Entity.INVALID` until the next `Workflow.update()` call. 
 *  So be careful when iterating without using `iter()`, and if so, be sure to check `entity.isValid()`. 
 *  It also means that `entities.length` may not show the actual number of entities. For actual count _right now right here_ you can use `size()` func.  
 *  
 * @author https://github.com/deepcake
 */
#if !macro
@:genericBuild(echos.core.macro.ViewBuilder.build())
#end
class View<Rest> extends echos.core.AbstractView { }
