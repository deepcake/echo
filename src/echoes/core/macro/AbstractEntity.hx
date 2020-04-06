package echoes.core.macro;

import haxe.macro.ComplexTypeTools;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Printer;
import haxe.macro.Type;
import haxe.macro.TypeTools;

#if macro
using echoes.core.macro.ComponentBuilder;
using echoes.core.macro.EntityTools;
using echoes.core.macro.MacroTools;
using haxe.EnumTools;
using haxe.macro.ExprTools;
#else
import echoes.Entity;
#end

/**
 * Any abstract extending Entity can be used to access components
 * as if they were instance variables. For example, this:
 * 
 * typedef Color = Int;
 * abstract ColorfulEntity(Entity) {
 *     public var color:Color;
 * }
 * 
 * Enables this:
 * 
 * var redBall = new ColorfulEntity();
 * redBall.color = 0xFF0000;
 * redBall.add(new SphericalHitbox(5));
 * redBall.add(new ElasticCollision(1));
 * trace(StringTools.hex(redBall.get(Color))); //FF0000
 */
class AbstractEntity {
	#if !macro
	
	public static function build():Array<Field> {
		return [];
	}
	
	#else
	
	private static var defaultFields:Array<Field> = [
		{
			access:[AInline],
			kind: FFun({
				args: [],
				expr: macro return cast this,
				ret: macro:Int
			}),
			name: "toInt",
			meta: [{name: ":to", pos: (macro null).pos}],
			pos: (macro null).pos
		},
		{
			access:[AInline],
			kind: FFun({
				args: [],
				expr: macro return cast this,
				ret: macro:echoes.Entity
			}),
			name: "toEntity",
			meta: [{name: ":to", pos: (macro null).pos}],
			pos: (macro null).pos
		}
	];
	
	private static var fieldName:String = null;
	private static var getField:Expr = null;
	
	public static function build():Array<Field> {
		var fields:Array<Field> = Context.getBuildFields();
		
		switch(Context.getLocalType()) {
			case TInst(_.get().kind => KAbstractImpl(_.get().type => parent), _):
				var lastName:String = null;
				while(parent != null) {
					switch(parent) {
						case TAbstract(_.get() => parentAbstract, _):
							if(parentAbstract.module == "StdTypes") {
								return fields;
							} else if(parentAbstract.name == lastName) {
								return fields;
							} else if(parentAbstract.name == "Entity"
								&& parentAbstract.pack.length == 1 && parentAbstract.pack[0] == "echoes") {
								parent = null;
								break;
							} else {
								lastName = parentAbstract.name;
								parent = parentAbstract.type;
							}
						default:
							return fields;
					}
				}
			default:
				return fields;
		}
		
		var blueprint:BlueprintData = BlueprintData.current();
		
		if(!blueprint.type.meta.has(":forward")) {
			blueprint.type.meta.add(":forward", [], blueprint.type.pos);
		}
		
		var reservedFields:Array<String> = [];
		var newFields:Array<Field> = defaultFields.copy();
		var fieldNames:Array<String> = [];
		
		var i:Int = fields.length;
		while(--i >= 0) {
			var field:Field = fields[i];
			var remove:Bool = false;
			
			if(reservedFields.indexOf(field.name) >= 0) {
				Context.warning('${field.name} is reserved and will be overwritten', field.pos);
				fields.splice(i, 1);
			} else {
				switch(field.kind) {
					case FVar(t, e):
						//Static variables should be left alone.
						if(field.access.indexOf(AStatic) >= 0) {
							continue;
						}
						
						//Turn instance variables into properties.
						field.kind = FProp("get", "set", t, null);
						
						for(variable in blueprint.variables) {
							if(variable.name == field.name) {
								makeAccessors(variable, newFields);
								break;
							}
						}
					case FProp(get, set, t, e):
						if(field.access.indexOf(AStatic) < 0) {
							throw "Assertion failed: the Haxe compiler no longer makes properties static";
						}
						
						//Properties can mostly be left as-is, as long as they don't have an underlying variable.
						if(get == "null" || get == "never") {
							get = "never";
						} else {
							get = "get";
						}
						if(set == "null" || set == "never") {
							set = "never";
						} else {
							set = "set";
						}
						
						field.kind = FProp(get, set, t, null);
						
						for(variable in blueprint.variables) {
							if(variable.name == field.name) {
								makeAccessors(variable, get == "get", set == "set", newFields);
								break;
							}
						}
					case FFun(func):
						if(func.expr == null) {
							Context.warning("Missing function body", field.pos);
							remove = true;
							break;
						}
						
						//Most functions can be left as-is. They will automatically use any necessary getters and setters.
						//However, the getters and setters themselves need to access their values differently.
						else if(StringTools.startsWith(field.name, "get_") || StringTools.startsWith(field.name, "set_")) {
							var returnType:ComplexType = func.ret;
							if(returnType == null) {
								try {
									returnType = TypeTools.toComplexType(Context.typeof(func.expr).followMono());
								} catch(e:Dynamic) {}
								
								if(returnType == null) {
									Context.error("Explicit return type required for this function", field.pos);
									remove = true;
									break;
								}
							}
							
							fieldName = field.name.substr(4);
							getField = (macro this).get(returnType);
							func.expr = func.expr.map(replaceVariableAccess);
						}
				}
				
				//Remove @:isVar from anything and everything.
				if(field.meta != null) {
					var m:Int = field.meta.length;
					while(--m >= 0) {
						if(field.meta[m].name == ":isVar") {
							Context.warning("Instance variables are not allowed", field.meta[m].pos);
							field.meta.splice(i, 1);
						}
					}
				}
			}
			
			if(remove) {
				fields.splice(i, 1);
			} else {
				fieldNames.push(field.name);
			}
		}
		
		//Add conversion functions.
		var lastType:Type = blueprint.type.type;
		var parentBlueprint:BlueprintData = blueprint.parentData;
		while(parentBlueprint != null) {
			newFields.push({
				access:[AInline],
				kind: FFun({
					args: [],
					expr: macro return cast this,
					ret: TypeTools.toComplexType(lastType)
				}),
				name: "to" + parentBlueprint.type.name,
				meta: [{name: ":to", pos: parentBlueprint.type.pos}],
				pos: parentBlueprint.type.pos
			});
			
			//Instead of trying to make a complex type based on the abstract
			//declaration, record the type used by the child abstract. This
			//ensures type parameters are included. Not that type parameters
			//are recommended.
			lastType = parentBlueprint.type.type;
			
			parentBlueprint = parentBlueprint.parentData;
		}
		
		//Make sure not to add any redundant fields.
		for(newField in newFields) {
			if(fieldNames.indexOf(newField.name) >= 0) {
				//Private fields can simply be renamed.
				if(newField.access.indexOf(APublic) < 0) {
					var i:Int = 0;
					while(++i < 100) {
						if(fieldNames.indexOf(newField.name + i) < 0) {
							newField.name += i;
							break;
						}
					}
					
					if(fieldNames.indexOf(newField.name) >= 0) {
						continue;
					}
				} else {
					//Public fields must be skipped.
					continue;
				}
			}
			
			fields.push(newField);
			fieldNames.push(newField.name);
		}
		
		//TODO: convert to Entity, Int, and any underlying types, but only
		//if "to Entity" etc. isn't already there.
		
		return fields;
	}
	
