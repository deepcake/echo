# echos
[![TravisCI Build Status](https://travis-ci.org/deepcake/echo.svg?branch=master)](https://travis-ci.org/deepcake/echo)

Super lightweight Entity Component System framework for Haxe. 
Initially created to learn the power of macros. 
Focused to be simple and fast. 
Inspired by other haxe ECS frameworks, especially [EDGE](https://github.com/fponticelli/edge), [ECX](https://github.com/eliasku/ecx), [ESKIMO](https://github.com/PDeveloper/eskimo) and [Ash-Haxe](https://github.com/nadako/Ash-Haxe)

#### Wip

#### Overview
 * Component is an instance of `T:Any` class. For each class `T` will be generated a global component container, where instance of `T` is a value and `Entity` is a key. 
 * `Entity` in that case is just an abstract over the `Int`, but with the ability to work with it as with a set of components like in other regular ECS frameworks. 
 * `View<T>` is a collection of entities containing all of the required components of the requested types. 
 * `System` is a place to process data collected by views. 

#### Example
```haxe
import echos.Workflow;
import echos.Entity;

class Example {
  static function main() {
    Workflow.addSystem(new Movement());
    Workflow.addSystem(new Render());
    // and so on

    var rabbit = createRabbit(0, 0, 1, 1);

    trace(rabbit.exists(Position)); // true
    trace(rabbit.get(Position).x); // 100
    rabbit.remove(Position); // oh no!
    rabbit.add(new Position(1, 1)); // okay

    // also somewhere should be Workflow.update(deltatime) call on every tick
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

class Movement extends echos.System {
  // @update-function will be called for every entity that contains all the defined components;
  // All args are interpreted as components, except Float (reserved for delta time) and Int/Entity;
  @update function updateBody(pos:Position, vel:Velocity, dt:Float, entity:Entity) {
    pos.x += vel.x * dt;
    pos.y += vel.y * dt;
  }
  // Also @update-function can be defined without components,
  // so it will be called only once per system's update;
  @update function traceGrats(dt:Float) {
    trace('All the bodies was updated!');
  }
}

class Render extends echos.System {
  var scene:Array<Sprite> = [];
  // @a, @u and @r are the shortcuts for @added, @update and @removed metas;
  // @added/@removed-function are the callback called when entity is added or removed from the view;
  @a function onEntityWithSpriteAndPositionAdded(spr:Sprite, pos:Position) {
    scene.push(spr);
    trace('New entity added to the scene!');
  }
  // Even if callback was triggered by destroying the entity,
  // @removed-function will be called before this happens,
  // so access to the component will be still exists;
  @r function onEntityWithSpriteAndPositionRemoved(spr:Sprite, pos:Position, entity:Entity) {
    scene.remove(spr); // spr still not a null
    trace('Oh My God! They removed $entity!');
  }

  // The execution order of @update-functions is the same as the definition order,
  // so it is possible to do some preparations before or after iterating over entities;
  @u function beforeSpritePositionsUpdated() {
    trace('Start updating sprite positions!');
  }
  @u inline function updateSpritePosition(spr:Sprite, pos:Position) {
    spr.x = pos.x;
    spr.y = pos.y;
  }
  @u function afterSpritePositionsUpdated() {
    scene.sort((spr1, spr2) -> spr2.y - spr1.y); // sort by y-axis
  }
}

class AverageSpeedCalculator extends echos.System {
  // All of required views will be defined and initialized under the hood,
  // but it is also possible to define a View manually (initialization is still not needed)
  // for additional possibilities like counting entities;
  var bodies:View<Position, Velocity>;

  @u function calcAverageSpeed() {
    var speedSum = 0;
    bodies.iter((entity, pos, vel) -> speedSum += Math.sqrt(vel.x * vel.x + vel.y * vel.y));
    trace('Average speed is ${ speedSum / bodies.entities.length }');
  }
}
```


[Live Example](https://deepcake.github.io/echo/web/) - Tiger in the Meatdow! ([source](https://github.com/deepcake/echo/blob/master/example/TigerInTheMeatdow.hx))


#### Also
There is also exists a few additional compiler flags:
 * `-D echos_profiling` - collecting some more info in `Workflow.toString()` method for debug purposes
 * `-D echos_report` - traces a short report of built components and views
 * `-D echos_array_cc` - using Array<T> instead IntMap<T> for global component containers (wip)

#### Install
```haxelib git echos https://github.com/deepcake/echo.git```
