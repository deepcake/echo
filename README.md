# Echo
[![TravisCI Build Status](https://travis-ci.org/deepcake/echo.svg?branch=master)](https://travis-ci.org/deepcake/echo)

Super lightweight Entity Component System framework for Haxe. 
Initially created to learn the power of macros. 
Focused on quick and easy use. 
Inspired by other haxe ECS frameworks, especially [EDGE](https://github.com/fponticelli/edge), [ECX](https://github.com/eliasku/ecx), [ESKIMO](https://github.com/PDeveloper/eskimo) and [Ash-Haxe](https://github.com/nadako/Ash-Haxe)

#### Wip

### Overview
 * Component is an instance of `T:Any` class. For each class `T` will be generated a global component container, where instance of `T` is a value and `Entity` is a key. 
 * `Entity` in that case is just an abstract over the `Int`, but with the ability to work with it as with a set of components like in other regular ECS frameworks. 
 * `View<T>` is a collection of entities containing all of the required components of the requested types. Views are usually placed on Systems. 
 * `System` is a macro powered place for main logic. 

#### Example
```haxe
import echoes.SystemList;
import echoes.Workflow;
import echoes.Entity;

class Example {
  static function main() {
    // for better control, you can use the system lists
    var physics = new SystemList()
      .add(new Movement())
      .add(new CollisionResolver());

    Workflow.addSystem(physics);
    Workflow.addSystem(new Render()); // or just add systems directly

    var rabbit = createRabbit(0, 0, 1, 1);

    trace(rabbit.exists(Position)); // true
    trace(rabbit.get(Position).x); // 100
    rabbit.remove(Position); // oh no!
    rabbit.add(new Position(1, 1)); // okay

    // also somewhere should be update call on every tick
    Workflow.update(0);
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

class Movement extends echoes.System {
  // @update-functions will be called for every entity that contains all the defined components;
  // All args are interpreted as components, except Float (reserved for delta time) and Int/Entity;
  @update function updateBody(pos:Position, vel:Velocity, dt:Float, entity:Entity) {
    pos.x += vel.x * dt;
    pos.y += vel.y * dt;
  }
  // If @update-functions are defined without components, 
  // they are called only once per system's update;
  @update function traceHello(dt:Float) {
    trace('Hello!');
  }
  // The execution order of @update-functions is the same as the definition order, 
  // so you can perform some preparations before or after iterating over entities;
  @update function traceWorld() {
    trace('World!');
  }
}

class DestroySlowest extends echoes.System {
  // All of necessary for meta-functions views will be defined and initialized under the hood, 
  // but it is also possible to define the View manually (initialization is still not required) 
  // for additional features such as counting and sorting entities;
  var bodies:View<Position, Velocity>;

  @u function destroySlowest() {
    bodies.entities.sort((e1, e2) -> speed(e2.get(Velocity)) - speed(e1.get(Velocity)));
    trace('Last of ${ bodies.entities.length } is destroyed!');
    bodies.entities.tail.value.destroy();
  }
  function speed(vel:Velocity) {
    return Std.int(Math.sqrt(vel.x * vel.x + vel.y * vel.y));
  }
}

class Render extends echoes.System {
  var scene:Array<Sprite> = [];
  // There are @a, @u and @r shortcuts for @added, @update and @removed metas;
  // @added/@removed-functions are callbacks that are called when an entity is added/removed from the view;
  @a function onEntityWithSpriteAndPositionAdded(spr:Sprite, pos:Position) {
    scene.push(spr);
  }
  // Even if callback was triggered by destroying the entity, 
  // @removed-function will be called before this happens, 
  // so access to the component will be still exists;
  @r function onEntityWithSpriteAndPositionRemoved(spr:Sprite, pos:Position, entity:Entity) {
    scene.remove(spr); // spr is still not a null
    trace('Oh My God! They removed $entity!');
  }
  @u inline function updateSpritePosition(spr:Sprite, pos:Position) {
    spr.x = pos.x;
    spr.y = pos.y;
  }
  @u inline function afterSpritePositionsUpdated() {
    // rendering...
  }
}
```

#### Live
[Tiger on the Meadow!](https://deepcake.github.io/tiger_on_the_meadow/bin/) ([source](https://github.com/deepcake/tiger_on_the_meadow)) - small example of using Echo framework 

### Also
There is also exists a few additional compiler flags:
 * `-D echoes_profiling` - collecting some more info in `Workflow.info()` method for debug purposes
 * `-D echoes_report` - traces a short report of built components and views
 * `-D echoes_array_container` - using Array<T> instead IntMap<T> for global component containers

### Install
```haxelib git echoes https://github.com/deepcake/echo.git```
