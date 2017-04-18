package;

import echo.Echo;
import echo.System;
import echo.View;
import js.Browser;
import js.html.Element;

/**
 * ...
 * @author octocake1
 */
class Example {
	
	static var echo:Echo;
	static var w = 60;
	static var h = 30;
	
	static function main() {
		var canvas = Browser.document.createElement('code'); // monospace text
		canvas.style.color = '#007F0E';
		
		Browser.document.body.appendChild(canvas);
		
		
		echo = new Echo();
		echo.addSystem(new Movement(w, h));
		echo.addSystem(new Render(w, h, canvas));
		
		
		for (i in 0...1000) createGrass(Std.random(w), Std.random(h));
		for (i in 0...100) createTree(Std.random(w), Std.random(h));
		for (i in 0...10) {
			var d = Math.random() * Math.PI * 2;
			createRabbit(Std.random(w), Std.random(h), Math.cos(d) * 2, Math.sin(d) * 2);
		}
		
		var d = Math.random() * Math.PI * 2;
		createTiger(Std.random(w), Std.random(h), Math.cos(d) * 6, Math.sin(d) * 6);
		
		
		Browser.window.setInterval(function() echo.update(.100), 100);
	}
	
	
	static function createGrass(x:Float, y:Float) {
		echo.setComponent(echo.id(), 
			new Position(x, y), 
			new Sprite('&#x1F33E;'));
	}
	
	static function createTree(x:Float, y:Float) {
		echo.setComponent(echo.id(), 
			new Position(x, y), 
			new Sprite('&#x1F333;')); //1F332
	}
	
	static function createDynamic(x:Float, y:Float, vx:Float, vy:Float):Int {
		var id = echo.id();
		var pos = new Position(x, y);
		var vel = new Velocity(vx, vy);
		echo.setComponent(id, pos, vel);
		return id;
	}
	
	static function createRabbit(x:Float, y:Float, vx:Float, vy:Float) {
		echo.setComponent(createDynamic(x, y, vx, vy), new Sprite('&#x1F407;'));
	}
	
	static function createTiger(x:Float, y:Float, vx:Float, vy:Float) {
		echo.setComponent(createDynamic(x, y, vx, vy), new Sprite('&#x1F405;'));
	}
	
}


// Utils

class Vec2 {
	public var x:Float;
	public var y:Float;
	public function new(?x:Float, ?y:Float) {
		this.x = x != null ? x : .0;
		this.y = y != null ? y : .0;
	}
}


// Components

@:forward(x, y)
abstract Velocity(Vec2) { // abstracts can be used to create different ComponentClasses from the same BaseClass without overhead
	inline public function new(?x:Float, ?y:Float) this = new Vec2(x, y);
}

@:forward(x, y)
abstract Position(Vec2) {
	inline public function new(?x:Float, ?y:Float) this = new Vec2(x, y);
}

class Sprite {
	// in this case it just a char
	public var value:String;
	public function new(value:String) {
		this.value = value;
	}
}


// Systems

class Movement extends System {
	@skip var w:Float;
	@skip var h:Float;
	var bodies = new View<{ pos:Position, vel:Velocity }>();
	public function new(w:Float, h:Float) {
		this.w = w;
		this.h = h;
	}
	override public function update(dt:Float) {
		for (body in bodies) {
			body.pos.x += body.vel.x * dt;
			body.pos.y += body.vel.y * dt;
			if (body.pos.x >= w) body.pos.x -= w;
			if (body.pos.x < 0) body.pos.x += w;
			if (body.pos.y >= h) body.pos.y -= h;
			if (body.pos.y < 0) body.pos.y += h;
		}
	}
}

class Render extends System {
	var canvas:Element;
	var world:Array<Array<Element>>;
	var w = 0;
	var h = 0;
	@view var visuals = new View<{ pos:Position, spr:Sprite }>();
	public function new(w:Int, h:Int, canvas:Element) {
		this.canvas = canvas;
		this.w = w;
		this.h = h;
		world = [];
		for (y in 0...h) {
			world[y] = [];
			for (x in 0...w) {
				world[y][x] = Browser.document.createSpanElement();
				canvas.appendChild(world[y][x]);
			}
			canvas.appendChild(Browser.document.createBRElement());
		}
	}
	override public function update(dt:Float) {
		for (y in 0...h) {
			for (x in 0...w) {
				world[y][x].innerHTML = '&#x1F33F;';
			}
		}
		for (v in visuals) {
			world[Std.int(v.pos.y)][Std.int(v.pos.x)].innerHTML = v.spr.value;
		}
	}
}
