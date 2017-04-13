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
	
	
	static public function getComponentHolder(componentClsName:String):String {
		var componentCls = Context.toComplexType(Context.getType(componentClsName));
		
		var componentHolderClsName = 'GenericComponentHolder_' + componentCls.fullname().replace('.', '_');
		
		componentHoldersMap.set(componentCls.fullname(), componentHolderClsName);
		
		try {
			return Context.toComplexType(Context.getType(componentHolderClsName)).fullname();
		}catch (er:Dynamic) {
			
			trace('define $componentHolderClsName');
			
			var def = macro class $componentHolderClsName {
				static public var __ID:Int = $v{componentIndex++};
				static public var __MAP:Map<Int, $componentCls> = new Map();
			}
			
			trace(new Printer().printTypeDefinition(def));
			
			Context.defineType(def);
			
			return Context.toComplexType(Context.getType(componentHolderClsName)).fullname();
			
		}
	}
	
	static public function buildView() {
		var fields = Context.getBuildFields();
		var cls = Context.toComplexType(Context.getLocalType());
		
		
		var excluding = fields.filter(function(f) return hasMeta(f, COMPONENTMETA)).length == 0; // no component meta, so use direct-skip-way (all vars without @skip are included)
		
		var components = fields.map(function(field) {
			switch(field.kind) {
				case FVar(ct, _):
					if (field.access != null) {
						if (field.access.indexOf(APublic) == -1) return null; // only public
						if (field.access.indexOf(AStatic) > -1) return null; // only non-static
						
						var componentClsName = Context.toComplexType(ct.fullname().getType().follow()).fullname(); // follow
						
						if (excluding) {
							if (hasMeta(field, EXCLUDEMETA)) return null; else return { name: field.name, clsname: componentClsName };
						} else {
							if (hasMeta(field, COMPONENTMETA)) return { name: field.name, clsname: componentClsName }; else null;
						}
					}
				default:
			}
			return null;
		} ).filter(function(el) {
			return el != null;
		});
		
		
		if (fields.filter(function(f) return f.name == 'new').length == 0) fields.push(ffun([APublic], 'new', null, null, macro super()));
		
		var selectExprs = [];
		selectExprs.push(Context.parse('this.id = id', Context.currentPos()));
		selectExprs = selectExprs.concat(components.map(function(c) return Context.parse('this.${c.name} = ${getComponentHolder(c.clsname)}.__MAP.get(id)', Context.currentPos())));
		selectExprs.push(Context.parse('return this', Context.currentPos()));
		fields.push(ffun([APublic, AOverride], 'select', [arg('id', macro:Int)], cls, macro $b{selectExprs}));
		
		
		var iterBody = Context.parse('return new echo.View.ViewIterator(this)', Context.currentPos());
		fields.push(ffun([APublic, AInline], 'iterator', null, macro:echo.View.ViewIterator<$cls>, iterBody));
		
		
		var testBody = Context.parse('return ' + components.map(function(c) return '${getComponentHolder(c.clsname)}.__MAP.exists(id)').join(' && '), Context.currentPos());
		fields.push(ffun([APublic, AOverride], 'test', [arg('id', macro:Int)], macro:Bool, testBody));
		
		
		var testcompoBody = Context.parse('return mask.indexOf(c) > -1', Context.currentPos());
		fields.push(ffun([APublic, AOverride], 'testcomponent', [arg('c', macro:Int)], macro:Bool, testcompoBody));
		
		
		var maskBody = Context.parse('[' + components.map(function(c) return '${getComponentHolder(c.clsname)}.__ID').join(', ') + ']', Context.currentPos());
		fields.push(fvar([APublic], 'mask', null, maskBody));
		
		
		traceFields(cls.fullname(), fields);
		
		
		return fields;
	}
	
	
	static public function buildSystem() {
		var fields = Context.getBuildFields();
		var cls = Context.toComplexType(Context.getLocalType());
		
		
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
		
		
		if (fields.filter(function(f) return f.name == 'new').length == 0) fields.push(ffun([APublic], 'new', null, null, macro super()));
		
		
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
		switch (haxe.macro.Context.getLocalType()) {
			case TInst(_.get() => cls, [TAnonymous(_.get() => p)]):
				
				var components = p.fields.map(
					function(field:ClassField) return { name: field.name, cls: Context.toComplexType(field.type.follow()) }
				);
				
				var id = components.map(function(c) return c.cls.fullname()).join('_').replace('.', '_'); // TODO sort ?
				var clsname = 'GenericView_$id';
				
				try {
					return Context.getType(clsname);
				}catch (er:Dynamic) {
					
					trace('define $clsname');
					
					var def:TypeDefinition = macro class $clsname extends echo.View {
						public function new() super();
					}
					
					for (c in components) {
						def.fields.push(fvar([APublic], c.name, c.cls));
					}
					
					trace(new Printer().printTypeDefinition(def));
					
					Context.defineType(def);
					
					return Context.getType(clsname);
					
				}
				
			case x: throw 'Expected: TInst(_.get() => cls, [TAnonymous(_.get() => p)]); Actual: $x';
		}
	}
	
	#end
	
	
}