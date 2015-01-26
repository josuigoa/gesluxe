package examples;
import org.gesluxe.events.GestureEvent;
import org.gesluxe.gestures.LongPressGesture;

/**
 * ...
 * @author Josu Igoa
 */
class LongPressExample
{
	var longPressGesture:LongPressGesture;

	public function new() 
	{
		longPressGesture = new LongPressGesture();
		long.events.listen(GestureEvent.GESTURE_BEGAN, onGesture);
		
		//slopSlider.value = longPressGesture.slop;
		//touchesSlider.value = longPressGesture.numTouchesRequired;
		//pressDurationSlider.value = longPressGesture.minPressDuration;
	}
	
	function onGesture(event:GestureEventData) 
	{
		
	}
}