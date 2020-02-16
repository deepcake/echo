package echoes.utils;

class Timestep {


	var time:Float = 0;

	public function new() {
	}

	public function advance(time:Float):Void {
		this.time += time;
	}

	public function hasNext():Bool return time > 0;

	public function next():Float {
		var time:Float = time;
		this.time = 0;
		return time;
	}


}

class FixedTimestep extends Timestep {


	var tickLength:Float;

	public function new(tickLength:Float) {
		super();
		this.tickLength = tickLength;
	}

	public override function hasNext():Bool {
		return time >= tickLength;
	}

	public override function next():Float {
		if(tickLength > 0) {
			time -= tickLength;
			return tickLength;
		} else {
			return super.next();
		}
	}


}

class CappedTimestep extends Timestep {


	var tickCap:Float;

	/**
	 * This time will not be used until time advances again.
	 * Usually this means the next frame.
	 */
	var extraTime:Float = 0;

	public function new(tickCap:Float) {
		super();
		this.tickCap = tickCap;
	}

	public override function advance(time:Float):Void {
		this.time += time + extraTime;
		extraTime = 0;
	}

	public override function next():Float {
		if(time > tickCap) {
			extraTime += time - tickCap;
			time = 0;
			return tickCap;
		} else {
			return super.next();
		}
	}


}

class CappedFixedTimestep extends FixedTimestep {


	var extraTime:Float = 0;
	var tickCap:Float;

	public function new(tickLength:Float, tickCap:Float) {
		super(tickLength);
		this.tickCap = tickCap;
	}

	public override function advance(time:Float):Void {
		this.time += time + extraTime;
		extraTime = 0;
	}

	public override function next():Float {
		if(time > tickCap) {
			extraTime += time - tickCap;
			time = tickCap;
		}

		return super.next();
	}


}
