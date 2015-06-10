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

		#if web
		// desktop web browsers
		Luxe.core.emitter.on(Luxe.Ev.mousedown, onmousedown);
		// mobile web browsers
		Luxe.core.emitter.on(Luxe.Ev.touchdown, ontouchdown);
		Luxe.core.emitter.on(Luxe.Ev.touchmove, ontouchmove);
		Luxe.core.emitter.on(Luxe.Ev.touchup, ontouchup);
		#elseif mobile
		Luxe.core.emitter.on(Luxe.Ev.touchdown, ontouchdown);
		Luxe.core.emitter.on(Luxe.Ev.touchmove, ontouchmove);
		Luxe.core.emitter.on(Luxe.Ev.touchup, ontouchup);
		#else
		Luxe.core.emitter.on(Luxe.Ev.mousedown, onmousedown);
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
			addmouselisteners();
	}

	static private function onmousemove(event:MouseEvent)
	{
		_touchesManager.onTouchMove(MOUSE_TOUCH_POINT_ID, event.pos.x, event.pos.y);
	}

	static private function onmouseup(event:MouseEvent)
	{
		_touchesManager.onTouchEnd(MOUSE_TOUCH_POINT_ID, event.pos.x, event.pos.y);

		if (_touchesManager.activeTouchesCount == 0)
			removemouselisteners();
	}

	static function addmouselisteners()
	{
		Luxe.core.emitter.on(Luxe.Ev.mousemove, onmousemove);
		Luxe.core.emitter.on(Luxe.Ev.mouseup, onmouseup);
	}

	static function removemouselisteners()
	{
		Luxe.core.emitter.off(Luxe.Ev.mousemove, onmousemove);
		Luxe.core.emitter.off(Luxe.Ev.mouseup, onmouseup);
	}

	static public function dispose()
	{
		gesturesManager.removeAllGestures();
		gesturesManager = null;
		touchesManager = null;

		Luxe.core.emitter.off(Luxe.Ev.touchdown, ontouchdown);
		Luxe.core.emitter.off(Luxe.Ev.touchmove, ontouchmove);
		Luxe.core.emitter.off(Luxe.Ev.touchup, ontouchup);

		Luxe.core.emitter.off(Luxe.Ev.mousedown, onmousedown);
		removemouselisteners();
	}
}
