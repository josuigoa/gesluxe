
import entities.BasicGestureEntity;
import entities.LongPressEntity;
import entities.PanEntity;
import entities.SwipeEntity;
import entities.TapUsageEntity;
import entities.TransformEntity;
import entities.ZoomEntity;
import luxe.Parcel;
import luxe.ParcelProgress;
import luxe.tween.Actuate;
import luxe.tween.easing.Sine;
import luxe.Visual;
import org.gesluxe.core.GestureState;
import org.gesluxe.gestures.Gesture;
import org.gesluxe.gestures.SwipeGesture;
import org.gesluxe.gestures.TransformGesture;
import org.gesluxe.gestures.ZoomGesture;
import phoenix.Camera;
import luxe.Color;
import luxe.Input;
import luxe.Scene;
import luxe.Text;
import luxe.Vector;
import org.gesluxe.events.GestureEvent;
import org.gesluxe.Gesluxe;
import org.gesluxe.gestures.LongPressGesture;
import org.gesluxe.gestures.PanGesture;
import org.gesluxe.gestures.TapGesture;
import examples.ConflictGestures;
import phoenix.Batcher;
import phoenix.Texture.FilterType;
import ui.Button;

class Main extends luxe.Game
{
	var _logText:Text;
	var _tutorial:Text;
    var hud_batcher:Batcher;
	var visual:Visual;
	var arrow:Visual;
	//var currentGestureEntity:BasicGestureEntity;
	var currentGesture:String;
	var pan:PanGesture;
	var doubleTapGesture:TapGesture;
	var twoFingerTapGesture:TapGesture;
	var longpress:LongPressGesture;
	var fingerToImageOffset:Vector;
	var swipe:SwipeGesture;
	var transformGesture:TransformGesture;
	var zoom:ZoomGesture;

    override function ready()
	{
		Luxe.renderer.clear_color =  new Color().rgb(0x333000);
		var json_asset = Luxe.loadJSON('assets/parcel.json');

		//then create a parcel to load it for us
		var preload = new Parcel();
		preload.from_json(json_asset.json);

		//but, we also want a progress bar for the parcel,
		//this is a default one, you can do your own
		new ParcelProgress({
			parcel      : preload,
			background  : new Color(1,1,1,0.85),
			oncomplete  : assets_loaded
		});

		//go!
		preload.load();
    } //ready
	
	function assets_loaded(_)
	{
		var texture = Luxe.loadTexture("assets/luxe.png");
		//now that the image is loaded
        //keep pixels crisp when we resize it
		texture.filter = FilterType.nearest;
		
		//work out the correct size based on a ratio
        var h = Luxe.screen.h * .2;
        var w = (h / texture.height) * texture.width;
		
		visual = new Visual( {
			name:"irudia",
			texture: texture,
			pos:Luxe.screen.mid,
			size:new Vector(w, h)
		});
		
		texture = Luxe.loadTexture("assets/arrow.png");
		texture.filter = FilterType.nearest;
        h = Luxe.screen.h * .2;
        w = (h / texture.height) * texture.width;
		
		arrow = new Visual( {
			name:"arrow",
			texture: texture,
			pos:Luxe.screen.mid,
			visible: false,
			size:new Vector(w, h)
		});
		arrow.color.a = 0;
		
		_logText = new Text( { name:"log text", 
								text: "TAP", 
								pos:new Vector(10, 10) } );
								
		_tutorial = new Text( { name: "tutorial",
										parent: this,
										pos: new Vector(Luxe.screen.w * .5, 5) } );
		
		Gesluxe.init();
		
		//currentGestureEntity = new TapUsageEntity();
		
		doubleTapGesture = new TapGesture();
		doubleTapGesture.numTapsRequired = 2;
		//doubleTapGesture.maxTapDelay = 10;
		//doubleTapGesture.maxTapDistance = 10;
		//doubleTapGesture.maxTapDuration = 20;
		doubleTapGesture.events.listen(GestureEvent.GESTURE_RECOGNIZED, onTap);
		twoFingerTapGesture = new TapGesture();
		twoFingerTapGesture.numTouchesRequired = 2;
		twoFingerTapGesture.events.listen(GestureEvent.GESTURE_RECOGNIZED, onTap);
		
		pan = new PanGesture();
		//pan.minNumTouchesRequired = 1;
		//pan.direction = PanGesture.HORIZONTAL;
		pan.maxNumTouchesRequired = 2;
		pan.events.listen(GestureEvent.GESTURE_BEGAN, onPan);
		pan.events.listen(GestureEvent.GESTURE_CHANGED, onPan);
		
		longpress = new LongPressGesture();
		//longpress.minPressDuration = 300;
		//longpress.numTouchesRequired = 1;
		longpress.events.listen(GestureEvent.GESTURE_STATE_CHANGE, onLongpress);
		fingerToImageOffset = new Vector();
		
		swipe = new SwipeGesture();
		//swipe.numTouchesRequired = 1;
		//swipe.maxDuration = 200;
		//swipe.minOffset = 300;
		//swipe.minVelocity = 50;
		swipe.events.listen(GestureEvent.GESTURE_RECOGNIZED, onSwipe);
		swipe.gesturesShouldRecognizeSimultaneously = swipeRecognizeSimultaneous;
		swipe.canBePreventedByGesture = swipe_canBePreventedByGesture;
		
		
		transformGesture = new TransformGesture();
		transformGesture.events.listen(GestureEvent.GESTURE_BEGAN, onTransform);
		transformGesture.events.listen(GestureEvent.GESTURE_CHANGED, onTransform);
		
		zoom = new ZoomGesture();
		//zoom.lockAspectRatio = false;
		zoom.events.listen(GestureEvent.GESTURE_BEGAN, onZoom);
		zoom.events.listen(GestureEvent.GESTURE_CHANGED, onZoom);
		
		create_hud();
		
		onbuttonclick({type:"tap"});
    } //assets_loaded
	
