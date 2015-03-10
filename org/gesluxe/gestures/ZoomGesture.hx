package org.gesluxe.gestures;
import luxe.Vector;
import org.gesluxe.core.GestureState;
import org.gesluxe.core.Touch;

/**
 * ...
 * @author Josu Igoa
 */
class ZoomGesture extends Gesture
{
	public var slop:Float = Gesture.DEFAULT_SLOP;
	public var lockAspectRatio:Bool = true;
	
	var _touch1:Touch;
	var _touch2:Touch;
	var _transformVector:Vector;
	var _initialDistance:Float;
	public var scaleX:Float = 1;
	public var scaleY:Float = 1;

	public function new(addToManager:Bool = true) 
	{
		super(addToManager);
		
		//scaleX = scaleY = 1;
	}
	
	// --------------------------------------------------------------------------
	//
	// methods
	//
	// --------------------------------------------------------------------------
	override function onTouchBegin(touch:Touch)
	{
		if (_touchesCount > 2)
		{
			failOrIgnoreTouch(touch);
			return;
		}
		
		if (_touchesCount == 1)
		{
			_touch1 = touch;
		}
		else// == 2
		{
			_touch2 = touch;
			
			_transformVector = Vector.Subtract(_touch2.location, _touch1.location);
			_initialDistance = _transformVector.length;
		}
	}
	
	override function onTouchMove(touch:Touch)
	{
		if (_touchesCount < 2)
			return;
		
		var currTransformVector:Vector = Vector.Subtract(_touch2.location, _touch1.location);
		
		if (state == GestureState.POSSIBLE)
		{
			var d:Float = currTransformVector.length - _initialDistance;
			var absD:Float = d >= 0 ? d : -d;
			if (absD < slop)
			{
				// Not recognized yet
				return;
			}
			
			if (slop > 0)
			{
				// adjust _transformVector to avoid initial "jump"
				var slopVector:Vector = currTransformVector.clone();
				//slopVector.normalize(_initialDistance + (d >= 0 ? slop : -slop));
				_transformVector = Vector.Multiply(slopVector.normalize(), _initialDistance + (d >= 0 ? slop : -slop));
			}
		}
		
		if (lockAspectRatio)
		{
			scaleX *= currTransformVector.length / _transformVector.length;
			scaleY = scaleX;
		}
		else
		{
			scaleX *= currTransformVector.x / _transformVector.x;
			scaleY *= currTransformVector.y / _transformVector.y;
		}
		
		//_transformVector.x = currTransformVector.x;
		//_transformVector.y = currTransformVector.y;
		
		updateLocation();
		
		if (state == GestureState.POSSIBLE)
			setState(GestureState.BEGAN);
		else
			setState(GestureState.CHANGED);
	}
	
	override function onTouchEnd(touch:Touch)
	{
		if (_touchesCount == 0)
		{
			if (state == GestureState.BEGAN || state == GestureState.CHANGED)
				setState(GestureState.ENDED);
			else if (state == GestureState.POSSIBLE)
				setState(GestureState.FAILED);
		}
		else//== 1
		{
			if (touch == _touch1)
			{
				_touch1 = _touch2;
			}
			_touch2 = null;
			
			if (state == GestureState.BEGAN || state == GestureState.CHANGED)
			{
				updateLocation();
				setState(GestureState.CHANGED);
			}
		}
	}
	
	override function resetNotificationProperties()
	{
		super.resetNotificationProperties();
		
		scaleX = scaleY = 1;
	}
}