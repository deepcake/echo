package echoes;

/**
 * View  
 * 
 * @author https://github.com/deepcake
 */
#if !macro
@:genericBuild(echoes.core.macro.ViewBuilder.build())
#end
class View<Rest> extends echoes.core.AbstractView { }
