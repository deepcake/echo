# Echo
[![TravisCI Build Status](https://travis-ci.org/wimcake/echo.svg?branch=master)](https://travis-ci.org/wimcake/echo)

Super lightweight Entity Component System framework for Haxe. 
Focused to be simple and perfomant.
Inspired by other haxe ECS frameworks, especially [EDGE](https://github.com/fponticelli/edge), [ECX](https://github.com/eliasku/ecx), [ESKIMO](https://github.com/PDeveloper/eskimo) and more classic [Ash-Haxe](https://github.com/nadako/Ash-Haxe) (check out it for understanding basic principles of ECS).

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
    createRabbit(100, 100, 0, 0);
  }

  static function createTree(x:Float, y:Float) {
    echo.setComponent(echo.id(), 
      new Position(x, y), 
      new Sprite('assets/tree.png'));
  }
  static function createRabbit(x:Float, y:Float, vx:Float, vy:Float) {
    var id = echo.id();
    addDynamic(id, x, y, vx, vy);
    echo.setComponent(id, new Sprite('assets/rabbit.png'));
    echo.setComponent(id, new Ears());
  }
  // sort of entity decorator
  static function addDynamic(id:Int, x:Float, y:Float, vx:Float, vy:Float) {
    var pos = new Position(x, y);
    var vel = new Velocity(vx, vy);
    echo.setComponent(id, pos, vel);
  }
}

// Components
class Sprite {
  // some visual component, it can be luxe.Sprite or openfl.dispaly.Sprite, for example
}

class Vec2 {
  // some vector 2d implementation
  // abstracts can be used to create different ComponentClass'es from the same BaseClass without overhead
}

@:forward(x, y)
abstract Velocity(Vec2) { 
  inline public function new(?x:Float, ?y:Float) this = new Vec2(x, y);
}
@:forward(x, y)
abstract Position(Vec2) {
  inline public function new(?x:Float, ?y:Float) this = new Vec2(x, y);
}

// Systems
class Movement extends System {
  var bodies:View<{ pos:Position, vel:Velocity }>;
  override public function update(dt:Float) {
    for (body in bodies) {
      body.pos.x += body.vel.x * dt;
      body.pos.y += body.vel.y * dt;
    }
  }
}

class Render extends System {
  var visuals:View<{ pos:Position, spr:Sprite }>;
  function onVisualAdded(id:Int) {
    var sprite = echo.getComponent(id, Sprite);
    scene.addChild(sprite);
  }
  function onVisualRemoved(id:Int) {
    var sprite = echo.getComponent(id, Sprite);
    scene.removeChild(sprite);
  }
  override public function onactivate() {
    visuals.onAdded.add(onVisualAdded);
    visuals.onRemoved.add(onVisualRemoved);
  }
  override public function update(dt:Float) {
    for (v in visuals) {
      v.spr.x = v.pos.x;
      v.spr.y = v.pos.y;
    }
  }
}
```

[See web demo](https://wimcake.github.io/echo/web/) (source at [echo/test/Example.hx](https://github.com/wimcake/echo/blob/master/test/Example.hx))

#### Overview
* `Component` is an instance of `T:Any`. For each class `T`, used as a component, will be generated a global `Map<Int, T>` component map.
* `Entity` is just the `Int` _id_, using as a key in global component maps.
* `View` is a collection of suitable _ids_.
* `System` is a place to work with views with some features.

#### Api
* `Echo` - something like called `Engine` in other frameworks. Entry point. _The workflow_.
  * `.id():Int` - creates and adds a new _id_ to _the workflow_.
  * `.next():Int` - creates a new _id_ without adding it to _the workflow_.
  * `.add(id:Int)` - adds _id_ to _the workflow_.
  * `.poll(id:Int)` - removes _id_ from _the workflow_ without removing its components.
  * `.remove(id:Int)` - removes _id_ from _the workflow_ and removes all it components. If expected to use _id_ with all its components after removing from _the workflow_ - must be used `#poll()`, otherwise `#remove()`.
  * `.setComponent(id:Int, ...args:Any)` - adds/sets components to the _id_, one or many at once.
  * `.getComponent(id:Int, type:Class<T>):T` - gets component of the _id_ by type.
  * `.removeComponent(id:Int, type:Class<Any>)` - removes component from _id_ by type.
  * `.addSystem`, `.removeSystem(system:System)` - adds/removes system from _the workflow_.
  * `.addView`, `.removeView` - adds/removes view from _the workflow_. In most cases that will not called directly, macro will do it.
* `View<T>` - generic class for views.
  * `.onAdded`, `.onRemoved:Signal<Int->Void>` - signals, called on a suitable _id_ is added/removed to _the workflow_. Actualy, signals is dispatch before id is removed (or after id is added), so it always possible to access to components of dispatched id.
  * `.entities:Array<Int>` - array of _ids_ into this view. Can be sorted.
  * `.iterator():Iterator<T>` - produce iterating over _ids_ like they was an instances of `T` with minimal overhead.
* `System` - all views that defined in the system (without `@skip` meta) will be added to the workflow.
  * `.onactivate()`, `.ondeactivate()` - to be overridden. Called on added/removed from _the workflow_.
  * `.update(dt:Float)` - to be overridden.
  * `@skip`, `@ignore` - saves the view from adding to _the workflow_.
    ```haxe
    @skip var view = new View<{ a:A }>();
    // nothing :-)
    ```
  * `@onadded`, `@add`, `@a` - meta that adds a function to the `onAdd` view signal.
  * `@onremoved`, `@rem`, `@r` - meta that adds a function to the `onRemove` view signal.
    ```haxe
    var view_ab:View<{ a:A, b:B }>;
    @onadded function onadd_ab(id:Int) trace(echo.getComponent(id, A));
    ```
      converts to:
    ```haxe
    override function onactivate() {
      view_ab.onAdded.add(onadd_ab);
    }
    override function ondeactivate() {
      view_ab.onAdded.remove(onadd_ab);
    }
    ```
      It also possible to pass a view name or index (starts from `0`) to the onadded/onremoved meta, if system contains more then one view:
    ```haxe
    var view_a:View<{ a:A }>; // index 0
    var view_b:View<{ b:B }>; // index 1
    @onadded("view_a") function onadd_a(id:Int) trace(echo.getComponent(id, A));
    @onadded(1) function onadd_b(id:Int) trace(echo.getComponent(id, B));
    ```
  * `@update`, `@upd`, `@u` - meta that calls a function for each view's entity. If a suitable view will be not found, new one will be defined.
    ```haxe
    @update function update_ab(a:A, b:B) trace(a, b);
    // Int and Float types are reserved for delta time and id
    // @update function update_ab(a:A, b:B, delta:Float, id:Int) trace(a, b);
    ```
      converts to:
    ```haxe
    var view_ab:View<{ a:A, b:B }>;
    override function update(dt:Float) {
      for (v in view_ab) update_ab(v.a, v.b);
    }
    ```

So code from the example above can be written with meta like this:
```haxe
class Render extends System {
  @onadd function onVisualAdded(id:Int) {
    var sprite = echo.getComponent(id, Sprite);
    scene.addChild(sprite);
  }
  @onremove function onVisualRemoved(id:Int) {
    var sprite = echo.getComponent(id, Sprite);
    scene.removeChild(sprite);
  }
  @oneach function updateVisuals(spr:Sprite, pos:Position, dt:Float) {
    spr.x = pos.x;
    spr.y = pos.y;
  }
}
```

#### Install
```haxelib git echo https://github.com/wimcake/echo.git```

#### Wip
Work in progress, with all its concomitant effects
