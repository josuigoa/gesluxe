package org.gesluxe.core;
import org.gesluxe.gestures.Gesture;
import org.gesluxe.utils.GestureUtils;

/**
 * ...
 * @author Josu Igoa
 */
class GesturesManager
{
	//const _frameTickerShape:Shape = new Shape();
	var _gesturesMap:Map<Gesture, Bool>;
	var _gesturesForTouchMap:Map<Touch, Array<Gesture>>;
	//var _gesturesForTargetMap:Map<Dynamic, Array<Gesture>;
	var _dirtyGesturesCount:UInt = 0;
	var _dirtyGesturesMap:Map<Gesture, Bool>;
	//var _stage:Stage;
	
	public function new() 
	{
		_gesturesMap = new Map<Gesture, Bool>();
		_gesturesForTouchMap = new Map<Touch, Array<Gesture>>();
		_dirtyGesturesMap = new Map<Gesture, Bool>();
	}
	
	public function addGesture(gesture:Gesture)
	{
		if (gesture == null)
		{
			throw "Argument 'gesture' must be not null.";
		}
		
		/*
		var target = gesture.target;
		if (!target)
		{
			throw "Gesture must have target.";
		}
		
		var targetGestures:Array<Gesture> = _gesturesForTargetMap[target];
		if (targetGestures)
		{
			if (targetGestures.indexOf(gesture) == -1)
			{
				targetGestures.push(gesture);
			}
		}
		else
		{
			targetGestures = _gesturesForTargetMap[target] = new Array<Gesture>();
			targetGestures[0] = gesture;
		}
		
		_gesturesForTargetMap.set(target, targetGestures);
		_gesturesMap[gesture] = true;
		
		if (_stage == null)
		{
			var targetAsDO:DisplayObject = target as DisplayObject;
			if (targetAsDO)
			{
				if (targetAsDO.stage)
				{
					onStageAvailable(targetAsDO.stage);
				}
				else
				{
					targetAsDO.addEventListener(Event.ADDED_TO_STAGE, gestureTarget_addedToStageHandler, false,0, true);
				}
			}
		}
		*/
		
		_gesturesMap[gesture] = true;
	}
	
	
	public function removeGesture(gesture:Gesture)
	{
		if (gesture == null)
		{
			throw "Argument 'gesture' must be not null.";
		}
		
		_gesturesMap.remove(gesture);
		
		gesture.reset();
	}
	
	public function scheduleGestureStateReset(gesture:Gesture)
	{
		if (!_dirtyGesturesMap[gesture])
		{
			_dirtyGesturesMap[gesture] = true;
			_dirtyGesturesCount++;
			Luxe.core.timer.schedule(Luxe.core.delta_time, resetDirtyGestures);
		}
	}
	
	function resetDirtyGestures()
	{
		for (gesture in _dirtyGesturesMap.keys())
		{
			if (_dirtyGesturesMap[gesture])
			{
				gesture.reset();
				_dirtyGesturesMap[gesture] = false;
				_dirtyGesturesCount--;
			}
		}
	}
	
	public function onGestureRecognized(gesture:Gesture)
	{
		for (otherGesture in _gesturesMap.keys())
		{
			// conditions for otherGesture "own properties"
			if (otherGesture != gesture &&
				otherGesture.enabled &&
				otherGesture.state == GestureState.POSSIBLE)
			{
				// conditions for gestures relations
				if ((gesture.canPreventGesture == null || gesture.canPreventGesture(otherGesture)) &&
					(otherGesture.canBePreventedByGesture == null || otherGesture.canBePreventedByGesture(gesture)) &&
					(gesture.gesturesShouldRecognizeSimultaneously == null || !gesture.gesturesShouldRecognizeSimultaneously(gesture, otherGesture)) &&
					(otherGesture.gesturesShouldRecognizeSimultaneously == null || !otherGesture.gesturesShouldRecognizeSimultaneously(otherGesture, gesture)))
				{
					otherGesture.setState(GestureState.FAILED);
				}
			}
		}
	}
	
