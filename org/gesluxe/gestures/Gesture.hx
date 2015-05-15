package org.gesluxe.gestures;
import luxe.Emitter;
import luxe.Events;
import luxe.Vector;
import org.gesluxe.core.GesturesManager;
import org.gesluxe.core.GestureState;
import org.gesluxe.core.Touch;
import org.gesluxe.events.GestureEvent;

/**
 * ...
 * @author Josu Igoa
 */
class Gesture
{
	public var events:Events;
	/**
	 * Map (generic object) of tracking touch points, where keys are touch points IDs.
	 */
	var _touchesMap:Map<Int, Touch>;
	var _touchesCount:UInt;
	public var touchesCount(get, null):UInt;
	public function get_touchesCount():UInt { return _touchesCount; }
	public var state:GestureState;
	public var idle:Bool;
	
	/**
	 * Threshold for screen distance they must move to count as valid input 
	 * (not an accidental offset on touch), 
	 * based on 20 pixels on a 252ppi device.
	 */
	//public static var DEFAULT_SLOP:UInt = Math.round(20 / 252 * flash.system.Capabilities.screenDPI);
	public static var DEFAULT_SLOP:UInt = 20;
	
	/*
	Device				Capabilities.screenDPI	Capabilities.serverString’s		Actual PPI
	Android Nexus 1				254							254						254
	Droid Incredible			254							254						254
	Droid X						240							144						228
	Droid 2						240							144						265
	Samsung Galaxy Tab			240							168						168
	iPhone 3GS					163							72						163
	iPad						132							72						132 
	*/
	
	public var canBePreventedByGesture:Gesture->Bool;
	public var canPreventGesture:Gesture->Bool;
	/**
	 * If a gesture should receive a touch.
	 * Callback signature: function(gesture:Gesture, touch:Touch):Boolean
	 * 
	 * @see Touch
	 */
	public var gestureShouldReceiveTouch:Gesture->Touch->Bool;
	/**
	 * If a gesture should be recognized (transition from state POSSIBLE to state RECOGNIZED or BEGAN).
	 * Returning <code>false</code> causes the gesture to transition to the FAILED state.
	 * 
	 * Callback signature: function(gesture:Gesture):Boolean
	 * 
	 * @see state
	 * @see GestureState
	 */
	public var gestureShouldBegin:Gesture->Bool;
	/**
	 * If two gestures should be allowed to recognize simultaneously.
	 * 
	 * Callback signature: function(gesture:Gesture, otherGesture:Gesture):Boolean
	 */
	public var gesturesShouldRecognizeSimultaneously:Gesture->Gesture->Bool;
	
	
	var _gesturesManager:GesturesManager;
	var _centralPoint:Vector;
	/**
	 * List of gesture we require to fail.
	 * @see requireGestureToFail()
	 */
	var _gesturesToFail:Map<Gesture, Bool>;
	var _pendingRecognizedState:GestureState;
	public var location(get, null):Vector;
	public var enabled(default, set):Bool;
	
	public function new(addToManager:Bool = true) 
	{
		preinit();
		
		events = new Events();
		_gesturesManager = Gesluxe.gesturesManager;
		_touchesMap = new Map<Int, Touch>();
		_centralPoint = new Vector();
		location = new Vector();
		_gesturesToFail = new Map<Gesture, Bool>();
		enabled = true;
		state = GestureState.POSSIBLE;
		idle = true;
		
		if (addToManager)
			_gesturesManager.addGesture(this);
	}
	
	/**
	 * First method, called in constructor.
	 */
	function preinit()
	{
	}
	
	/**
	 * TODO: clarify usage. For now it's supported to call this method in onTouchBegin with return.
	 */
	function ignoreTouch(touch:Touch)
	{
		if (_touchesMap.remove(touch.id))
			_touchesCount--;
	}
	
	function failOrIgnoreTouch(touch:Touch)
	{
		if (state == GestureState.POSSIBLE)
		{
			setState(GestureState.FAILED);
		}
		else
		{
			ignoreTouch(touch);
		}
	}
	
	/**
	 * <p><b>NB!</b> This is abstract method and must be overridden.</p>
	 */
	function onTouchBegin(touch:Touch)
	{
	}
	
	
	/**
	 * <p><b>NB!</b> This is abstract method and must be overridden.</p>
	 */
	function onTouchMove(touch:Touch)
	{
	}
	
	
	/**
	 * <p><b>NB!</b> This is abstract method and must be overridden.</p>
	 */
	function onTouchEnd(touch:Touch)
	{
	}
	
	
	/**
	 * 
	 */
	function onTouchCancel(touch:Touch)
	{
	}
	
