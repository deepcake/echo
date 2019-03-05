# Echo
[![TravisCI Build Status](https://travis-ci.org/deepcake/echo.svg?branch=master)](https://travis-ci.org/deepcake/echo)

Super lightweight Entity Component System framework for Haxe. 
Initially created to learn the power of macros. 
Focused to be simple and fast. 
Inspired by other haxe ECS frameworks, especially [EDGE](https://github.com/fponticelli/edge), [ECX](https://github.com/eliasku/ecx), [ESKIMO](https://github.com/PDeveloper/eskimo) and [Ash-Haxe](https://github.com/nadako/Ash-Haxe)

#### Wip

#### Overview
* `Component` is an instance of `T:Any` class. A global component map will be generated for each `T` class, used as a component.
* `Entity` is an abstract over the `Int` _id_, used as a key in a global component map.
* `View` is a collection of all suitable _ids_ that was added to _the workflow_.
* `System` is a place for some logic over views;

#### Example
```haxe
import echo.Echo;
import echo.Entity;
import echo.View;

class Example {

  static function main() {
    Echo.addSystem(new Movement());
    Echo.addSystem(new Render());

    for (i in 0...100) createTree(Std.random(500), Std.random(500));

    var rabbit = createRabbit(100, 100, 1, 1);
    trace(rabbit.exists(Position)); // true
    trace(rabbit.get(Position).x); // 100
    rabbit.remove(Position); // oh no!
    rabbit.add(new Position(1, 1)); // okay

    // also somewhere should be Echo.update(deltatime) call on every tick
  }

  static function createTree(x:Float, y:Float) {
    return new Entity()
      .add(new Position(x, y))
      .add(new Sprite('assets/tree.png'));
  }
  static function createRabbit(x:Float, y:Float, vx:Float, vy:Float) {
    var pos = new Position(x, y);
    var vel = new Velocity(vx, vy);
    var spr = new Sprite('assets/rabbit.png');
    return new Entity().add(pos, vel, spr);
  }
}

// some visual component, openfl.dispaly.Sprite for example
class Sprite { } 

// abstracts can be used to create different ComponentClass'es from the same BaseClass without overhead
class Vec2 { var x:Float; var y:Float; }
@:forward abstract Velocity(Vec2) { 
  inline public function new(x, y) this = new Vec2(x, y);
}
@:forward abstract Position(Vec2) {
  inline public function new(x, y) this = new Vec2(x, y);
}

class Movement extends echo.System {
  // @update-functions will be called for each entity that contains required components;
  // all views for that will be defined and initialized under the hood;
  // any types are supposed to be a component, 
  // except Float (reserved for delta time) and Int/Entity (reserved for Entity id);
  @update function updateBody(pos:Position, vel:Velocity, dt:Float, id:Int) {
    pos.x += vel.x * dt;
    pos.y += vel.y * dt;
  }

  // it is also possible to define a View manually (initialization is still not needed) 
  // for additional abilities like counting entities;
  var velocities:View<{ vel:Velocity }>;

  // @update-function without components will be called just once per system update;
  @update function printVelocitiesCount() {
    trace('we have a ${ velocities.entities.length } count of entities with velocity component!');
    // another way to iterate over entities
    velocities.iter((entity, velocity) -> trace('$entity has velocity $velocity'));
  }
}

class Render extends echo.System {
  var scene:Array<Sprite> = [];
  // @a, @u and @r is a shortcuts for @added, @update and @removed;
  // @added/@removed-functions is a callbacks called when entity is added or removed from the view;
  @a function onEntityWithSpriteComponentAdded(spr:Sprite, pos:Position) {
    scene.push(spr);
  }
  @r function onEntityWithSpriteComponentRemoved(spr:Sprite, pos:Position, entity:Entity) {
    // even if callback was triggered by destroying entity or removing a Sprite component, 
    // @removed-function actually will be called before that will happened, 
    // so access to entity or component will be still exists;
    scene.remove(spr);
    trace('Oh My God! They removed $entity!');
  }

  // execution order of @update-functions is the same to definition order, 
  // so it is possible to do some preparations before iterate over entities;
  @u inline function beforeSpritePositionsUpdated() {
    trace('starting update positions of ${ scene.length } sprites!');
  }
  @u inline function updateSpritePosition(spr:Sprite, pos:Position) {
    spr.x = pos.x;
    spr.y = pos.y;
  }
  // @update-function without components can receive a Float deltatime
  @u inline function afterSpritePositionsUpdated(dt:Float) {
    scene.sort(function(s1, s2) return s2.y - s1.y);
  }
}
```

[Live Example](https://deepcake.github.io/echo/web/) - Tiger in the Meatdow! (source [echo/example/TigerInTheMeatdow.hx](https://github.com/deepcake/echo/blob/master/example/TigerInTheMeatdow.hx))


#### Also
There is also exists a few additional compiler flags:
 * `-D echo_profiling` - collecting some more info for `Echo.toString()` method (especially for debug purposes)
 * `-D echo_report` - traces a short report of built components and views
 * `-D echo_array_cc` - using Array<T> instead IntMap<T> for global component containers

#### Install
```haxelib git echo https://github.com/deepcake/echo.git```
