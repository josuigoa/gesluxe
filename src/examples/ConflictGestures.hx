package examples;
import org.gesluxe.core.Touch;
import org.gesluxe.events.GestureEvent.GestureEventData;
import org.gesluxe.gestures.Gesture;
import org.gesluxe.gestures.PanGesture;
import org.gesluxe.gestures.RotateGesture;
import org.gesluxe.gestures.ZoomGesture;

/**
 * ...
 * @author Josu Igoa
 */
class ConflictGestures
{
	var gestures:Array<Gesture>;

	public function new() 
	{
		gestures = new Array<Gesture>();
		
		var pan:PanGesture = new PanGesture();
		pan.gestureShouldBegin = gestureShouldBegin;
		pan.gestureShouldReceiveTouch = gestureShouldReceiveTouch;
		pan.gesturesShouldRecognizeSimultaneously = gesturesShouldRecognizeSimultaneously;
		pan.maxNumTouchesRequired = 2;
		//pan.delegate = this;
		//pan.addEventListener(org.gestouch.events.GestureEvent.GESTURE_BEGAN, onPan);
		//pan.addEventListener(org.gestouch.events.GestureEvent.GESTURE_CHANGED, onPan);
		gestures.push(pan);
		
		var zoom:ZoomGesture = new ZoomGesture();
		zoom.gestureShouldBegin = gestureShouldBegin;
		zoom.gestureShouldReceiveTouch = gestureShouldReceiveTouch;
		zoom.gesturesShouldRecognizeSimultaneously = gesturesShouldRecognizeSimultaneously;
		//zoom.addEventListener(org.gestouch.events.GestureEvent.GESTURE_BEGAN, onZoom);
		//zoom.addEventListener(org.gestouch.events.GestureEvent.GESTURE_CHANGED, onZoom);
		//zoom.delegate = this;
		gestures.push(zoom);
		
		var rotate:RotateGesture = new RotateGesture();
		rotate.gestureShouldBegin = gestureShouldBegin;
		rotate.gestureShouldReceiveTouch = gestureShouldReceiveTouch;
		rotate.gesturesShouldRecognizeSimultaneously = gesturesShouldRecognizeSimultaneously;
		//rotate.delegate = this;
		//rotate.addEventListener(org.gestouch.events.GestureEvent.GESTURE_BEGAN, onRotate);
		//rotate.addEventListener(org.gestouch.events.GestureEvent.GESTURE_CHANGED, onRotate);
		gestures.push(rotate);
	}
	/*
	private function onPan(event:GestureEventData):void
	{
		var gesture:PanGesture = event.target as PanGesture;
		var target:UIComponent = gesture.target as UIComponent;
		target.move(target.x + gesture.offsetX, target.y + gesture.offsetY);
	}
	
	private function onZoom(event:GestureEventData):void
	{
		var gesture:ZoomGesture = event.target as ZoomGesture;
		var target:UIComponent = gesture.target as UIComponent;
		var matrix:Matrix = target.transform.matrix;
		var transformPoint:Point = matrix.transformPoint(target.globalToLocal(gesture.location));
		matrix.translate(-transformPoint.x, -transformPoint.y);
		matrix.scale(gesture.scaleX, gesture.scaleY);
		matrix.translate(transformPoint.x, transformPoint.y);
		target.transform.matrix = matrix;
	}
	
	private function onRotate(event:GestureEventData):void
	{
		var gesture:RotateGesture = event.target as RotateGesture;
		var target:UIComponent = gesture.target as UIComponent;
		var matrix:Matrix = target.transform.matrix;
		var transformPoint:Point = matrix.transformPoint(target.globalToLocal(gesture.location));
		matrix.translate(-transformPoint.x, -transformPoint.y);
		matrix.rotate(gesture.rotation);
		matrix.translate(transformPoint.x, transformPoint.y);
		target.transform.matrix = matrix;
	}
	*/
	
	/* DELEGATES */
	public function gestureShouldReceiveTouch(gesture:Gesture, touch:Touch):Bool
	{
		return true;
	}
	
	public function gestureShouldBegin(gesture:Gesture):Bool
	{
		return true;
	}
	
	public function gesturesShouldRecognizeSimultaneously(gesture:Gesture, otherGesture:Gesture):Bool
	{
		if (gesture == otherGesture)
			return true;
		
		return false;
	}
}