	public function setState(newState:GestureState):Bool
	{
		if (state == newState && state == GestureState.CHANGED)
		{
			// shortcut for better performance
			events.fire(GestureEvent.GESTURE_STATE_CHANGE, { gesture:this, newState:state, oldState:state } );
			events.fire(GestureEvent.GESTURE_CHANGED, { gesture:this, newState:state, oldState:state } );
			
			resetNotificationProperties();
			
			return true;
		}
		
		if (!state.canTransitionTo(newState))
		{
			throw "You cannot change from state " + state + " to state " + newState  + ".";
		}
		
		if (newState != GestureState.POSSIBLE)
		{
			// in case instantly switch state in touchBeganHandler()
			idle = false;
		}
		
		
		if (newState == GestureState.BEGAN || newState == GestureState.RECOGNIZED)
		{
			// first we check if other required-to-fail gestures recognized
			// TODO: is this really necessary? using "requireGestureToFail" API assume that
			// required-to-fail gesture always recognizes AFTER this one.
			for (gestureToFail in _gesturesToFail.keys())
			{
				if (!gestureToFail.idle &&
					gestureToFail.state != GestureState.POSSIBLE &&
					gestureToFail.state != GestureState.FAILED)
				{
					// Looks like other gesture won't fail,
					// which means the required condition will not happen, so we must fail
					setState(GestureState.FAILED);
					return false;
				}
			}
			// then we check if other required-to-fail gestures are actually tracked (not IDLE)
			// and not still not recognized (e.g. POSSIBLE state)
			for (gestureToFail in _gesturesToFail.keys())
			{
				if (gestureToFail.state == GestureState.POSSIBLE)
				{
					// Other gesture might fail soon, so we postpone state change
					_pendingRecognizedState = newState;
					
					for (gestureToFail in _gesturesToFail.keys())
					{
						gestureToFail.events.listen(GestureEvent.GESTURE_STATE_CHANGE, gestureToFailstateChangeHandler);
						//gestureToFail.addEventListener(GestureEvent.GESTURE_STATE_CHANGE, gestureToFailstateChangeHandler, false, 0, true);
					}
					
					return false;
				}
				// else if gesture is in IDLE state it means it doesn't track anything,
				// so we simply ignore it as it doesn't seem like conflict from this perspective
				// (perspective of using "requireGestureToFail" API)
			}
			
			
			if (gestureShouldBegin != null && !gestureShouldBegin(this))
			{
				setState(GestureState.FAILED);
				return false;
			}
		}
			
		var oldState:GestureState = state;	
		state = newState;
		
		if (state.isEndState)
			_gesturesManager.scheduleGestureStateReset(this);
		
		//TODO: what if RTE happens in event handlers?
		
		events.fire(GestureEvent.GESTURE_STATE_CHANGE, { gesture:this, newState:state, oldState:oldState } );
		events.fire(state.toEventType(), { gesture:this, newState:state, oldState:oldState } );
		
		resetNotificationProperties();
		if (state == GestureState.BEGAN || state == GestureState.RECOGNIZED)
		{
			_gesturesManager.onGestureRecognized(this);
		}
		
		return true;
	}
	
	function updateCentralPoint()
	{
		var touchLocation:Vector;
		var x:Float = 0;
		var y:Float = 0;
		for (touchID in _touchesMap.keys())
		{
			touchLocation = _touchesMap[touchID].location;
			x += touchLocation.x;
			y += touchLocation.y;
		}
		
		_centralPoint.x = (x != 0) ? x / _touchesCount : 0;
		_centralPoint.y = (y != 0) ? y / _touchesCount: 0;
	}
	
	
	function updateLocation()
	{
		updateCentralPoint();
		location.set_xy(_centralPoint.x, _centralPoint.y);
	}
	
	function resetNotificationProperties()
	{
		
	}
	public function isTrackingTouch(touchID:UInt):Bool
	{
		return _touchesMap.exists(touchID);
	}
	
