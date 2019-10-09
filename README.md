# Echo
[![TravisCI Build Status](https://travis-ci.org/deepcake/echo.svg?branch=master)](https://travis-ci.org/deepcake/echo)

Super lightweight Entity Component System framework for Haxe. 
Initially created to learn the power of macros. 
Focused to be simple and fast. 
Inspired by other haxe ECS frameworks, especially [EDGE](https://github.com/fponticelli/edge), [ECX](https://github.com/eliasku/ecx), [ESKIMO](https://github.com/PDeveloper/eskimo) and [Ash-Haxe](https://github.com/nadako/Ash-Haxe)

#### Wip

### Overview
 * Component is an instance of `T:Any` class. For each class `T` will be generated a global component container, where instance of `T` is a value and `Entity` is a key. 
 * `Entity` in that case is just an abstract over the `Int`, but with the ability to work with it as with a set of components like in other regular ECS frameworks. 
 * `View<T1, T2, TN>` is a collection of entities containing all components of the required types `T1, T2, TN`. Views are placed in Systems. 
 * `System` is a place for processing a certain set of data represented by views. 
 * To organize systems in phases can be used the `SystemList`. 

#### Example
```haxe
import echoes.SystemList;
import echoes.Workflow;
import echoes.Entity;

class Example {
  static function main() {
    var physics = new SystemList()
      .add(new Movement())
      .add(new CollisionResolver());

    Workflow.addSystem(physics);
    Workflow.addSystem(new Render()); // or just add systems directly

    var john = createRabbit(0, 0, 1, 1, 'John');
    var jack = createRabbit(5, 5, 1, 1, 'Jack');

    trace(jack.exists(Position)); // true
    trace(jack.get(Position).x); // 5
    jack.remove(Position); // oh no!
    jack.add(new Position(1, 1)); // okay

    // also somewhere should be Workflow.update call on every tick
    Workflow.update(1.0);
  }
  static function createTree(x:Float, y:Float) {
    return new Entity()
      .add(new Position(x, y))
      .add(new Sprite('assets/tree.png'));
  }
  static function createRabbit(x:Float, y:Float, vx:Float, vy:Float, name:Name) {
    var pos = new Position(x, y);
    var vel = new Velocity(vx, vy);
    var spr = new Sprite('assets/rabbit.png');
    return new Entity().add(pos, vel, spr, name);
  }
}

@:forward
abstract Name(String) from String to String {
  public function new(name:String) this = name;
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

class NamePrinter extends echoes.System {
  // All of necessary for meta-functions views will be defined and initialized under the hood, 
  // but it is also possible to define the View manually (initialization is still not required) 
  // for additional features such as counting and sorting entities;
  var named:View<Name>;

  @update function sortAndPrint() {
    bodies.entities.sort((e1, e2) -> e1.get(Name) < e2.get(Name) ? -1 : 1);
    // using Lambda
    bodies.entities.iter(e -> trace(e.get(Name)));
  }
}

class Render extends echoes.System {
  var scene:DisplayObjectContainer;
  // There are @a, @u and @r shortcuts for @added, @update and @removed metas;
  // @added/@removed-functions are callbacks that are called when an entity is added/removed from the view;
  @a function onEntityWithSpriteAndPositionAdded(spr:Sprite, pos:Position) {
    scene.addChild(spr);
  }
  // Even if callback was triggered by destroying the entity, 
  // @removed-function will be called before this happens, 
  // so access to the component will be still exists;
  @r function onEntityWithSpriteAndPositionRemoved(spr:Sprite, pos:Position, e:Entity) {
    scene.removeChild(spr); // spr is still not a null
    trace('Oh My God! They removed ${ e.exists(Name) ? e.get(Name) : "Unknown Sprite" }!');
  }
  @u inline function updateSpritePosition(spr:Sprite, pos:Position) {
    spr.x = pos.x;
    spr.y = pos.y;
  }
  @u inline function afterSpritePositionsUpdated() {
    // rendering, etc
  }
}
```

#### Live
[Tiger on the Meadow!](https://deepcake.github.io/tiger_on_the_meadow/bin/) ([source](https://github.com/deepcake/tiger_on_the_meadow)) - small example of using Echo framework 

#### Also
There is also exists a few additional compiler flags:
 * `-D echoes_profiling` - collecting some more info in `Workflow.info()` method for debug purposes
 * `-D echoes_report` - traces a short report of built components and views
 * `-D echoes_array_container` - using Array<T> instead IntMap<T> for global component containers

### Install
```haxelib git echoes https://github.com/deepcake/echo.git```
