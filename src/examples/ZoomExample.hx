package examples;
import org.gesluxe.events.GestureEvent;
import org.gesluxe.gestures.ZoomGesture;

/**
 * ...
 * @author Josu Igoa
 */
class ZoomExample extends ImageExample
{
	var zoom:ZoomGesture;

	public function new() 
	{
		super();
	}
	
	override function texture_loaded(_) 
	{
		super.texture_loaded(_);
		
		zoom = new ZoomGesture();
		zoom.events.listen(GestureEvent.GESTURE_BEGAN, onGesture);
		zoom.events.listen(GestureEvent.GESTURE_CHANGED, onGesture);
	}
	
	function onGesture(event:GestureEventData) 
	{
		visual.scale.set_xy(zoom.scaleX, zoom.scaleY);
	}
}