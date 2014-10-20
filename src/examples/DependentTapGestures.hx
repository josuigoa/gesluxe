package examples;
import org.gesluxe.events.GestureEvent;
import org.gesluxe.gestures.TapGesture;

/**
 * ...
 * @author Josu Igoa
 */
class DependentTapGestures
{
	var singleTapGesture:TapGesture;
	var doubleTapGesture:TapGesture;

	public function new() 
	{
		singleTapGesture = new TapGesture();
		singleTapGesture.events.listen(GestureEvent.GESTURE_RECOGNIZED, onGesture);
		
		doubleTapGesture = new TapGesture();
		doubleTapGesture.events.listen(GestureEvent.GESTURE_RECOGNIZED, onGesture);
		// probably you want to set a bit smaller value for maxTapDelay
		// so double tap will fail a bit more quickly. default is 400ms
		doubleTapGesture.maxTapDelay = 300;
		doubleTapGesture.numTapsRequired = 2;
		
		singleTapGesture.requireGestureToFail(doubleTapGesture);
	}
	
	function onGesture(event:GestureEventData) 
	{
		if (event.gesture == singleTapGesture)
			trace("Signle-tap recognized.");
		else
			trace("Double-tap recognized.");
		
		//TweenMax.fromTo(label, 4,
						//{autoAlpha: 1},
						//{autoAlpha: 0});
		//TweenMax.fromTo(button, 1,
						//{glowFilter: {color: 0xCCCCCC * Math.random(), blurX: 64, blurY: 64, strength: 3, alpha: 1, quality: 1}},
						//{glowFilter: {alpha: 0, remove: true}});
	}
	
}