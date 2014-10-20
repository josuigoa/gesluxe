package examples;
import luxe.tween.Actuate;
import org.gesluxe.events.GestureEvent;
import org.gesluxe.gestures.TapGesture;

/**
 * ...
 * @author Josu Igoa
 */
class TapGestureUsage extends ImageExample
{
	var doubleTapGesture:TapGesture;
	var twoFingerTapGesture:TapGesture;

	public function new() 
	{
		super();
	}
	
	override function texture_loaded(_) 
	{
		super.texture_loaded(_);
		
		doubleTapGesture = new TapGesture();
		doubleTapGesture.numTapsRequired = 2;
		doubleTapGesture.events.listen(GestureEvent.GESTURE_RECOGNIZED, onGesture);
		
		twoFingerTapGesture = new TapGesture();
		twoFingerTapGesture.numTouchesRequired = 2;
		twoFingerTapGesture.events.listen(GestureEvent.GESTURE_RECOGNIZED, onGesture);
	}
	
	function onGesture(event:GestureEventData) 
	{
		var scale:Float;
		
		if (event.gesture == doubleTapGesture)
			scale = visual.scale.x * 1.2;
		else
			scale = visual.scale.x / 1.2;
		
		Actuate.tween(visual.scale, 0.3, {
				x: scale,
				y: scale
				});
	}
	
}