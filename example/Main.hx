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


    static var GRASS = [ '🌾', '🌿' ];
    static var TREE = [ '🌲', '🌳' ];
    static var FLOWER = [ '🌻', '🥀', '🌹', '🌷' ];
    static var MEAT = [ '🥩', '🍗', '🍖' ];

    static var SIZE:Int;


    static function main() {
        var canvas = Browser.document.createDivElement();
        canvas.classList.add('meatdow');

        var info = Browser.document.createPreElement();
        info.classList.add('info');

        Browser.document.body.appendChild(canvas);
        Browser.document.body.appendChild(info);

        // make it mobile friendly (i guess)
        SIZE = Std.parseInt(Browser.window.getComputedStyle(canvas).fontSize);

        var w = Math.floor(Browser.window.innerWidth / SIZE);
        var h = Math.floor(Browser.window.innerHeight / SIZE);

        var population = Std.int(Math.max(w * h / 50, 10));

        Workflow.addSystem(new Play());
        Workflow.addSystem(new Movement(w, h));
        Workflow.addSystem(new Render(w, h, SIZE, canvas));
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

    static public function rabbit(x:Float, y:Float):Entity {
        var entity = new Entity();
        var pos = new Position(x, y);
        var vel = getRandomVelocity(1);
        var spr = new Sprite('🐇', '100%');
        var animal = Rabbit(entity);
        return entity.add(pos, vel, spr, animal);
    }

    static public function tiger(x:Float, y:Float):Entity {
        var pos = new Position(x, y);
        var vel = getRandomVelocity(10);
        var spr = new Sprite('🐅', '150%');
        return new Entity().add(pos, vel, spr, Tiger);
    }

    static public function loveEvent(x:Float, y:Float) {
        // heart
        new Entity().add(
            new Position(x, y),
            new Sprite('💘'),
            new Effect(1.0, getSizeAndOpacityTween(1.25, 0.50, 1.0, -0.75), null)
        );
    }

    static public function deathEvent(x:Float, y:Float) {
        var reborn = (e:Entity) -> {
            var nx = e.get(Position).x;
            var ny = e.get(Position).y;
            Main.rabbit(nx, ny).add(new Effect(1.0, getOpacityTween(0, 1.0), null, false));
        };

        // ghost
        new Entity().add(
            getRandomVelocity(2),
            new Position(x, y),
            new Sprite('👻'),
            new Effect(5.0, getSizeAndOpacityTween(1.15, 0.10, 1.0, -0.75), reborn)
        );
        // collision
        new Entity().add(
            new Position(x, y),
            new Sprite('💥', '150%'),
            new Effect(1.0, getOpacityTween(1.0, -0.75), null)
        );

        // drop
        for (i in 0...3) {
            var dx = 1 - Std.random(3);
            var dy = 1 - Std.random(3);
            new Entity().add(
                new Position(x + dx, y + dy),
                new Sprite(getRandomEmoji(MEAT), '100%'),
                new Effect(7.0, getOpacityTween(1.0, -0.75), null)
            );
        }
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

    static function getFlickerTween() {
        return (e:Entity, t:Float) -> e.get(Sprite).setOpacity(Std.int(t * 50) % 4 == 0 ? 0.0 : 1.0);
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
    inline public function new(value:String, SIZE = '125%') {
        this = Browser.document.createSpanElement();
        this.style.position = 'absolute';
        this.style.right = '0px';
        this.style.bottom = '0px';
        this.style.fontSize = SIZE;
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
    public var destroy:Bool;
    public function new(timeout:Float, onUpdate:Entity->Float->Void, onComplete:Entity->Void, destroy = true) {
        this.time = .0;
        this.timeout = timeout;
        this.onUpdate = onUpdate;
        this.onComplete = onComplete;
        this.destroy = destroy;
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
        element.innerHTML = 'EATEN: $eaten\n\n${ Workflow.info() }';
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
    var w:Float;
    var h:Float;
    var world:Array<Array<Element>> = [];
    public function new(w:Int, h:Int, SIZE:Int, canvas:Element) {
        this.w = w;
        this.h = h;
        for (y in 0...h) {
            world[y] = [];
            for (x in 0...w) {
                var span = Browser.document.createSpanElement();
                span.style.position = 'absolute';
                span.style.left = '${(x + 1) * SIZE}px';
                span.style.top = '${(y + 1) * SIZE}px';
                world[y][x] = span;
                canvas.appendChild(span);
            }
            canvas.appendChild(Browser.document.createBRElement());
        }
    }

    @ad inline function appendSprite(pos:Position, spr:Sprite) {
        pos.x = Math.max(0, Math.min(w - 1, pos.x));
        pos.y = Math.max(0, Math.min(h - 1, pos.y));
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

    var animals:View<Animal->Position>;

    @u inline function interaction(dt:Float) {
        var n1 = animals.entities.head;
        while (n1 != null) {
            var id1 = n1.value;
            var a1 = id1.get(Animal);
            var pos1 = id1.get(Position);

            var n2 = n1.next;
            while (n2 != null) {
                var id2 = n2.value;
                var a2 = id2.get(Animal);
                var pos2 = id2.get(Position);

                if (test(pos1, pos2, 1.41)) {

                    switch (a1) {
                        case Tiger: 
                            switch (a2) {
                                case Rabbit(_): {
                                    eats(id1, id2);
                                }
                                default: 
                            }
                        case Rabbit(lastlove1): 
                            switch (a2) {
                                case Tiger: {
                                    eats(id2, id1);
                                }
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

                n2 = n2.next;
            }

            n1 = n1.next;
        }
    }

    function eats(tiger:Entity, rabbit:Entity) {
        trace('#$tiger eats #$rabbit');
        Main.deathEvent(rabbit.get(Position).x, rabbit.get(Position).y);
        Info.eaten++;
        rabbit.destroy();
    }

    function test(pos1:Position, pos2:Position, radius:Float) {
        var dx = pos2.x - pos1.x;
        var dy = pos2.y - pos1.y;
        return dx * dx + dy * dy < radius * radius;
    }
}

class Effects extends System {

    @a inline function add(id:Entity, ef:Effect) {
        if (ef.onUpdate != null) ef.onUpdate(id, 0.0);
    }

    @u function update(id:Entity, ef:Effect, dt:Float) {
        ef.time += dt;

        if (ef.time < ef.timeout) {
            if (ef.onUpdate != null) ef.onUpdate(id, ef.time / ef.timeout);
        } else {
            if (ef.onUpdate != null) ef.onUpdate(id, 1.0);
            if (ef.onComplete != null) ef.onComplete(id);
            if (ef.destroy) {
                id.destroy();
            } else {
                id.remove(Effect);
            }
        }
    }

}
