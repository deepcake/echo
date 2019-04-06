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

    static var size:Int;


    static function main() {
        var canvas = Browser.document.createDivElement();
        canvas.classList.add('meatdow');

        var info = Browser.document.createPreElement();
        info.classList.add('info');

        Browser.document.body.appendChild(canvas);
        Browser.document.body.appendChild(info);

        // make it mobile friendly (i guess)
        size = Std.parseInt(Browser.window.getComputedStyle(canvas).fontSize);

        var w = Math.floor(Browser.window.innerWidth / size);
        var h = Math.floor(Browser.window.innerHeight / size);

        var population = Std.int(Math.max(w * h / 50, 10));

        Workflow.addSystem(new Play());
        Workflow.addSystem(new Movement(w, h));
        Workflow.addSystem(new Render(w, h, size, canvas));
        Workflow.addSystem(new Effects());
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
            new Sprite(getRandomEmoji(GRASS)));
    }

    static function tree(x:Float, y:Float) {
        new Entity().add(
            new Position(x, y), 
            new Sprite(getRandomEmoji(TREE), '175%'));
    }

    static function flower(x:Float, y:Float) {
        new Entity().add(
            new Position(x, y),
            new Sprite(getRandomEmoji(FLOWER)));
    }

    static public function rabbit(x:Float, y:Float) {
        var entity = new Entity();
        var pos = new Position(x, y);
        var vel = getRandomVelocity(1);
        var spr = new Sprite('&#x1F407;');
        var animal = Animal.Rabbit(entity);
        entity.add(pos, vel, spr, animal);
    }

    static public function tiger(x:Float, y:Float) {
        var pos = new Position(x, y);
        var vel = getRandomVelocity(10);
        var spr = new Sprite('&#x1F405;', '150%');
        new Entity().add(pos, vel, spr, Animal.Tiger);
    }

    static public function loveEvent(x:Float, y:Float) {
        // heart
        new Entity().add(
            new Position(x, y),
            new Sprite('&#x1F498'),
            new Effect(1.0, getSizeAndOpacityTween(1.0, 0.75, 1.0, -1.0), null)
        );
    }

    static public function deathEvent(x:Float, y:Float) {
        // ghost
        new Entity().add(
            getRandomVelocity(2),
            new Position(x, y),
            new Sprite('&#x1F47B;'),
            new Effect(5.0, getSizeAndOpacityTween(1.15, 0.10, 1.0, -1.0), e -> Main.rabbit(e.get(Position).x, e.get(Position).y))
        );
        // collision
        new Entity().add(
            new Position(x, y),
            new Sprite('&#x1F4A5;'),
            new Effect(1.0, getSizeAndOpacityTween(1.40, 0.10, 1.0, -1.0), null)
        );
    }

    static function getRandomEmoji(codes:Array<String>) {
        return codes[Std.random(codes.length)];
    }

    static function getRandomVelocity(speed:Float) {
        var d = Math.random() * Math.PI * 2;
        return new Velocity(Math.cos(d) * speed, Math.sin(d) * speed);
    }

    static function getOpacityTween(from:Float, delta:Float) {
        return (e:Entity, t:Float) -> e.get(Sprite).setOpacity(from + t * delta);
    }

    static function getSizeTween(from:Float, delta:Float) {
        return (e:Entity, t:Float) -> e.get(Sprite).setSize(from + t * delta);
    }

    static function getSizeAndOpacityTween(fromSize:Float, deltaSize:Float, fromOpacity:Float, deltaOpacity:Float) {
        var t1 = getSizeTween(fromSize, deltaSize);
        var t2 = getOpacityTween(fromOpacity, deltaOpacity);
        return (e:Entity, t:Float) -> {
            t1(e, t);
            t2(e, t);
        }
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
    public function setOpacity(value:Float) {
        this.style.opacity = '${ value }';
        
    }
    public function setSize(value:Float) {
        this.style.fontSize = '${ Std.int(value * 100) }%';
    }
}

enum Animal {
    Rabbit(lastlove:Entity);
    Tiger;
}

class Effect {
    public var timeout:Float;
    public var time:Float;
    public var onUpdate:Entity->Float->Void;
    public var onComplete:Entity->Void;
    public function new(timeout:Float, onUpdate:Entity->Float->Void, onComplete:Entity->Void) {
        this.time = .0;
        this.timeout = timeout;
        this.onUpdate = onUpdate;
        this.onComplete = onComplete;
    }
}


// Systems

class Info extends System {
    public static var eaten = 0;
    var element:Element;
    public function new(element:Element) {
        this.element = element;
    }
    @u function print() {
        element.innerHTML = 'EATEN: $eaten\n\n${ Workflow.toString() }';
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
    var animals:View<Animal->Position>;

    @u inline function interaction(dt:Float) {
        // dummy everyone with everyone
        for (i1 in 0...animals.entities.length) {
            var id1 = animals.entities[i1];
            var a1 = id1.get(Animal);
            var pos1 = id1.get(Position);

            for (i2 in i1+1...animals.entities.length) {
                var id2 = animals.entities[i2];
                var a2 = id2.get(Animal);
                var pos2 = id2.get(Position);

                if (test(pos1, pos2, 1.41)) {

                    switch (a1) {
                        case Tiger: 
                            switch (a2) {
                                case Rabbit(_): eats(id1, id2);
                                default: 
                            }
                        case Rabbit(lastlove1): 
                            switch (a2) {
                                case Tiger: eats(id2, id1);
                                case Rabbit(lastlove2): {

                                    if (id1 != lastlove2 && id2 != lastlove1) {
                                        var x = (pos1.x + pos2.x) / 2;
                                        var y = (pos1.y + pos2.y) / 2;
                                        Main.loveEvent(x, y);
                                        id1.add(Rabbit(id2));
                                        id2.add(Rabbit(id1));
                                    }

                                }
                            }
                    }

                }
            }
        }

        while (del.length > 0) del.pop().destroy();
    }

    function eats(tiger:Entity, rabbit:Entity) {
        trace('#$tiger eats #$rabbit');
        Main.deathEvent(rabbit.get(Position).x, rabbit.get(Position).y);
        del.push(rabbit);
        Info.eaten++;
    }

    function test(pos1:Position, pos2:Position, radius:Float) {
        var dx = pos2.x - pos1.x;
        var dy = pos2.y - pos1.y;
        return dx * dx + dy * dy < radius * radius;
    }
}

class Effects extends System {

    @u inline function update(id:Entity, dt:Float, ef:Effect) {
        ef.time += dt;

        if (ef.time < ef.timeout) {
            if (ef.onUpdate != null) ef.onUpdate(id, ef.time / ef.timeout);
        } else {
            if (ef.onUpdate != null) ef.onUpdate(id, 1.0);
            if (ef.onComplete != null) ef.onComplete(id);
            id.destroy();
        }
    }

}
