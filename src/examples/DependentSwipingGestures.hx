package examples;
import luxe.Color;
import luxe.Matrix;
import luxe.Vector;
import luxe.Visual;
import org.gesluxe.core.Touch;
import org.gesluxe.events.GestureEvent;
import org.gesluxe.gestures.Gesture;
import org.gesluxe.gestures.PanGesture;
import org.gesluxe.gestures.SwipeGesture;

/**
 * ...
 * @author Josu Igoa
 */
class DependentSwipingGestures
{
	//var fillOffsetMatrix:Matrix;
	var vis:Visual;
	var pan:PanGesture;
	var swipe:SwipeGesture;

	public function new() 
	{
		//fillOffsetMatrix = new Matrix();
		vis = new Visual({
			name: "visual",
			size: new Vector(50, 50),
			pos: Luxe.screen.mid,
			color: new Color().rgb(0xFFF000)
		});
		
		pan = new PanGesture();
		pan.events.listen(GestureEvent.GESTURE_BEGAN, onPan);
		pan.events.listen(GestureEvent.GESTURE_CHANGED, onPan);
		pan.slop = 0;
		
		swipe = new SwipeGesture();
		swipe.events.listen(GestureEvent.GESTURE_RECOGNIZED, onSwipe);
		swipe.direction = SwipeGesture.RIGHT;
		swipe.gestureShouldBeginCallback = gestureShouldBegin;
		swipe.gestureShouldReceiveTouchCallback = gestureShouldReceiveTouch;
		swipe.gesturesShouldRecognizeSimultaneouslyCallback = gesturesShouldRecognizeSimultaneously;
		
		pan.requireGestureToFail(swipe);//NB! this is weak reference
	}
	
	function onPan(event:GestureEventData)
	{
		trace("pan");
		//fillOffsetMatrix.makeTranslation(pan.offsetX, pan.offsetY);
		vis.pos.set_xy(pan.offsetX, pan.offsetY);
	}
	
	function onSwipe(event:GestureEventData)
	{
		trace("swipe");
		//TweenMax.to(menu, 1, {bezierThrough:[{scaleX:2}, {scaleX:1}]});
	}
	
	function updateFill():void
	{
		//var g:Graphics = scroller.graphics;
		//g.clear();
		//g.beginBitmapFill(fillBitmapData, fillOffsetMatrix);
		//g.drawRect(0, 0, scroller.width, scroller.height);
		//g.endFill();
	}
	//----------------------------------
	// Begin of IGestureDelegate implementation
	//----------------------------------
	public function gestureShouldReceiveTouch(gesture:Gesture, touch:Touch):Bool
	{
		trace(touch.location.x, width / 3);
		if (gesture == swipe && touch.location.x > width / 3)
			return false;
			
		return true;
	}
	
	public function gestureShouldBegin(gesture:Gesture):Bool
	{
		return true;
	}
	
	public function gesturesShouldRecognizeSimultaneously(gesture:Gesture, otherGesture:Gesture):Bool
	{
		return false;
	}
	//----------------------------------
	// End of IGestureDelegate implementation
	//----------------------------------
}