	private static function dotAccessExpr(pack:Array<String>, name:String):Expr {
		var packWithName:Array<String> = pack.copy();
		packWithName.push(name);
		return macro $p{packWithName};
	}
	
	private static function complexTypeExpr(complexType:ComplexType, pos:Position):Expr {
		switch(complexType) {
			case TPath({pack: pack, name: name, params: params}):
				if(params != null && params.length > 0) {
					Context.error("Parameters currently aren't supported. Use a typedef to get around this.", pos);
				}
				if(pack != null && pack.length > 0) {
					return dotAccessExpr(pack, name);
				} else {
					return macro $i{name};
				}
			default:
				return null;
		}
	}
	
	private static function replaceVariableAccess(expr:Expr):Expr {
		switch(expr.expr) {
			case EReturn({expr: EBinop(OpAssign, {expr: EConst(CIdent(c))}, e)}) if(c == fieldName):
				//Avoid duplicating $e; it could include a costly function call.
				return @:pos(expr.pos) macro return { this.add($e); $getField; };
			case EBinop(OpAssign, {expr: EConst(CIdent(c))}, e) if(c == fieldName):
				return @:pos(expr.pos) macro this.add($e);
			case EConst(CIdent(c)) if(c == fieldName):
				return getField;
			default:
				return expr.map(replaceVariableAccess);
		}
	}
	
	private static function makeAccessors(fieldData:BlueprintVariable, ?getter:Bool = true, ?setter:Bool = true, array:Array<Field>):Void {
		if(getter) {
			var get:Expr = (macro this).get(fieldData.type);
			array.push({
				access: [AInline],
				kind: FFun({
					args: [],
					expr: @:pos(fieldData.pos) macro return $get,
					ret: fieldData.type
				}),
				name: "get_" + fieldData.name,
				pos: fieldData.pos
			});
		}
		
		if(setter) {
			var typeExpr:Expr = complexTypeExpr(fieldData.type, fieldData.pos);
			array.push({
				access: [AInline],
				kind: FFun({
					args: [{name: "value", type: fieldData.type}],
					expr: @:pos(fieldData.pos) macro {
						if(value == null) {
							this.remove($typeExpr);
						} else {
							this.add(value);
						}
						return value;
					},
					ret: fieldData.type
				}),
				name: "set_" + fieldData.name,
				pos: fieldData.pos
			});
		}
	}
	
