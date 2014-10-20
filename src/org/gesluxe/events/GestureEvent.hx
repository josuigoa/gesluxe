package org.gesluxe.events;
import org.gesluxe.core.GestureState;
import org.gesluxe.gestures.Gesture;

/**
 * ...
 * @author Josu Igoa
 */

typedef GestureEventData = {
	var gesture:Gesture;
	var newState:GestureState;
	var oldState:GestureState;
}
class GestureEvent
{
	public static inline var GESTURE_POSSIBLE:String = "gesture.possible";
	public static inline var GESTURE_RECOGNIZED:String = "gesture.recognized";
	public static inline var GESTURE_BEGAN:String = "gesture.began";
	public static inline var GESTURE_CHANGED:String = "gesture.changed";
	public static inline var GESTURE_ENDED:String = "gesture.ended";
	public static inline var GESTURE_CANCELLED:String = "gesture.cancelled";
	public static inline var GESTURE_FAILED:String = "gesture.failed";
	
	public static inline var GESTURE_STATE_CHANGE:String = "gesture.stateChange";
	
	/*
	public var type:String;
	public var newState:GestureState;
	public var oldState:GestureState;

	public function new(type:String, newState:GestureState, oldState:GestureState)
	{
		//super(type, false, false);
		
		this.type = type;
		this.newState = newState;
		this.oldState = oldState;
	}
	
	public function clone():GestureEvent
	{
		return new GestureEvent(type, newState, oldState);
	}
	
	
	public function toString():String
	{
		return "GestureEvent: " + type + ", " + oldState.toString() + ", " + newState.toString();
	}
	*/
}