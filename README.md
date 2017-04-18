# Echo
[![TravisCI Build Status](https://travis-ci.org/octocake1/echo.svg?branch=master)](https://travis-ci.org/octocake1/echo)

Super lightweight entity component system framework for Haxe

Inspired by other haxe ecs frameworks, especially [EDGE](https://github.com/fponticelli/edge), [ECX](https://github.com/eliasku/ecx) and [ESKIMO](https://github.com/PDeveloper/eskimo)

### Example
```haxe
import echo.Echo;
import echo.System;
import echo.View;

class Example {
  static var echo:Echo;
  
  static function main() {
    echo = new Echo();
    echo.addSystem(new Movement());
    echo.addSystem(new Render(1024, 720));
    
    for (i in 0...100) createTree(Std.random(1280), Std.random(720));
    for (i in 0...10) {
      var d = Math.random() * Math.PI * 2;
      createRabbit(Std.random(1280), Std.random(720), Math.cos(d) * 2, Math.sin(d) * 2);
    }
  }
  
  static function createTree(x:Float, y:Float) {
    echo.setComponent(echo.id(), 
      new Position(x, y), 
      new Sprite());
  }
  
  // sort of entity decorator
  static function createDynamic(x:Float, y:Float, vx:Float, vy:Float):Int {
    var id = echo.id();
    var pos = new Position(x, y);
    var vel = new Velocity(vx, vy);
    echo.setComponent(id, pos, vel);
    return id;
  }
  static function createRabbit(x:Float, y:Float, vx:Float, vy:Float) {
    echo.setComponent(createDynamic(x, y, vx, vy), new Sprite());
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
  // abstracts can be used to create different ComponentClasses from the same BaseClass without overhead
  inline public function new(?x:Float, ?y:Float) this = new Vec2(x, y);
}

@:forward(x, y)
abstract Position(Vec2) {
  inline public function new(?x:Float, ?y:Float) this = new Vec2(x, y);
}

class Sprite {
  // some visual component, it can be luxe.Sprite or openfl.dispaly.Sprite, for example
}

// Systems
class Movement extends System {
  var bodies = new View<{ pos:Position, vel:Velocity }>();
  override public function update(dt:Float) {
    for (body in bodies) {
      body.pos.x += body.vel.x * dt;
      body.pos.y += body.vel.y * dt;
    }
  }
}

class Render extends System {
  @skip var w:Float;
  @skip var h:Float;
  // @skip indicates that var is not View, so macro dont touch it
  // instead @skip can be used @view, and all vars without @view will be skipped
  var visuals = new View<{ pos:Position, spr:Sprite }>();
  public function new(w:Int, h:Int) {
    this.w = w;
    this.h = h;
  }
  override public function update(dt:Float) {
    for (v in visuals) {
      // move sprites to position or something
    }
  }
}
```

[See web demo](https://octocake1.github.io/echo/web/) (source: [echo/test/Example.hx](https://github.com/octocake1/echo/blob/master/test/Example.hx))
