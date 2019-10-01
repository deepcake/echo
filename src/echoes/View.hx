package echoes;

/**
 * View  
 * 
 *  A View can be defined manually:  
 *  `View<T1, T2, TN>`  
 *  
 * @author https://github.com/deepcake
 */
#if !macro
@:genericBuild(echoes.core.macro.ViewBuilder.build())
#end
class View<Rest> extends echoes.core.AbstractView { }
