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

        Workflow.addSystem(new Movement(w, h));
        Workflow.addSystem(new Play(population));
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
        spr.style.fontSize = '150%';
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
        this.style.right = '0px';
        this.style.bottom = '0px';
        this.style.fontSize = '125%';
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

// some dummy interaction
class Play extends System {
    var del = [];

    var population:Int;
    var animals:View<{ a:Animal, pos:Position }>;

    public function new(population:Int) {
        this.population = population;
    }

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
                        if (animals.entities.count(function(i) return i.get(Animal) == Animal.Rabbit) < population) {
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
