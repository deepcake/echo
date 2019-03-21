package;

import echos.Workflow;
import echos.System;
import echos.View;
import echos.Entity;
import js.Browser;
import js.html.Element;
using Lambda;

/**
 * ...
 * @author https://github.com/deepcake
 */
class TigerInTheMeatdow {

	static public var RABBITS_POPULATION = 64;

	static function main() {
		var canvas = Browser.document.createElement('code'); // monospace text
		var stat = Browser.document.createPreElement();
		Browser.document.body.appendChild(canvas);
		Browser.document.body.appendChild(stat);

		// mobile friendly (i guess)
		var size = Std.parseInt(Browser.window.getComputedStyle(Browser.document.body).fontSize);

		var w = Math.floor(Browser.window.innerWidth / size);
		var h = 40;


		Workflow.addSystem(new Movement(w, h));
		Workflow.addSystem(new Interaction());
		Workflow.addSystem(new Render(w, h, size, canvas));
		Workflow.addSystem(new InteractionEvent());

		// fill world by plants
		for (y in 0...h) {
			for (x in 0...w) {
				if (Math.random() < .75) {
					grass(x, y); 
				} else {
					if (Math.random() < .25) {
						tree(x, y); 
					} else {
						flower(x, y);
					}
				}
			}
		}

		// some rabbits
		for (i in 0...RABBITS_POPULATION) {
			rabbit(Std.random(w), Std.random(h));
		}

		// tiger!
		tiger(Std.random(w), Std.random(h));


		Browser.window.setInterval(function() {
			Workflow.update(.050);
			stat.innerHTML = Workflow.toString();
		}, 50);
	}


	static function grass(x:Float, y:Float) {
		var codes = [ '&#x1F33E', '&#x1F33F' ];
		new Entity().add(
			new Position(x, y),
			new Sprite(codes[Std.random(codes.length)]));
	}

	static function tree(x:Float, y:Float) {
		var codes = [ '&#x1F332', '&#x1F333' ];
		new Entity().add(
			new Position(x, y), 
			new Sprite(codes[Std.random(codes.length)]));
	}

	static function flower(x:Float, y:Float) {
		var codes = [ '&#x1F337', '&#x1F339', '&#x1F33B' ];
		new Entity().add(
			new Position(x, y),
			new Sprite(codes[Std.random(codes.length)]));
	}

	static public function rabbit(x:Float, y:Float) {
		var pos = new Position(x, y);
		var vel = randomVelocity(1);
		var spr = new Sprite('&#x1F407;');
		new Entity().add(pos, vel, spr, Animal.Rabbit);
	}

	static public function tiger(x:Float, y:Float) {
		var pos = new Position(x, y);
		var vel = randomVelocity(10);
		var spr = new Sprite('&#x1F405;');
		spr.style.fontSize = '200%';
		new Entity().add(pos, vel, spr, Animal.Tiger);
	}

	static public function event(x:Float, y:Float, type:String) {
		var code = switch(type) {
			case 'heart': '&#x1F498;';
			case 'skull': '&#x1F480;';
			default: '';
		}
		new Entity().add(
			new Position(x, y),
			new Sprite(code),
			new Timer(5.0));
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

class Timer {
	public var timeout:Float;
	public var time:Float;
	public function new(timeout:Float) {
		this.time = .0;
		this.timeout = timeout;
	}
}


// Systems

class Movement extends System {
	var w:Float;
	var h:Float;
	public function new(w:Float, h:Float) {
		this.w = w;
		this.h = h;
	}
	@u function move(dt:Float, pos:Position, vel:Velocity) {
		var dx = vel.x * dt;
		var dy = vel.y * dt;

		if (pos.x + dx >= w - 1 || pos.x + dx < 0) {
			vel.x *= -1;
		}

		if (pos.y + dy >= h - 1 || pos.y + dy < 0) {
			vel.y *= -1;
		}

		pos.x += dx;
		pos.y += dy;
	}
}

class Render extends System {
	var world:Array<Array<Element>> = [];
	public function new(w:Int, h:Int, size:Int, canvas:Element) {
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

	@ad inline function appendVisual(pos:Position, spr:Sprite) {
		world[Std.int(pos.y)][Std.int(pos.x)].appendChild(spr); 
	}
	@rm inline function removeVisual(pos:Position, spr:Sprite) {
		spr.remove();
	}

	// dynamic visuals only (with Velocity component)
	@update inline function updateDynamicVisual(dt:Float, vel:Velocity, pos:Position, spr:Sprite) {
		world[Std.int(pos.y)][Std.int(pos.x)].appendChild(spr);
	}
}

// some dummy interaction
class Interaction extends System {
	var animals:View<{ a:Animal, pos:Position }>;
	var del = [];
	@u inline function action(dt:Float) {
		// everyone with everyone
		animals.iter((id1, a1, pos1) -> {
			animals.iter((id2, a2, pos2) -> {

				if (id1 != id2 && isInteract(pos1, pos2, 1.0)) {

					if (a1 == Animal.Tiger && a2 == Animal.Rabbit) {
						// tiger eats rabbit
						trace('$id1 eats $id2');
						TigerInTheMeatdow.event(pos1.x, pos1.y, 'skull');
						del.push(id2);
					}
					if (a1 == Animal.Rabbit && a2 == Animal.Rabbit) {
						// rabbits reproduces
						if (animals.entities.count(function(i) return i.get(Animal) == Animal.Rabbit) < TigerInTheMeatdow.RABBITS_POPULATION) {
							TigerInTheMeatdow.rabbit(pos1.x, pos1.y);
							TigerInTheMeatdow.event(pos1.x, pos1.y, 'heart');
						}
					}

				}

			});
		});

		while(del.length > 0) del.pop().destroy();
	}

	function isInteract(pos1:Position, pos2:Position, radius:Float) {
		return Math.abs(pos1.x - pos2.x) < radius && Math.abs(pos1.y - pos2.y) < radius;
	}
}

class InteractionEvent extends System {
	@u inline function action(id:Entity, dt:Float, t:Timer, s:Sprite) {
		s.style.opacity = '${1.0 - (t.time / t.timeout)}';
		t.time += dt;
		if (t.time >= t.timeout) {
			s.style.opacity = '.0';
			id.destroy();
		}
	}
}