	function swipeRecognizeSimultaneous(gesture:Gesture, otherGesture:Gesture):Bool
	{
		return (Std.is(gesture, SwipeGesture) && Std.is(otherGesture, PanGesture)) || (Std.is(gesture, PanGesture) && Std.is(otherGesture, SwipeGesture));
	}
	
	function swipe_canBePreventedByGesture(gesture:Gesture):Bool
	{
		return false;
	}
	
    override function onkeyup( e:KeyEvent )
	{
		//probaSprite.scene = null;
		if (e.keycode == Key.escape)
			Luxe.shutdown();

    } //onkeyup
	
	function onbuttonclick(_prop:Dynamic) 
	{
		if (_prop == null) _prop = { };
		if (_prop.type == null) _prop.type = "tap";
		
		trace("BOTOI CLICK LISTENER: " + _prop.type);
		//currentGestureEntity.destroy();
		_logText.text = _prop.type.toUpperCase();
		_tutorial.text = "";
		visual.visible = _prop.type != "swipe";
		arrow.visible = !visual.visible;
		
		currentGesture = _prop.type;
		if (_prop.type == "tap")
			_tutorial.text = "Double tap / Two fingers tap";
		else if (_prop.type == "longpress")
			_tutorial.text = "Long press and move";
	}
	
    function create_hud() {

        hud_batcher = new Batcher(Luxe.renderer, 'hud_batcher');
            //we then create a second camera for it, default options
        var hud_view = new Camera();
            //then assign it
        hud_batcher.view = hud_view;
            //the default batcher is stored at layer 1, we want to be above it
        hud_batcher.layer = 2;
            //the add it to the renderer
        Luxe.renderer.add_batch(hud_batcher);

		var buttonY = 585;
		var b:Button = new Button("Tap", { name:"btn_tap", pos:new Vector(15, buttonY), batcher:hud_batcher } );
		b.events.listen(Button.CLICK, onbuttonclick);
		b = new Button("Pan", { name:"btn_pan", pos:new Vector(b.size_rect.x + b.size_rect.w + 15, buttonY), batcher:hud_batcher } );
		b.events.listen(Button.CLICK, onbuttonclick);
		b = new Button("LongPress", { name:"btn_lp", pos:new Vector(b.size_rect.x + b.size_rect.w + 15, buttonY), batcher:hud_batcher } );
		b.events.listen(Button.CLICK, onbuttonclick);
		b = new Button("Swipe", { name:"btn_swipe", pos:new Vector(b.size_rect.x + b.size_rect.w + 15, buttonY), batcher:hud_batcher } );
		b.events.listen(Button.CLICK, onbuttonclick);
		b = new Button("Transform", { name:"btn_trans", pos:new Vector(b.size_rect.x + b.size_rect.w + 15, buttonY), batcher:hud_batcher } );
		b.events.listen(Button.CLICK, onbuttonclick);
		b = new Button("Zoom", { name:"btn_zoom", pos:new Vector(b.size_rect.x + b.size_rect.w + 15, buttonY), batcher:hud_batcher } );
		b.events.listen(Button.CLICK, onbuttonclick);

        Luxe.draw.box({
            x : 0, y : buttonY - 10,
            w : Luxe.screen.w, h: Luxe.screen.h - buttonY + 10,
            color : new Color().rgb(0xf0f0f0),
                //here is the key, we don't store it in the default batcher, we make a second batcher with a different camera
            batcher : hud_batcher
        });
		
        Luxe.draw.line({
            p0 : new Vector(Luxe.screen.w/2, 0),
            p1 : new Vector(Luxe.screen.w/2, Luxe.screen.h),
            color : new Color(1,1,1,0.3),
            batcher : hud_batcher
        });
        Luxe.draw.line({
            p0 : new Vector(0, Luxe.screen.h/2),
            p1 : new Vector(Luxe.screen.w, Luxe.screen.h/2),
            color : new Color(1,1,1,0.3),
            batcher : hud_batcher
        });
    } //create_hud
	