	/**
	 * Cancels current tracking (interaction) cycle.
	 * 
	 * <p>Could be useful to "stop" gesture for the current interaction cycle.</p>
	 */
	public function reset()
	{
		if (idle)
			return;// Do nothing as we are idle and there is nothing to reset
		
		var state:GestureState = this.state;//caching getter
		
		location.x = 0;
		location.y = 0;
		_touchesMap = new Map<Int, Touch>();
		_touchesCount = 0;
		idle = true;
		var gestureToFail;
		
		for (gestureToFail in _gesturesToFail.keys())
		{
			gestureToFail.events.unlisten(GestureEvent.GESTURE_STATE_CHANGE);
			//gestureToFail.removeEventListener(GestureEvent.GESTURE_STATE_CHANGE, gestureToFailstateChangeHandler);
		}
		_pendingRecognizedState = null;
		
		if (state == GestureState.POSSIBLE)
		{
			// manual reset() call. Set to FAILED to keep our State Machine clean and stable
			setState(GestureState.FAILED);
		}
		else if (state == GestureState.BEGAN || state == GestureState.CHANGED)
		{
			// manual reset() call. Set to CANCELLED to keep our State Machine clean and stable
			setState(GestureState.CANCELLED);
		}
		else
		{
			// reset from GesturesManager after reaching one of the 4 final states:
			//(state == GestureState.RECOGNIZED ||
			 //state == GestureState.ENDED ||
			 //state == GestureState.FAILED ||
			 //state == GestureState.CANCELLED)
			setState(GestureState.POSSIBLE);
		}
	}
	
	/**
	 * Remove gesture and prepare it for GC.
	 * 
	 * <p>The gesture is not able to use after calling this method.</p>
	 */
	public function dispose()
	{
		//TODO
		reset();
		//target = null;
		canBePreventedByGesture = null;
		canPreventGesture = null;
		gestureShouldReceiveTouch = null;
		gestureShouldBegin = null;
		gesturesShouldRecognizeSimultaneously = null;
		_gesturesToFail = null;
	}
	
	/*
	public function canBePreventedByGesture(preventingGesture:Gesture):Bool
	{
		return true;
	}
	
	
	public function canPreventGesture(preventedGesture:Gesture):Bool
	{
		return true;
	}
	*/
	
	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------
	
	public function touchBeginHandler(touch:Touch)
	{
		if (_touchesMap.exists(touch.id)) return;
		
		_touchesMap[touch.id] = touch;
		_touchesCount++;
		
		onTouchBegin(touch);
		
		if (_touchesCount == 1 && state == GestureState.POSSIBLE)
		{
			idle = false;
		}
	}
	
	
	public function touchMoveHandler(touch:Touch)
	{
		if (!_touchesMap.exists(touch.id)) return;
		
		//_touchesMap[touch.id] = touch;
		onTouchMove(touch);
	}
	
	
	public function touchEndHandler(touch:Touch)
	{
		if (!_touchesMap.exists(touch.id)) return;
		
		_touchesMap.remove(touch.id);
		_touchesCount--;
		
		onTouchEnd(touch);
	}
	
	
	public function touchCancelHandler(touch:Touch)
	{
		if (_touchesMap.exists(touch.id)) return;
		
		_touchesMap.remove(touch.id);
		_touchesCount--;
		
		onTouchCancel(touch);
		
		if (!state.isEndState)
		{
			if (state == GestureState.BEGAN || state == GestureState.CHANGED)
				setState(GestureState.CANCELLED);
			else
				setState(GestureState.FAILED);
		}
	}
	
	function gestureToFailstateChangeHandler(event:Dynamic)
	{
		if (_pendingRecognizedState == null || state != GestureState.POSSIBLE)
			return;
		
		if (event.newState == GestureState.FAILED)
		{
			for (gestureToFail in _gesturesToFail.keys())
			{
				if (gestureToFail.state == GestureState.POSSIBLE)
				{
					// we're still waiting for some gesture to fail
					return;
				}
			}
			
			// at this point all gestures-to-fail are either in IDLE or in FAILED states
			setState(_pendingRecognizedState);
		}
		else if (event.newState != GestureState.POSSIBLE)
		{
			//TODO: need to re-think this over
			
			setState(GestureState.FAILED);
		}
	}
	
	/* GETTERS & SETTERS */
	public function get_location():Vector
	{
		//return location.clone();
		return location;
	}
	
	public function set_enabled(value:Bool):Bool
	{
		if (enabled == value)
			return value;
		
		enabled = value;
		
		if (!enabled)
		{
			if (state == GestureState.POSSIBLE)
				setState(GestureState.FAILED);
			else if (state == GestureState.BEGAN || state == GestureState.CHANGED)
				setState(GestureState.CANCELLED);
		}
		
		return value;
	}
}