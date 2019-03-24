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
class Main {


    static var GRASS = [ '&#x1F33E', '&#x1F33F' ];
    static var TREE = [ '&#x1F332', '&#x1F333' ];
    static var FLOWER = [ '&#x1F337', '&#x1F339', '&#x1F33B' ];


    static function main() {
        var canvas = Browser.document.createDivElement();
        canvas.classList.add('meatdow');

        var info = Browser.document.createPreElement();
        info.classList.add('info');

        Browser.document.body.appendChild(canvas);
        Browser.document.body.appendChild(info);

        // make it mobile friendly (i guess)
        var size = Std.parseInt(Browser.window.getComputedStyle(canvas).fontSize);

        var w = Math.floor(Browser.window.innerWidth / size);
        var h = Math.floor(Browser.window.innerHeight / size);

        var population = Std.int(Math.max(w * h / 50, 10));

        Workflow.addSystem(new Play(population));
        Workflow.addSystem(new Movement(w, h));
        Workflow.addSystem(new Render(w, h, size, canvas));
        Workflow.addSystem(new InteractionEvent());
        Workflow.addSystem(new Info(info));

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
        for (i in 0...population) {
            rabbit(Std.random(w), Std.random(h));
        }

        // tiger!
        tiger(Std.random(w), Std.random(h));

        var fps = 60;
        Browser.window.setInterval(function() Workflow.update(fps / 1000), fps);
    }


    static function grass(x:Float, y:Float) {
        new Entity().add(
            new Position(x, y),
            new Sprite(randomEmoji(GRASS)));
    }

    static function tree(x:Float, y:Float) {
        new Entity().add(
            new Position(x, y), 
            new Sprite(randomEmoji(TREE), '175%'));
    }

    static function flower(x:Float, y:Float) {
        new Entity().add(
            new Position(x, y),
            new Sprite(randomEmoji(FLOWER)));
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
        var spr = new Sprite('&#x1F405;', '150%');
        new Entity().add(pos, vel, spr, Animal.Tiger);
    }

    static public function event(x:Float, y:Float, type:String, cb:Void->Void) {
        var code = switch(type) {
            case 'heart': '&#x1F498;';
            case 'skull': '&#x1F480;';
            default: '';
        }
        new Entity().add(
            new Position(x, y),
            new Sprite(code),
            new Timer(5.0, cb));
    }

    static function randomEmoji(codes:Array<String>) {
        return codes[Std.random(codes.length)];
    }

    static function randomVelocity(speed:Float) {
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
    inline public function new(value:String, size = '125%') {
        this = Browser.document.createSpanElement();
        this.style.position = 'absolute';
        this.style.right = '0px';
        this.style.bottom = '0px';
        this.style.fontSize = size;
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
    public var cb:Void->Void;
    public function new(timeout:Float, cb:Void->Void) {
        this.time = .0;
        this.timeout = timeout;
        this.cb = cb;
    }
}


// Systems

class Info extends System {
    var element:Element;
    public function new(element:Element) {
        this.element = element;
    }
    @u function print() {
        element.innerHTML = '${ Workflow.toString() }';
    }
}

class Movement extends System {
    var w:Float;
    var h:Float;
    public function new(w:Float, h:Float) {
        this.w = w;
        this.h = h;
    }
    @u inline function move(dt:Float, pos:Position, vel:Velocity) {
        var dx = vel.x * dt;
        var dy = vel.y * dt;

        if (pos.x + dx > w - 1 || pos.x + dx < 0) {
            vel.x *= -1;
        }

        if (pos.y + dy > h - 1 || pos.y + dy < 0) {
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
                span.style.left = '${(x + 1) * size}px';
                span.style.top = '${(y + 1) * size}px';
                world[y][x] = span;
                canvas.appendChild(span);
            }
            canvas.appendChild(Browser.document.createBRElement());
        }
    }

    @ad inline function appendSprite(pos:Position, spr:Sprite) {
        world[Std.int(pos.y)][Std.int(pos.x)].appendChild(spr); 
    }
    @rm inline function detachSprite(pos:Position, spr:Sprite) {
        spr.remove();
    }

    @u inline function updateDynamicSprite(vel:Velocity, pos:Position, spr:Sprite) {
        world[Std.int(pos.y)][Std.int(pos.x)].appendChild(spr);
    }
}

class Play extends System {
    var del = [];
    var animals:View<Animal->Position->Velocity->Void>;

    var maxPopulation:Int;
    var population:Int;

    public function new(population:Int) {
        this.maxPopulation = population;
        this.population = maxPopulation;
    }

    @u inline function action(dt:Float) {
        // dummy everyone with everyone
        animals.iter((id1, a1, pos1, vel1) -> {
            animals.iter((id2, a2, pos2, vel2) -> {

                if (id1 != id2 && test(pos1, pos2, 1.41)) {

                    if (a1 == Animal.Tiger && a2 == Animal.Rabbit) {

                        trace('#$id1 eats #$id2');
                        Main.event(pos1.x, pos1.y, 'skull', null);
                        del.push(id2);
                        population--;

                    }

                    if (a1 == Animal.Rabbit && a2 == Animal.Rabbit) {

                        // bounce
                        vel1.x *= -1;
                        vel1.y *= -1;
                        vel2.x *= -1;
                        vel2.y *= -1;

                        if (population < maxPopulation) {
                            var x = (pos1.x + pos2.x) / 2;
                            var y = (pos1.y + pos2.y) / 2;
                            Main.event(x, y, 'heart', function() Main.rabbit(x, y));
                            population++;
                        }

                    }

                }

            });
        });

        while (del.length > 0) del.pop().destroy();
    }

    function test(pos1:Position, pos2:Position, radius:Float) {
        var dx = pos2.x - pos1.x;
        var dy = pos2.y - pos1.y;
        return dx * dx + dy * dy < radius * radius;
    }
}

class InteractionEvent extends System {
    @u inline function action(id:Entity, dt:Float, t:Timer, s:Sprite) {
        s.style.opacity = '${1.0 - (t.time / t.timeout)}';
        s.style.fontSize = '${ 100 + Std.int((t.time / t.timeout) * 75) }%';

        t.time += dt;
        if (t.time >= t.timeout) {
            s.style.opacity = '.0';

            if (t.cb != null) t.cb();
            id.destroy();
        }
    }
}
