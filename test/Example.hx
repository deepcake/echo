package;

import echo.Echo;
import echo.System;
import echo.View;
import js.Browser;
import js.html.Element;
using Lambda;

/**
 * ...
 * @author https://github.com/wimcake
 */
class Example {

	static public var RABBITS_POPULATION = 15;
	static public var MAX_WIDTH = 60;
	static public var MAX_HEIGHT = 40;

	static var echo:Echo;

	static function main() {
		var canvas = Browser.document.createElement('code'); // monospace text
		var stat = Browser.document.createPreElement();
		Browser.document.body.appendChild(canvas);
		Browser.document.body.appendChild(stat);

		// mobile friendly (i guess)
		var size = Std.parseInt(Browser.window.getComputedStyle(Browser.document.body).fontSize);
		var w = Browser.window.innerWidth / size > MAX_WIDTH ? MAX_WIDTH : Math.floor(Browser.window.innerWidth / size);
		var h = Browser.window.innerHeight / size > MAX_HEIGHT ? MAX_HEIGHT : Math.floor(Browser.window.innerHeight / size);


		echo = new Echo();
		echo.addSystem(new Movement(w, h));
		echo.addSystem(new Interaction());
		echo.addSystem(new Render(w, h, size, canvas));

		// fill world by plants
		for (y in 0...h) for (x in 0...w) {
			if (Math.random() > .5) {
				grass(x, y); 
			} else {
				if (Math.random() > .2) tree(x, y); else flower(x, y);
			}
		}

		// some rabbits
		for (i in 0...RABBITS_POPULATION) rabbit(Std.random(w), Std.random(h));

		// tiger!
		tiger(Std.random(w), Std.random(h));


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

	static public function rabbit(x:Float, y:Float) {
		var pos = new Position(x, y);
		var vel = randomVelocity(1);
		var spr = new Sprite('&#x1F407;');
		echo.setComponent(echo.id(), pos, vel, spr, Animal.Rabbit);
	}

	static public function tiger(x:Float, y:Float) {
		var pos = new Position(x, y);
		var vel = randomVelocity(10);
		var spr = new Sprite('&#x1F405;');
		spr.style.fontSize = '200%';
		echo.setComponent(echo.id(), pos, vel, spr, Animal.Tiger);
	}

	static public function randomVelocity(speed:Float) {
		var d = Math.random() * Math.PI * 2;
		return new Velocity(Math.cos(d) * speed, Math.sin(d) * speed);
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

@:forward(remove, style)
abstract Sprite(Element) from Element to Element {
	inline public function new(value:String) {
		this = Browser.document.createSpanElement();
		this.style.position = 'absolute';
		this.innerHTML = value;
	}
}

enum Animal {
	Rabbit;
	Tiger;
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
	public function new(w:Int, h:Int, size:Int, canvas:Element) {
		world = [];
		for (y in 0...h) {
			world[y] = [];
			for (x in 0...w) {
				var span = Browser.document.createSpanElement();
				span.style.position = 'absolute';
				span.style.left = '${x * size}px';
				span.style.top = '${y * size}px';
				world[y][x] = span;
				canvas.appendChild(span);
			}
			canvas.appendChild(Browser.document.createBRElement());
		}
	}

	// all visuals
	// not required updates, just add sprite to the canvas
	var visuals:View<{ pos:Position, spr:Sprite }>;
	@onadded function appendVisual(pos:Position, spr:Sprite) {
		world[Std.int(pos.y)][Std.int(pos.x)].appendChild(spr);
	}
	@onremoved function removeVisual(id:Int) {
		echo.getComponent(id, Sprite).remove();
	}

	// dynamic visuals only (with Velocity component)
	@update function updateDynamicVisual(dt:Float, vel:Velocity, pos:Position, spr:Sprite) {
		world[Std.int(pos.y)][Std.int(pos.x)].appendChild(spr);
	}
}

// some dummy interaction
class Interaction extends System {
	var animals:View<{ a:Animal, pos:Position }>;
	override public function update(dt:Float) {
		var del = [];
		for (a1 in animals) for (a2 in animals) {
			if (a1 != a2 && samecell(a1.pos, a2.pos)) {
				if (a1.a == Animal.Tiger && a2.a == Animal.Rabbit) del.push(a2.id);
				if (a1.a == Animal.Rabbit && a2.a == Animal.Rabbit) {
					if (animals.count(function(a) return a.a == Animal.Rabbit) < Example.RABBITS_POPULATION) Example.rabbit(a1.pos.x, a1.pos.y);
				}
			}
		}

		for (id in del) echo.remove(id);
	}
	function samecell(pos1:Position, pos2:Position) return Std.int(pos1.x) == Std.int(pos2.x) && Std.int(pos1.y) == Std.int(pos2.y);
}
