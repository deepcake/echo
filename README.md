# Echo
[![TravisCI Build Status](https://travis-ci.org/deepcake/echo.svg?branch=master)](https://travis-ci.org/deepcake/echo)

Super lightweight Entity Component System framework for Haxe. 
Focused to be simple and fast.
Inspired by other haxe ECS frameworks, especially [EDGE](https://github.com/fponticelli/edge), [ECX](https://github.com/eliasku/ecx), [ESKIMO](https://github.com/PDeveloper/eskimo) and [Ash-Haxe](https://github.com/nadako/Ash-Haxe)

#### Wip

#### Overview
* `Component` is an instance of `T:Any` class. For each `T` class, used as a component, generate a global `Map<Int, T>` component map.
* `Entity` in this case is just the `Int` _id_, used as a key in a global component maps, and combination of components, stored with this _id_.
* `View` is a collection of all suitable _ids_ that was added to _the workflow_.
* `System` is a place for some logic over views;

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
    echo.addSystem(new Render());

    for (i in 0...100) createTree(Std.random(500), Std.random(500));

    createRabbit(100, 100, 1, 1);
  }

  static function createTree(x:Float, y:Float) {
    echo.addComponent(echo.id(), 
      new Position(x, y), 
      new Sprite('assets/tree.png'));
  }
  static function createRabbit(x:Float, y:Float, vx:Float, vy:Float) {
    var id = echo.id();
    var pos = new Position(x, y);
    var vel = new Velocity(vx, vy);
    var spr = new Sprite('assets/rabbit.png');
    echo.addComponent(id, pos, vel, spr);
  }
}

// Components
class Sprite {
  // some visual component, it can be luxe.Sprite or openfl.dispaly.Sprite, for example
}
class Vec2 {
  // abstracts can be used to create different ComponentClass'es from the same BaseClass without overhead
}
@:forward 
abstract Velocity(Vec2) { 
  inline public function new(?x:Float, ?y:Float) this = new Vec2(x, y);
}
@:forward 
abstract Position(Vec2) {
  inline public function new(?x:Float, ?y:Float) this = new Vec2(x, y);
}

// Systems
class Movement extends System {
  // @update-function will be called for each entity that contains required components
  @update function updateBody(pos:Position, vel:Velocity, dt:Float, id:Int) {
    pos.x += vel.x * dt;
    pos.y += vel.y * dt;
  }
  // suitable View<{ pos:Position, vel:Velocity }> will be created under the hood
  // but you can define a View manually
  var positions:View<{ vel:Velocity }>;
}

class Render extends System {

  var scene:Array<Sprite>;

  @a function onEntityWithSpriteComponentAdded(s:Sprite) {
    sprites.push(s);
  }
  @r function onEntityWithSpriteComponentRemoved(s:Sprite, id:Int) {
    sprites.remove(s);
    trace('Oh My God! They Killed $id!');
  }

  // execution order of @update-functions is the same of definition order
  @u inline function updateSpritePosition(spr:Sprite, pos:Position) {
    spr.x = pos.x;
    spr.y = pos.y;
  }
  // @update-function without components will be called just once per update
  @u inline function afterSpritePositionsUpdated() {
    scene.sort(function(s1, s2) return s2.y - s1.y);
  }
}
```

[Live Example](https://deepcake.github.io/echo/web/) - Tiger in the Meatdow! (source [echo/test/Example.hx](https://github.com/deepcake/echo/blob/master/test/Example.hx))

[Live Demo](https://deepcake.github.io/chickens/bin/web/) of using Echo with Luxe and Nape (source [https://github.com/deepcake/chickens](https://github.com/deepcake/chickens))

#### Also
There is also exists a few additional compiler flags:
 * `-D echo_verbose` - traces to console all generated classes (for debug purposes)
 * `-D echo_debug` - collecting some more info for `toString()` method

#### Install
```haxelib git echo https://github.com/deepcake/echo.git```