	/* GESTURE LISTENERS */
	function onTap(evd:GestureEventData)
	{
		if (currentGesture != "tap") return;
		
		var scale:Float;
		
		if (evd.gesture == doubleTapGesture)
			scale = visual.scale.x * 1.2;
		else
			scale = visual.scale.x / 1.2;
		
		Actuate.tween(visual.scale, 0.3, {
				x: scale,
				y: scale
				});
	}
	
	function onPan(evd:GestureEventData)
	{
		if (currentGesture != "pan") return;
		
		visual.pos.x += pan.offsetX;
		visual.pos.y += pan.offsetY;
	}
	
	function onLongpress(evd:GestureEventData)
	{
		if (currentGesture != "longpress") return;
		
		var loc = longpress.location;
		
		if (evd.newState == GestureState.BEGAN)
		{
			visual.color.a = .5;
			visual.scale.x = visual.scale.y = 1.2;
			fingerToImageOffset.x = visual.pos.x - loc.x;
			fingerToImageOffset.y = visual.pos.y - loc.y;
		}
		else if (evd.newState == GestureState.CHANGED)
		{
			visual.pos.set_xy(fingerToImageOffset.x + loc.x, fingerToImageOffset.y + loc.y);
		}
		else if (evd.newState == GestureState.ENDED)
		{
			visual.color.a = 1;
			visual.scale.x = visual.scale.y = 1;
		}
		else if (evd.newState == GestureState.CANCELLED)
		{
			visual.color.a = 1;
			visual.scale.x = visual.scale.y = 1;
		}
	}
	
	function onSwipe(evd:GestureEventData)
	{
		if (currentGesture != "swipe") return;
		
		//arrow.flipx = (swipe.offsetX < 0 && swipe.offsetY == 0);
		var t = (swipe.offsetX < 0 && swipe.offsetY == 0 ? -1 : 1);
		//trace("SWIPE t: " + t);
		arrow.scale.x = t * Math.abs(arrow.scale.x);
		//if (t == 1) trace (swipe.offsetY + ", " + swipe.offsetX);
		var angle = 0;//event.offsetX == 0 ? (event.offsetY > 0 ? 90 : -90) : Math.atan(event.offsetY / event.offsetX) * 180 / Math.PI;
		if (swipe.offsetY != 0 && Math.abs(swipe.offsetY) > Math.abs(swipe.offsetX))
			angle = swipe.offsetY > 0 ? 90 : -90;
		
		arrow.rotation_z = angle;
		arrow.color.a = 1;
		Actuate.tween(arrow.color, 2, { a:0 } ).ease(Sine.easeIn);
	}
	
	function onTransform(evd:GestureEventData)
	{
		if (currentGesture != "transform") return;
		
		// Panning
		visual.pos.x += transformGesture.offsetX;
		visual.pos.y += transformGesture.offsetY;
		//visual.pos.set_xy(transformGesture.offsetX, transformGesture.offsetY);
		
		if (transformGesture.scale != 1 || transformGesture.rotation != 0)
		{
			// Scale and rotation.
			visual.radians = transformGesture.rotation;
			visual.scale.set_xy(transformGesture.scale, transformGesture.scale);
		}
	}
	
	function onZoom(evd:GestureEventData)
	{
		if (currentGesture != "zoom") return;
		
		visual.scale.set_xy(zoom.scaleX, zoom.scaleY);
	}

} //Main