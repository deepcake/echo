package echoes.utils;

/**
 * A timestep determines how to split up chunks of time.
 * Think of it like a wind-up clock. When you wind it up,
 * it will tick one or more times as it unwinds.
 * 
 * "Winding" a timestep is done with the `advance()`
 * function, where you enter in a certain amount of time.
 * "Unwinding" a timestep is done with a `for()` loop:
 * `for(tick in timestep) { ... }`. When the loop
 * completes, the timestep is finished unwinding.
 * 
 * By default, timesteps only tick once. You enter an
 * amount of time, and they return that entire value.
 * 
 * Subclasses use the decorator pattern to allow more
 * customization. You can use this to combine subclasses,
 * applying a cap from `CappedTimestep`, the fixed ticks
 * from `FixedTimestep`, and/or the speed adjustment from
 * `ScaledTimestep`. To combine subclasses, create an
 * instance of each, passing the last-created instance to
 * the next constructor.
 */
class Timestep {


	var time:Time;

	var nextTimestep:Null<Timestep>;

	/**
	 * While paused, time cannot be added to a `Timestep`.
	 * If time was already added, iteration will continue
	 * as normal.
	 */
	public var paused:Bool = false;

	public function new(?nextTimestep:Timestep) {
		this.nextTimestep = nextTimestep;
		time = nextTimestep != null ? nextTimestep.time : new Time();
	}

	public function advance(time:Float):Void {
		if(!paused) {
			if(nextTimestep != null) {
				nextTimestep.advance(time);
			} else {
				this.time.left += time;
			}
		}
	}

	public function hasNext():Bool {
		if(nextTimestep != null) {
			return nextTimestep.hasNext();
		} else {
			return time.left > 0;
		}
	}

	public function next():Float {
		if(nextTimestep != null) {
			return nextTimestep.next();
		} else {
			var time:Float = this.time.left;
			this.time.left = 0;
			return time;
		}
	}


}

private class Time {
	public var left:Float = 0;

	public inline function new() {
	}
}

/**
 * Each tick from a fixed timestep is exactly the same
 * length. This is useful for physics simulations,
 * which tend to require consistency.
 * 
 * Usually, a fixed timestep will have a little time
 * left over at the end of the frame, not quite enough
 * for another tick. This time is saved until the next
 * frame, and may cause some frames to advance farther
 * than others.
 * 
 * This class is incompatible with any other class that
 * overrides `next()`. (No other class defined in
 * Timestep.hx does so.)
 */
class FixedTimestep extends Timestep {


	public var tickLength:Float;

	public function new(tickLength:Float, ?nextTimestep:Timestep) {
		super(nextTimestep);
		this.tickLength = tickLength;
	}

	public override function hasNext():Bool {
		return super.hasNext() && time.left >= tickLength;
	}

	public override function next():Float {
		if(tickLength > 0) {
			time.left -= tickLength;
			return tickLength;
		} else {
			return super.next();
		}
	}


}

/**
 * A capped timestep limits how much time can elapse in
 * one frame. This helps in cases of extreme lag, or in
 * cases where a device goes to sleep for hours.
 * 
 * Capped timesteps go well with fixed timesteps. Without
 * a cap, a fixed timestep could tick dozens if not
 * hundreds of times after a particularly laggy frame.
 * Processing all those ticks would, of course, create
 * even more lag. A cap would limit the number of ticks
 * dispatched, and hopefully prevent any viscious spirals.
 */
class CappedTimestep extends Timestep {


	public var tickCap:Float;

	public function new(tickCap:Float, ?nextTimestep:Timestep) {
		super(nextTimestep);
		this.tickCap = tickCap;
	}

	public override function advance(time:Float):Void {
		super.advance(time);
		if(this.time.left > tickCap) {
			this.time.left = tickCap;
		}
	}


}

/**
 * A scaled timestamp multiplies all elapsed time.
 * Depending on the multiplier, this can speed time up,
 * slow it down, pause it, or reverse it. (Caution:
 * reversing time may create edge cases.)
 */
class ScaledTimestep extends Timestep {


	public var scale:Float;

	public function new(scale:Float = 1, ?nextTimestep:Timestep) {
		super(nextTimestep);
		this.scale = scale;
	}

	public override function advance(time:Float):Void {
		super.advance(time * scale);
	}


}