	#end
}

class BlueprintData {
	#if macro
	
	public static var allData:Array<BlueprintData> = [];
	
	private static function typePathToString(path:TypePath):String {
		var result:String;
		
		if(path.pack.length > 0) {
			result = path.pack.join(".") + "." + path.name;
		} else {
			result = path.name;
		}
		
		if(path.sub != null) {
			result += "." + path.sub;
		}
		
		return result;
	}
	
	private static function baseTypeToString(type:BaseType):String {
		var result:String;
		
		result = type.module;
		
		if(!StringTools.endsWith(type.module, "." + type.name)) {
			result += "." + type.name;
		}
		
		return result;
	}
	
	public static inline function byType(type:BaseType):BlueprintData {
		return byQualifiedName(baseTypeToString(type));
	}
	
	public static function byQualifiedName(qualifiedName:String):BlueprintData {
		for(data in allData) {
			if(data.qualifiedName == qualifiedName) {
				return data;
			}
		}
		
		return new BlueprintData(Context.getType(qualifiedName));
	}
	
	public static function current():Null<BlueprintData> {
		var type:Type = Context.getLocalType();
		switch(type) {
			case TInst(_.get().kind => KAbstractImpl(_.get() => abstractType), _):
				var qualifiedName:String = baseTypeToString(abstractType);
				var data:BlueprintData = null;
				for(d in allData) {
					if(d.qualifiedName == qualifiedName) {
						data = d;
						break;
					}
				}
				
				if(data == null) {
					data = new BlueprintData(type);
				}
				
				if(data.variables.length == 0) {
					data.init(Context.getBuildFields());
				}
				
				return data;
			default:
				return null;
		}
	}
	
	public var type:AbstractType;
	public var qualifiedName:String;
	
	/**
	 * May not be defined unless you accessed this via current().
	 */
	public var variables:Array<BlueprintVariable> = [];
	
	/**
	 * Null indicates that this inherits directly from Entity.
	 */
	public var parentData:Null<BlueprintData>;
	
	private function new(fromType:Type) {
		switch(fromType) {
			case TInst(_.get().kind => KAbstractImpl(_.get() => abstractType), _)
				| TAbstract(_.get() => abstractType, _):
				type = abstractType;
			default:
				throw fromType + " is not abstract";
		}
		
		qualifiedName = baseTypeToString(type);
		
		allData.push(this);
		
		switch(TypeTools.toComplexType(type.type.followMono())) {
			case TPath({pack: ["echoes"], name: "Entity"}):
				parentData = null;
			case TPath(path):
				parentData = byQualifiedName(typePathToString(path));
				if(parentData == this) {
					Context.error(type.name + " should not be its own parent", type.pos);
					parentData = null;
				}
			case unrecognized:
				Context.error("Unable to parse underlying type: " + unrecognized, type.pos);
		}
	}
	
	private function init(fields:Array<Field>):Void {
		var printer:Printer = new Printer();
		
		for(field in fields) {
			//Skip static variables, but not properties.
			switch(field.kind) {
				case FVar(_, _):
					if(field.access != null && field.access.indexOf(AStatic) >= 0) {
						continue;
					}
				default:
			}
			
			switch(field.kind) {
				case FVar(type, expr), FProp(_, _, type, expr):
					var coerce:Bool;
					
					if(type == null) {
						type = TypeTools.toComplexType(Context.typeof(expr).followMono());
						
						switch(expr.expr) {
							case ENew(_, _):
								coerce = true;
							case null:
								Context.error("Please specify a type", field.pos);
							default:
								coerce = false;
						}
					} else {
						//Convert back and forth to get a fully-qualified type.
						type = TypeTools.toComplexType(ComplexTypeTools.toType(type).followMono());
						coerce = true;
					}
					
					var printedType:String = printer.printComplexType(type);
					
					if(printedType == "Int" || printedType == "StdTypes.Int") {
						Context.error("Int is reserved for entity ids - consider using a typedef or abstract", field.pos);
					} else if(printedType == "Float" || printedType == "StdTypes.Float") {
						Context.error("Float is reserved for lengths of time - consider using a typedef or abstract", field.pos);
					}
					
					for(variable in variables) {
						if(printedType == variable.printedType) {
							Context.error("Too many " + printedType + " components", field.pos);
						}
					}
					
					var overwrite:Bool = field.access.indexOf(AOverride) >= 0;
					
					variables.push({
						type:type,
						printedType:printedType,
						name:field.name,
						expr:expr,
						overwrite:overwrite,
						coerce:coerce,
						pos:field.pos
					});
				default:
			}
		}
	}
	
	#end
}

typedef BlueprintVariable = {
	type:ComplexType,
	printedType:String,
	name:String,
	expr:Expr,
	overwrite:Bool,
	coerce:Bool,
	pos:Position
	//, requestedData:Array<RequestedData>
};
