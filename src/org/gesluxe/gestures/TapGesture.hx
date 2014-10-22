package org.gesluxe.gestures;
import luxe.Timer;
import luxe.Vector;
import org.gesluxe.core.GestureState;
import org.gesluxe.core.Touch;
import org.gesluxe.utils.GestureUtils;

/**
 * ...
 * @author Josu Igoa
 */
class TapGesture extends Gesture
{
	public var numTouchesRequired:UInt = 1;
	public var numTapsRequired:UInt = 1;
	public var slop:Float = Gesture.DEFAULT_SLOP << 2;//iOS has 45px for 132 dpi screen
	public var maxTapDelay:UInt = 400;
	public var maxTapDuration:UInt = 1500;
	public var maxTapDistance:Float = Gesture.DEFAULT_SLOP << 2;
	
	var _timer:Timer;
	var _numTouchesRequiredReached:Bool;
	var _tapCounter:UInt = 0;
	var _touchBeginLocations:Array<Vector>;

	public function new() 
	{
		super();
		
		_touchBeginLocations = new Array<Vector>();
		canPreventGesture = can_prevent_gesture;
	}
	
	// --------------------------------------------------------------------------
	//
	// Public methods
	//
	// --------------------------------------------------------------------------
	
	override public function reset()
	{
		_numTouchesRequiredReached = false;
		_tapCounter = 0;
		_timer.reset();
		GestureUtils.clearArray(_touchBeginLocations);
		
		super.reset();
	}
	
	function can_prevent_gesture(preventedGesture:Gesture):Bool
	{
		if (Std.is(preventedGesture, TapGesture) && cast(preventedGesture, TapGesture).numTapsRequired > this.numTapsRequired)
			return false;
		
		return true;
	}
	
	// --------------------------------------------------------------------------
	//
	// Protected methods
	//
	// --------------------------------------------------------------------------
	
	override function preinit()
	{
		super.preinit();
		
		_timer = new Timer(Luxe.core);
		//_timer.schedule(maxTapDelay/1000, timerCompleteHandler);
		//_timer.addEventListener(TimerEvent.TIMER_COMPLETE, timer_timerCompleteHandler);
	}
	
	
	override function onTouchBegin(touch:Touch)
	{
		if (_touchesCount > numTouchesRequired)
		{
			failOrIgnoreTouch(touch);
			return;
		}
		
		if (_touchesCount == 1)
		{
			_timer.reset();
			_timer.schedule(maxTapDuration/1000, timerCompleteHandler);
		}
		
		if (numTapsRequired > 1)
		{
			if (_tapCounter == 0)
			{
				// Save touch begin locations to check
				_touchBeginLocations.push(touch.location);
			}
			else
			{
				// Quite a dirty check, but should work in most cases
				var found:Bool = false;
				for (loc in _touchBeginLocations)
				{
					// current touch should be near any previous one
					if (GestureUtils.distance(touch.location, loc) <= maxTapDistance)
					{
						found = true;
						break;
					}
				}

				if (!found)
				{
					setState(GestureState.FAILED);
					return;
				}
			}
		}
		
		if (_touchesCount == numTouchesRequired)
		{
			_numTouchesRequiredReached = true;
			updateLocation();
		}
	}
	
	
	override function onTouchMove(touch:Touch)
	{
		if (slop >= 0 && touch.locationOffset.length > slop)
		{
			setState(GestureState.FAILED);
		}
	}
	
	
	override function onTouchEnd(touch:Touch)
	{
		if (!_numTouchesRequiredReached)
		{
			setState(GestureState.FAILED);
		}
		else if (_touchesCount == 0)
		{
			// reset flag for the next "full press" cycle
			_numTouchesRequiredReached = false;
			
			_tapCounter++;
			_timer.reset();
			//trace("_tapCounter: " + _tapCounter);
			//trace("numTapsRequired: " + numTapsRequired);
			
			if (_tapCounter == numTapsRequired)
			{
				setState(GestureState.RECOGNIZED);
			}
			else
				_timer.schedule(maxTapDelay/1000, timerCompleteHandler);
		}
	}
	
	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------
	
	function timerCompleteHandler()
	{
		if (state == GestureState.POSSIBLE)
		{
			setState(GestureState.FAILED);
		}
	}
}