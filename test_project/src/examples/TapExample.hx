package examples;
import org.gesluxe.events.GestureEvent;
import org.gesluxe.gestures.TapGesture;

/**
 * ...
 * @author Josu Igoa
 */
class TapExample extends ImageExample
{
	var tap:TapGesture;

	public function new() 
	{
		super();
		
	}
	
	override function texture_loaded(_) 
	{
		super.texture_loaded(_);
		
		tap = new TapGesture();
		tap.events.listen(GestureEvent.GESTURE_RECOGNIZED, onTap);
	}
	
	function onTap(event:GestureEventData)
	{
		visual.color.a = (visual.color.a == 1) ? .5 : 1;
	}
}