package;

import echo.Echo;
import echo.System;
import echo.View;
import js.Browser;
import js.html.Element;

/**
 * ...
 * @author https://github.com/wimcake
 */
class Example {

	static var echo:Echo;
	static var w = 80;
	static var h = 20;

	static function main() {
		var canvas = Browser.document.createElement('code'); // monospace text
		var stat = Browser.document.createPreElement();
		Browser.document.body.appendChild(canvas);
		Browser.document.body.appendChild(Browser.document.createBRElement());
		Browser.document.body.appendChild(stat);


		echo = new Echo();
		echo.addSystem(new Movement(w, h));
		echo.addSystem(new Render(w, h, canvas));

		// fill world by plants
		for (y in 0...h) for (x in 0...w) {
			if (Math.random() > .5) {
				grass(x, y); 
			} else {
				if (Math.random() > .2) tree(x, y); else flower(x, y);
			}
		}

		// some rabbits
		for (i in 0...10) {
			var d = Math.random() * Math.PI * 2;
			rabbit(Std.random(w), Std.random(h), Math.cos(d) * 2, Math.sin(d) * 2);
		}

		// tiger!
		var d = Math.random() * Math.PI * 2;
		tiger(Std.random(w), Std.random(h), Math.cos(d) * 6, Math.sin(d) * 6);


		Browser.window.setInterval(function() {
			echo.update(.100);
			stat.innerHTML = echo.toString();
		}, 100);
	}


	static function grass(x:Float, y:Float) {
		var codes = [ '&#x1F33E', '&#x1F33F' ];
		echo.setComponent(echo.id(),
			new Position(x, y),
			new Sprite(codes[Std.random(codes.length)]));
	}

	static function tree(x:Float, y:Float) {
		var codes = [ '&#x1F332', '&#x1F333' ];
		echo.setComponent(echo.id(),
			new Position(x, y),
			new Sprite(codes[Std.random(codes.length)]));
	}

	static function flower(x:Float, y:Float) {
		var codes = [ '&#x1F337', '&#x1F339', '&#x1F33B' ];
		echo.setComponent(echo.id(),
			new Position(x, y),
			new Sprite(codes[Std.random(codes.length)]));
	}

	static function rabbit(x:Float, y:Float, vx:Float, vy:Float) {
		var pos = new Position(x, y);
		var vel = new Velocity(vx, vy);
		var spr = new Sprite('&#x1F407;');
		echo.setComponent(echo.id(), pos, vel, spr);
	}

	static function tiger(x:Float, y:Float, vx:Float, vy:Float) {
		var pos = new Position(x, y);
		var vel = new Velocity(vx, vy);
		var spr = new Sprite('&#x1F405;');
		echo.setComponent(echo.id(), pos, vel, spr);
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
abstract Velocity(Vec2) {
	inline public function new(?x:Float, ?y:Float) this = new Vec2(x, y);
}

@:forward(x, y)
abstract Position(Vec2) {
	inline public function new(?x:Float, ?y:Float) this = new Vec2(x, y);
}

abstract Sprite(Element) from Element to Element {
	inline public function new(value:String) {
		this = Browser.document.createSpanElement();
		this.style.position = 'absolute';
		this.innerHTML = value;
	}
}


// Systems

class Movement extends System {
	var w:Float;
	var h:Float;
	var bodies:View<{ pos:Position, vel:Velocity }>;
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
	var world:Array<Array<Element>>;
	public function new(w:Int, h:Int, canvas:Element) {
		world = [];
		for (y in 0...h) {
			world[y] = [];
			for (x in 0...w) {
				var span = Browser.document.createSpanElement();
				span.style.position = 'fixed';
				span.style.left = '${x * 16}px';
				span.style.top = '${y * 16}px';
				world[y][x] = span;
				canvas.appendChild(span);
			}
			canvas.appendChild(Browser.document.createBRElement());
		}
	}

	// all visuals
	// not required updates, just add sprite to the canvas
	var visuals:View<{ pos:Position, spr:Sprite }>;
	@onadded function appendVisual(id:Int) {
		world[Std.int(echo.getComponent(id, Position).y)][Std.int(echo.getComponent(id, Position).x)].appendChild(echo.getComponent(id, Sprite)); // TODO ugly, need more macro
	}

	// dynamic visuals only (with Velocity component)
	@update function updateDynamicVisual(dt:Float, vel:Velocity, pos:Position, spr:Sprite) {
		world[Std.int(pos.y)][Std.int(pos.x)].appendChild(spr);
	}
}
