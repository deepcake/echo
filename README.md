# echo
[![TravisCI Build Status](https://travis-ci.org/octocake1/echo.svg?branch=master)](https://travis-ci.org/octocake1/echo)

Super lightweight entity component system framework for Haxe

Inspired by other haxe ecs frameworks, especially [EDGE](https://github.com/fponticelli/edge), [ECX](https://github.com/eliasku/ecx) and [ESKIMO](https://github.com/PDeveloper/eskimo)

#### Example
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

[See web demo](https://octocake1.github.io/echo/web/) (source at [echo/test/Example.hx](https://github.com/octocake1/echo/blob/master/test/Example.hx))

#### Overview
* `Component` is an instance of any `Class`.
* `Entity` is the `Int` _id_, referenced to global `Map<Int, ComponentClass>`s.
* `View<T>` is a collection of suitable for filter `T` _ids_ with ability to iterate over them.
* `System` is a wrapper for `View`'s with some ~~syntactic~~ macro sugar.

#### API
* `Echo` - something like called `Engine` in other frameworks. Entry point. _The workflow_.
  * `.id():Int` - create and add new _id_ to _the workflow_.
  * `.next():Int` - only create new _id_, without adding it to _the workflow_.
  * `.add(id:Int)` - add _id_ to _the workflow_
  * `.remove(id:Int)` - remove _id_ from _the workflow_.
  * `.dispose(id:Int)` - remove _id_ from _the workflow_ and remove all it components. If we expect to use _id_ with all its components after removing from _the workflow_ - use `remove()`, otherwise use `dispose()`.
  * `.setComponent(id:Int, ...args:Any)` - add/set components to the _id_, one or many at once.
  * `.getComponent(id:Int, type:Class<T>):T` - get component form _id_ by type.
  * `.removeComponent(id:Int, type:Class<Any>)` - remove component from _id_ by type.
  * `.addSystem`, `.removeSystem(system:System)` - add/remove system from _the workflow_
  * `.addView`, `.removeView` - add/remove view from _the workflow_. In most cases we will not call that functions directly, macro will do it for us.
* `View<T>`
  * `.onAdd`, `.onRemove:Signal<Int->Void>` - signals, called at add/remove an suitable _id_ to _the workflow_.
  * `.entities:Array<Int>` - array of _ids_ into this view. Can be sorted.
  * `.iterator:Iterator<T>` - produce iterating over _ids_ like they was an instances of `T` with minimal overhead.
* `System` - to be extended.
  * `.onactivate`, `.ondeactivate` - to be overridden. Called at add/remove from _the workflow_.
  * `.update(dt:Float)` - to be overridden. Main logic place.
  * `@view`, `@skip` - macro tags to check\uncheck variable as a View
  
