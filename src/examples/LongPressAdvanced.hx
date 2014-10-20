package examples;
import luxe.Vector;
import org.gesluxe.core.GestureState;
import org.gesluxe.events.GestureEvent;
import org.gesluxe.gestures.LongPressGesture;

/**
 * ...
 * @author Josu Igoa
 */
class LongPressAdvanced extends ImageExample
{
	var longPressGesture:LongPressGesture;
	var fingerToImageOffset:Vector;

	public function new() 
	{
		super();
	}
	
	override function texture_loaded(_) 
	{
		super.texture_loaded(_);
		
		longPressGesture = new LongPressGesture();
		longPressGesture.events.listen(GestureEvent.GESTURE_STATE_CHANGE, onGesture);
		
		fingerToImageOffset = new Vector();
	}
	
	function onGesture(event:GestureEventData)
	{
		var loc = longPressGesture.location;
		switch (event.newState)
		{
			case GestureState.BEGAN:
				//initialTransform = image.transform.matrix;
				//TweenMax.to(image, 0.5, {alpha: 0.5, glowFilter: {color: 0xEEEEEE * Math.random(), blurX: 16, blurY: 16, strength: 2, alpha: 1}});
				//fingerToImageOffset.x = image.x - loc.x;
				//fingerToImageOffset.y = image.y - loc.y;
			case GestureState.CHANGED:
				//image.move(fingerToImageOffset.x + loc.x, fingerToImageOffset.y + loc.y);
			case GestureState.ENDED:
				//TweenMax.to(image, 1, {alpha: 1, glowFilter: {alpha: 0, remove: true}});
			case GestureState.CANCELLED:
				//TweenMax.to(image, 0, {alpha: 1, glowFilter: {alpha: 0, remove: true}});
				//image.transform.matrix = initialTransform;
		}
	}
}