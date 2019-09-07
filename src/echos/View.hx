package echos;

/**
 * View  
 * 
 *  A View can be defined manually:  
 *  `View<T1, T2, TN>`  
 *  
 * @author https://github.com/deepcake
 */
#if !macro
@:genericBuild(echos.core.macro.ViewBuilder.build())
#end
class View<Rest> extends echos.core.AbstractView { }
