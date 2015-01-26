package examples;
import luxe.Vector;
import luxe.Visual;
import org.gesluxe.events.GestureEvent;
import org.gesluxe.gestures.PanGesture;
import phoenix.Texture;

/**
 * ...
 * @author Josu Igoa
 */
class PanExample extends ImageExample
{
	var pan:PanGesture;
	
	public function new() 
	{
		super();
	}
	
	override function texture_loaded(_) 
	{
		super.texture_loaded(_);
		
		pan = new PanGesture();
		pan.maxNumTouchesRequired = 2;
		pan.events.listen(GestureEvent.GESTURE_BEGAN, onPan);
		pan.events.listen(GestureEvent.GESTURE_CHANGED, onPan);
		//slopSlider.value = pan.slop;
		//minNumTouchesSlider.value = pan.minNumTouchesRequired;
		//maxNumTouchesSlider.value = pan.maxNumTouchesRequired;
	}
	
	function onPan(event:GestureEventData) 
	{
		visual.pos.x += pan.offsetX;
		visual.pos.y += pan.offsetY;
	}
}