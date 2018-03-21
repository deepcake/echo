# Echo
[![TravisCI Build Status](https://travis-ci.org/deepcake/echo.svg?branch=master)](https://travis-ci.org/deepcake/echo)

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

    createRabbit(100, 100, 1, 1);
  }

  static function createTree(x:Float, y:Float) {
    echo.setComponent(echo.id(), 
      new Position(x, y), 
      new Sprite('assets/tree.png'));
  }
  static function createRabbit(x:Float, y:Float, vx:Float, vy:Float) {
    var id = echo.id();
    var pos = new Position(x, y);
    var vel = new Velocity(vx, vy);
    var spr = new Sprite('assets/rabbit.png');
    echo.setComponent(id, pos, vel, spr);
  }
}

// Components
class Sprite {
  // some visual component, it can be luxe.Sprite or openfl.dispaly.Sprite, for example
}

class Vec2 {
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
  @update function updateBody(pos:Position, vel:Velocity, dt:Float) {
    pos.x += vel.x * dt;
    pos.y += vel.y * dt;
  }
}

class Render extends System {
  @onadded function onVisualAdded(s:Sprite) scene.addChild(s);
  @onremoved function onVisualRemoved(s:Sprite) scene.removeChild(s);

  @update inline function updateVisuals(spr:Sprite, pos:Position) {
    spr.x = pos.x;
    spr.y = pos.y;
  }

  @update inline function afterVisualsUpdated() renderScene(); // updating sprites depth or something
}
```

[Live Example](https://deepcake.github.io/echo/web/) - Tiger in the Meatdow! (source [echo/test/Example.hx](https://github.com/deepcake/echo/blob/master/test/Example.hx))

[Live Demo](https://deepcake.github.io/chickens/bin/web/) of using Echo with Luxe and Nape (source [https://github.com/deepcake/chickens](https://github.com/deepcake/chickens))

#### Overview
* `Component` is an instance of `T:Any` class. For each `T` class, used as a component, will be generated a global `Map<Int, T>` component map.
* `Entity` in this case is just the `Int` _id_, used as a key in global component maps. Combinations of components, stored with same key, is checked by views.
* `View` is a collection of all suitable _ids_ that was added to _the workflow_. Its a data for systems;
* `System` finally is a place for do action with data (views);

#### Api
* `Echo` - something like called "Engine" in other frameworks. Entry point. _The workflow_.
  * `.id(add:Bool):Int` - creates a new _id_ and adds it to _the workflow_ (or not if `false` passed).
  * `.add(id:Int)` - adds the _id_ to _the workflow_.
  * `.poll(id:Int)` - removes the _id_ from _the workflow_ without removing its components.
  * `.remove(id:Int)` - removes the _id_ from _the workflow_ and removes all it components. If expected to use _id_ with all its components after removing from _the workflow_ - must be used `.poll()`, otherwise `.remove()`.
  * `.setComponent(id:Int, ...args:Any)` - adds/sets a components to the _id_, one or many at once. If the _id_ already has component with same type, it will be replaced.
  * `.getComponent(id:Int, type:Class<T>):T` - gets a component of the _id_ by type.
  * `.removeComponent(id:Int, type:Class<Any>)` - removes a component from the _id_ by type.
  * `.addSystem(s:System)`, `.removeSystem(s:System)` - adds/removes a system to _the workflow_.
  * `.addView(v:View)`, `.removeView(v:View)` - adds/removes a view to _the workflow_. In most cases that will not called directly, macro will do it.
* `View<T>` - generic class for views.
  * `.new()`
    ```haxe
    new View<{ a:A, b:B }>()
     // or
    typedef ABData = { var a:A; var b:B; }
    new View<ABData>()
    ```
  * `.onAdded:Signal<Int->Void>`, `.onRemoved:Signal<Int->Void>` - signals, called when a suitable _id_ is added/removed to _the workflow_. Actualy, signals are dispatchs before an id is removed (or after an id is added), so it always possible to access to the components of dispatched id.
  * `.entities:Array<Int>` - array of _ids_ collected by this view. Can be sorted.
  * `.iterator():Iterator<T>` - produce iterating over _ids_ like they was an instances of `T` (with minimal overhead).
* `System` - parent class for systems.
  * `.onactivate()`, `.ondeactivate()` - to be overridden. Called when this system is added/removed to _the workflow_.
  * `.update(dt:Float)` - to be overridden.
  * `@update`, `@upd`, `@u` - meta that calls a tagged function for each entity in view's iterating cycle. To tagged function must be passed all components of associated view (or nothing at all). If a suitable view will be not found, new one will be defined. If tagged function is not have any argument, it will be called before/after (depends on define order) view's iterating cycle.
    ```haxe
    @update function update_ab(a:A, b:B) trace(a, b);
    @update function after_ab() trace("Bye!");
     // equals to
    var view_ab:View<{ a:A, b:B }>;
    override function update(dt:Float) {
      for (v in view_ab) update_ab(v.a, v.b);
      after_ab();
    }
    ```
      To a tagged function can be passed an optional args - `Float` arg for delta time and `Int` arg for id:
    ```haxe
    @update function update_ab(a:A, b:B, dt:Float, id:Int) trace(a, b);
    ```
  * `@onadded`, `@add`, `@a` - meta that adds a tagged function to the `onAdded` view's signal.
  * `@onremoved`, `@rem`, `@r` - meta that adds a tagged function to the `onRemoved` view's signal. To tagged function can be passed an `Int` id, any components of associated view, or nothing.
    ```haxe
    var view_ab:View<{ a:A, b:B }>;
    @onadded function onadd_ab(id:Int) trace(echo.getComponent(id, A));
     // equals to
    override function onactivate() {
      view_ab.onAdded.add(onadd_ab);
    }
    override function ondeactivate() {
      view_ab.onAdded.remove(onadd_ab);
    }
    ```
      It is possible to pass a view name or index (starts from 0) to the `@onadded`/`@onremoved` meta (if system contains more then single view):
    ```haxe
    var view_a:View<{ a:A }>; // index 0
    var view_b:View<{ b:B }>; // index 1
    @onadded("view_a") function onadd_a(id:Int) trace(echo.getComponent(id, A));
    @onadded(1) function onadd_b(id:Int) trace(echo.getComponent(id, B));
    ```
      So it is also possible to use `@onadded` meta with `@update` meta like:
    ```haxe
    @update function update_a(a:A) trace(a); // index 0
    @update function update_b(b:A) trace(b); // index 1
    @onadded function onadd_a(a:A) trace(a); // index 0 can be omitted
    @onadded(1) function onadd_b() trace("B!");
    ```
  * `@skip`, `@ignore` - all views defined in the system without `@skip` meta will be added to _the workflow_. Also `@skip` meta can be used to drop other metas from execution:
    ```haxe
    @skip @update function update_a(a:A) trace(a); // nothing
    ```

There is also exists a few additional compiler flags:
 * `-D echo_verbose` - traces to console all generated classes (for debug purposes)
 * `-D echo_debug` - collecting some more info for `toString()` method (note, that it uses reflection, so better to remove it in release build)

#### Install
```haxelib git echo https://github.com/deepcake/echo.git```

#### Wip
Work in progress, breaking changes are possible
