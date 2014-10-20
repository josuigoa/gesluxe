package examples;
import org.gesluxe.events.GestureEvent;
import org.gesluxe.gestures.TransformGesture;

/**
 * ...
 * @author Josu Igoa
 */
class TransformExample extends ImageExample
{
	var transformGesture:TransformGesture;
	
	public function new() 
	{
		super();
	}
	
	override function texture_loaded(_) 
	{
		super.texture_loaded(_);
		
		transformGesture = new TransformGesture();
		transformGesture.events.listen(GestureEvent.GESTURE_BEGAN, onGesture);
		transformGesture.events.listen(GestureEvent.GESTURE_CHANGED, onGesture);
	}
	
	function onGesture(event:GestureEventData) 
	{
		// Panning
		visual.pos.set_xy(transformGesture.offsetX, transformGesture.offsetY);
		
		if (transformGesture.scale != 1 || transformGesture.rotation != 0)
		{
			// Scale and rotation.
			visual.radians = transformGesture.rotation;
			visual.scale.set_xy(transformGesture.scale, transformGesture.scale);
		}
	}
}