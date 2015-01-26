package examples;
import org.gesluxe.events.GestureEvent;
import org.gesluxe.gestures.SwipeGesture;

/**
 * ...
 * @author Josu Igoa
 */
class SwipeGestureExample extends ImageExample
{
	var swipe:SwipeGesture;
	
	public function new() 
	{
		swipe = new SwipeGesture(this);
		swipe.events.listen(GestureEvent.GESTURE_RECOGNIZED, onGesture);
		swipe.events.listen(GestureEvent.GESTURE_FAILED, onGestureStateChange);
		//minDistanceSlider.value = swipe.minOffset;
		//touchesSlider.value = swipe.numTouchesRequired;
		//minVelocitySlider.value = swipe.minVelocity;
		//leftCheckBox.selected = (swipe.direction & SwipeGestureDirection.LEFT) > 0;
		//rightCheckBox.selected = (swipe.direction & SwipeGestureDirection.RIGHT) > 0;
		//upCheckBox.selected = (swipe.direction & SwipeGestureDirection.UP) > 0;
		//downCheckBox.selected = (swipe.direction & SwipeGestureDirection.DOWN) > 0;
	}
	
	function onGesture(event:GestureEventData) 
	{
		visual.scale.x = (swipe.offsetX < 0 && swipe.offsetY == 0 ? -1 : 1) * Math.abs(visual.scale.x);
		var angle = 0;//event.offsetX == 0 ? (event.offsetY > 0 ? 90 : -90) : Math.atan(event.offsetY / event.offsetX) * 180 / Math.PI;
		if (swipe.offsetY != 0)
			angle = swipe.offsetY > 0 ? 90 : -90;
			
		visual.rotation_z = angle;
		//TweenMax.fromTo(arrow, 2, {alpha: 1}, {alpha: 0, ease: Sine.easeIn});
	}
	
	
	function onGestureStateChange(event:GestureEventData) 
	{
		//TweenMax.fromTo(failedGraphic, 1, {alpha: 1}, {alpha: 0, ease: Sine.easeIn});
	}
}