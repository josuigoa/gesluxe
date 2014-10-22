package org.gesluxe.gestures;
import luxe.Timer;
import org.gesluxe.core.GestureState;
import org.gesluxe.core.Touch;

/**
 * ...
 * @author Josu Igoa
 */
class LongPressGesture extends Gesture
{
	public var numTouchesRequired:UInt = 1;
	/**
	 * The minimum time interval in millisecond fingers must press on the target for the gesture to be recognized.
	 * 
	 * @default 500
	 */
	public var minPressDuration:UInt = 500;
	public var slop:Float = Gesture.DEFAULT_SLOP;
	
	var _timer:Timer;
	var _numTouchesRequiredReached:Bool;

	public function new() 
	{
		super();
		
	}
	
	// --------------------------------------------------------------------------
	//
	// Public methods
	//
	// --------------------------------------------------------------------------
	
	override public function reset()
	{
		super.reset();
		
		_numTouchesRequiredReached = false;
		_timer.reset();
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
		//_timer.addEventListener(TimerEvent.TIMER_COMPLETE, timer_timerCompleteHandler);
		//_timer.schedule(minPressDuration/1000, timerCompleteHandler);
	}
	
	
	override function onTouchBegin(touch:Touch)
	{
		if (_touchesCount > numTouchesRequired)
		{
			failOrIgnoreTouch(touch);
			return;
		}
		
		if (_touchesCount == numTouchesRequired)
		{
			_numTouchesRequiredReached = true;
			_timer.reset();
			_timer.schedule(minPressDuration / 1000, timerCompleteHandler);
			
		}
	}
	
	override function onTouchMove(touch:Touch)
	{
		if (state == GestureState.POSSIBLE && slop > 0 && touch.locationOffset.length > slop)
			setState(GestureState.FAILED);
		else if (state == GestureState.BEGAN || state == GestureState.CHANGED)
		{
			updateLocation();
			setState(GestureState.CHANGED);
		}
	}
	
	
	override function onTouchEnd(touch:Touch)
	{
		if (_numTouchesRequiredReached)
		{
			if (state == GestureState.BEGAN || state == GestureState.CHANGED)
			{
				updateLocation();
				setState(GestureState.ENDED);
			}
			else
				setState(GestureState.FAILED);
		}
		else
			setState(GestureState.FAILED);
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
			updateLocation();
			setState(GestureState.BEGAN);
		}
	}
}