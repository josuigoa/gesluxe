package examples;
import luxe.Visual;
import org.gesluxe.events.GestureEvent;
import org.gesluxe.gestures.RotateGesture;
import phoenix.Texture;

/**
 * ...
 * @author Josu Igoa
 */
class RotateGestureExample extends ImageExample
{
	var rotate:RotateGesture;
	
	public function new() 
	{
		super();
	}
	
	override function texture_loaded(_) 
	{
		super.texture_loaded(_);
		
		rotate = new RotateGesture();
		rotate.events.listen(GestureEvent.GESTURE_BEGAN, onGesture);
		rotate.events.listen(GestureEvent.GESTURE_CHANGED, onGesture);
	}
	
	function onGesture(event:GestureEventData) 
	{
		visual.radians = rotate.rotation;
	}
}