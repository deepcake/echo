package echo.macro;
import echo.macro.Macro.*;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Printer;
import haxe.macro.Type.ClassField;

using haxe.macro.Context;
using echo.macro.Macro;
using StringTools;
using Lambda;

/**
 * ...
 * @author octocake1
 */
@:noCompletion
@:final
@:dce
class MacroBuilder {
	
	
	static var EXCLUDEMETA = ['skip'];
	static var COMPONENTMETA = ['component', 'c'];
	static var VIEWMETA = ['view', 'v'];
	
	
	static public var componentIndex:Int = 0;
	static public var componentHoldersMap:Map<String, String> = new Map();
	
	
	#if macro
	
	static function hasMeta(field:Field, metas:Array<String>) {
		for (m in field.meta) for (meta in metas) if (m.name == meta) return true;
		return false;
	}
	
	static function getClsNameID(clsname:String) {
		return clsname.replace('.', '_'); // TODO hash ?
	}
	
	
	static public function getComponentHolder(componentClsName:String):String {
		var componentCls = Context.getType(componentClsName).toComplexType();
		
		var componentHolderClsName = 'GenericComponentHolder_' + getClsNameID(componentCls.fullname());
		
		componentHoldersMap.set(componentCls.fullname(), componentHolderClsName);
		
		try {
			return Context.getType(componentHolderClsName).toComplexType().fullname();
		}catch (er:Dynamic) {
			
			var def = macro class $componentHolderClsName {
				static public var __ID:Int = $v{componentIndex++};
				static public var __MAP:Map<Int, $componentCls> = new Map();
			}
			
			
			traceTypeDefenition(def);
			
			Context.defineType(def);
			
			return Context.getType(componentHolderClsName).toComplexType().fullname();
			
		}
	}
	
	
	static public function buildSystem() {
		var fields = Context.getBuildFields();
		var cls = Context.getLocalType().toComplexType();
		
		
		var excluding = fields.filter(function(f) return hasMeta(f, VIEWMETA)).length == 0;
		
		var views = fields.map(function(field) {
			switch(field.kind) {
				case FVar(ct, _):
					
					if (field.access != null) if (field.access.indexOf(AStatic) > -1) return null; // only non-static
					
					for (m in field.meta) for (em in MacroBuilder.EXCLUDEMETA) if (m.name == em) return null; // skip by meta
					
					if (excluding) {
						if (hasMeta(field, EXCLUDEMETA)) return null; else return { name: field.name };
					} else {
						if (hasMeta(field, VIEWMETA)) return { name: field.name }; else null;
					}
					
				default:
			}
			return null;
		} ).filter(function(el) {
			return el != null;
		} );
		
		
		if (fields.filter(function(f) return f.name == 'new').length == 0) fields.push(ffun([APublic], 'new', null, null, null));
		
		
		var activateExprs = [];
		activateExprs.push(macro super.activate(echo));
		/*activateExprs = activateExprs.concat(views.map(function(el) {
			var cls = el.type;
			return macro $i{el.name} = new $cls();
		}));*/
		activateExprs = activateExprs.concat(views.map(function(el) return Context.parse('this.echo.addView(this.${el.name})', Context.currentPos())));
		fields.push(ffun([APublic, AOverride], 'activate', [arg('echo', macro:echo.Echo)], null, macro $b{activateExprs}));
		
		
		var deactivateExprs = [];
		deactivateExprs = deactivateExprs.concat(views.map(function(el) return Context.parse('this.echo.removeView(this.${el.name})', Context.currentPos())));
		deactivateExprs.push(macro super.deactivate());
		fields.push(ffun([APublic, AOverride], 'deactivate', null, null, macro $b{deactivateExprs}));
		
		
		traceFields(cls.fullname(), fields);
		
		
		return fields;
	}
	
	
	static public function genericView() {
		switch (Context.getLocalType()) {
			case TInst(_.get() => cls, [TAnonymous(_.get() => p)]):
				
				var components = p.fields.map(
					function(field:ClassField) return { name: field.name, cls: Context.toComplexType(field.type.follow()) }
				);
				
				var clsname = 'GenericView_' + getClsNameID(components.map(function(c) return c.cls.fullname()).join('_')); // TODO sort ?
				
				try {
					return Context.getType(clsname);
				}catch (er:Dynamic) {
					
					var def:TypeDefinition = macro class $clsname extends echo.View.ViewBase {
						public function new() {}
					}
					
					var iteratorTypePath = getIterator(components).tp();
					def.fields.push(ffun([APublic, AInline], 'iterator', null, null, macro return new $iteratorTypePath(this.entities)));
					
					var testBody = Context.parse('return ' + components.map(function(c) return '${getComponentHolder(c.cls.fullname())}.__MAP.exists(id)').join(' && '), Context.currentPos());
					def.fields.push(ffun([APublic, AOverride], 'test', [arg('id', macro:Int)], macro:Bool, testBody));
					
					// testcomponent
					// TODO opt use map
					// TODO opt use static
					def.fields.push(ffun([APublic, AOverride], 'testcomponent', [arg('c', macro:Int)], macro:Bool, macro return mask.indexOf(c) > -1));
					
					var maskBody = Context.parse('[' + components.map(function(c) return '${getComponentHolder(c.cls.fullname())}.__ID').join(', ') + ']', Context.currentPos());
					def.fields.push(fvar([APublic], 'mask', null, maskBody));
					
					
					traceTypeDefenition(def);
					
					Context.defineType(def);
					
					return Context.getType(clsname);
					
				}
				
			case x: throw 'Expected: TInst(_.get() => cls, [TAnonymous(_.get() => p)]); Actual: $x';
		}
	}
	
	
	static public function getViewData(components:Array<{ name:String, cls:ComplexType }>):ComplexType {
		var viewdataClsName = 'ViewData_' + getClsNameID(components.map(function(c) return c.cls.fullname()).join('_')); // TODO sort ?
		
		try {
			return Context.getType(viewdataClsName).toComplexType();
		}catch (er:Dynamic) {
			
			var def:TypeDefinition = macro class $viewdataClsName {
				inline public function new() { }
				public var id:Int;
			}
			
			for (c in components) def.fields.push(fvar([APublic], c.name, c.cls));
			
			
			traceTypeDefenition(def);
			
			Context.defineType(def);
			
			return Context.getType(viewdataClsName).toComplexType();
			
		}
	}
	
	
	static public function getIterator(components:Array<{ name:String, cls:ComplexType }>):ComplexType {
		var viewdataCls = getViewData(components);
		var iteratorClsName = 'ViewIterator_' + getClsNameID(viewdataCls.fullname());
		
		try {
			return Context.getType(iteratorClsName).toComplexType();
		}catch (er:Dynamic) {
			
			var viewdataTypePath = viewdataCls.tp();
			
			var def = macro class $iteratorClsName {
				var i:Int;
				var list:Array<Int>;
				var vd:$viewdataCls;
				public inline function new(list:Array<Int>) {
					this.i = -1;
					this.list = list;
					this.vd = new $viewdataTypePath(); // TODO opt js ( Object ? )
				}
				public inline function hasNext():Bool return ++i < list.length;
				//public inline function next():$dataViewCls return vd;
			}
			
			var nextExprs = [];
			nextExprs.push(macro this.vd.id = this.list[i]);
			components.iter(function(c) nextExprs.push(Context.parse('this.vd.${c.name} = ${getComponentHolder(c.cls.fullname())}.__MAP.get(this.vd.id)', Context.currentPos())));
			nextExprs.push(macro return this.vd);
			def.fields.push(ffun([APublic, AInline], 'next', null, viewdataCls, macro $b{nextExprs}));
			
			
			traceTypeDefenition(def);
			
			Context.defineType(def);
			
			return Context.getType(iteratorClsName).toComplexType();
			
		}
	}
	
	#end
	
	
}