	public function onTouchBegin(touch:Touch)
	{
		var gesture:Gesture;
		
		// This vector will contain active gestures for specific touch during all touch session.
		var gesturesForTouch:Array<Gesture> = _gesturesForTouchMap[touch];
		if (gesturesForTouch == null)
			gesturesForTouch = new Array<Gesture>();
		else
		{
			// touch object may be pooled in the future
			GestureUtils.clearArray(gesturesForTouch);
		}
		
		/*
		var target = touch.target;
		var displayListAdapter:IDisplayListAdapter = Gestouch.gestouch_internal::getDisplayListAdapter(target);
		if (!displayListAdapter)
		{
			throw new Error("Display list adapter not found for target of type '" + getQualifiedClassName(target) + "'.");
		}
		const hierarchy:Vector.<Object> = displayListAdapter.getHierarchy(target);
		const hierarchyLength:uint = hierarchy.length;
		if (hierarchyLength == 0)
		{
			throw "No hierarchy build for target '" + target +"'. Something is wrong with that IDisplayListAdapter.";
		}
		if (_stage && !(hierarchy[hierarchyLength - 1] is Stage))
		{
			// Looks like some non-native (non DisplayList) hierarchy
			// but we must always handle gestures with Stage target
			// since Stage is anyway the top-most parent
			hierarchy[hierarchyLength] = _stage;
		}
		
		// Create a sorted(!) list of gestures which are interested in this touch.
		// Sorting priority: deeper target has higher priority, recently added gesture has higher priority.
		var gesturesForTarget:Vector.<Gesture>;
		for each (target in hierarchy)
		{
			gesturesForTarget = _gesturesForTargetMap[target] as Vector.<Gesture>;
			if (gesturesForTarget)
			{
				i = gesturesForTarget.length;
				while (i-- > 0)
				{
					gesture = gesturesForTarget[i];
					if (gesture.enabled &&
						(gesture.gestureShouldReceiveTouchCallback == null ||
						 gesture.gestureShouldReceiveTouchCallback(gesture, touch)))
					{
						//TODO: optimize performance! decide between unshift() vs [i++] = gesture + reverse()
						gesturesForTouch.unshift(gesture);
					}
				}
			}
		}
		*/
		
		for (gesture in _gesturesMap.keys()) 
		{
			if (gesture.enabled &&
				(gesture.gestureShouldReceiveTouch == null ||
				 gesture.gestureShouldReceiveTouch(gesture, touch)))
			{
				//TODO: optimize performance! decide between unshift() vs [i++] = gesture + reverse()
				gesturesForTouch.unshift(gesture);
			}
		}
		
		// Then we populate them with this touch and event.
		// They might start tracking this touch or ignore it (via Gesture#ignoreTouch())
		var i = gesturesForTouch.length;
		while (i-- > 0)
		{
			gesture = gesturesForTouch[i];
			// Check for state because previous (i+1) gesture may already abort current (i) one
			if (!_dirtyGesturesMap[gesture])
				gesture.touchBeginHandler(touch);
			else
				gesturesForTouch.splice(i, 1);
		}
		
		_gesturesForTouchMap.set(touch, gesturesForTouch);
	}
	
	
	public function onTouchMove(touch:Touch)
	{
		var gesturesForTouch:Array<Gesture> = _gesturesForTouchMap[touch];
		var gesture:Gesture;
		var i = gesturesForTouch.length;
		while (i-- > 0)
		{
			gesture = gesturesForTouch[i];
			if (!_dirtyGesturesMap[gesture] && gesture.isTrackingTouch(touch.id))
				gesture.touchMoveHandler(touch);
			else
			{
				// gesture is no more interested in this touch (e.g. ignoreTouch was called)
				gesturesForTouch.splice(i, 1);
			}
		}
	}
	
	
	public function onTouchEnd(touch:Touch)
	{
		var gesturesForTouch:Array<Gesture> = _gesturesForTouchMap[touch];
		var gesture:Gesture;
		var i = gesturesForTouch.length;
		while (i-- > 0)
		{
			gesture = gesturesForTouch[i];
			
			if (!_dirtyGesturesMap[gesture] && gesture.isTrackingTouch(touch.id))
				gesture.touchEndHandler(touch);
		}
		
		GestureUtils.clearArray(gesturesForTouch);
		
		_gesturesForTouchMap.remove(touch);//TODO: remove this once Touch objects are pooled
	}
	
	
	public function onTouchCancel(touch:Touch)
	{
		var gesturesForTouch:Array<Gesture> = _gesturesForTouchMap[touch];
		var gesture:Gesture;
		var i = gesturesForTouch.length;
		while (i-- > 0)
		{
			gesture = gesturesForTouch[i];
			
			if (!_dirtyGesturesMap[gesture] && gesture.isTrackingTouch(touch.id))
				gesture.touchCancelHandler(touch);
		}
		
		GestureUtils.clearArray(gesturesForTouch);
		
		_gesturesForTouchMap.remove(touch);//TODO: remove this once Touch objects are pooled
	}
}