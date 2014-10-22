package org.gesluxe;

import luxe.Game;
import luxe.Input.MouseEvent;
import luxe.Input.TouchEvent;
import org.gesluxe.core.GesturesManager;
import org.gesluxe.core.GestureState;
import org.gesluxe.core.TouchesManager;
/**
 * ...
 * @author Josu Igoa
 */

class Gesluxe
{
	static inline var MOUSE_TOUCH_POINT_ID:UInt = 0;
	static var touchesManager(null, set):TouchesManager;
	static public function set_touchesManager(tm:TouchesManager):TouchesManager { touchesManager = tm; return tm; }
	
	static public var gesturesManager:GesturesManager;
	static var _touchesManager:TouchesManager;
	
	public function new() 
	{
	}
	
	static public function init() 
	{
		GestureState.initStates();
		gesturesManager = new GesturesManager();
		_touchesManager = new TouchesManager(gesturesManager);
		
		#if !mobile
		Luxe.core.emitter.on("mousedown", onmousedown);
		#else
		Luxe.core.emitter.on("touchdown", ontouchdown);
		Luxe.core.emitter.on("touchmove", ontouchmove);
		Luxe.core.emitter.on("touchup", ontouchup);
		#end
	}
	
	static function ontouchdown(event:TouchEvent) 
	{
		/*
		 * state : InteractState.down,
			timestamp : timestamp,
			touch_id : touch_id,
			x : x,
			y : y,
			dx : x,
			dy : y,
			pos : _touch_pos*/
		_touchesManager.onTouchBegin(event.touch_id, event.pos.x * Luxe.screen.w, event.pos.y * Luxe.screen.h); //, event.target as InteractiveObject);
	}
	
	static function ontouchmove(event:TouchEvent) 
	{
		_touchesManager.onTouchMove(event.touch_id, event.pos.x * Luxe.screen.w, event.pos.y * Luxe.screen.h);
	}
	
	static function ontouchup(event:TouchEvent) 
	{
		_touchesManager.onTouchEnd(event.touch_id, event.pos.x * Luxe.screen.w, event.pos.y * Luxe.screen.h);
	}
	
	static function onmousedown(event:MouseEvent)
	{
		var touchAccepted:Bool = _touchesManager.onTouchBegin(MOUSE_TOUCH_POINT_ID, event.pos.x, event.pos.y);
			
		if (touchAccepted)
			installMouseListeners();
	}
	
	static private function onmousemove(event:MouseEvent) 
	{
		_touchesManager.onTouchMove(MOUSE_TOUCH_POINT_ID, event.pos.x, event.pos.y);
	}
	
	static private function onmouseup(event:MouseEvent) 
	{
		_touchesManager.onTouchEnd(MOUSE_TOUCH_POINT_ID, event.pos.x, event.pos.y);
			
		if (_touchesManager.activeTouchesCount == 0)
			unstallMouseListeners();
	}
	
	static function installMouseListeners()
	{
		Luxe.core.emitter.on("mousemove", onmousemove);
		Luxe.core.emitter.on("mouseup", onmouseup);
	}
	
	
	static function unstallMouseListeners()
	{
		Luxe.core.emitter.off("mousemove", onmousemove);
		Luxe.core.emitter.off("mouseup", onmouseup);
	}
	
	static public function dispose() 
	{
		gesturesManager.removeAllGestures();
		gesturesManager = null;
		touchesManager = null;
		
		Luxe.core.emitter.off("touchdown", ontouchdown);
		Luxe.core.emitter.off("touchmove", ontouchmove);
		Luxe.core.emitter.off("touchup", ontouchup);
		
		Luxe.core.emitter.off("mousedown", onmousedown);
		unstallMouseListeners();
	}
}