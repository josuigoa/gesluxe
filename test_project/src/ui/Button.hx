package ui;

import luxe.Color;
import luxe.Emitter.EmitHandler;
import luxe.Entity;
import luxe.Input.MouseEvent;
import luxe.Input.TouchEvent;
import luxe.NineSlice;
import luxe.options.EntityOptions;
import luxe.options.VisualOptions;
import luxe.Rectangle;
import luxe.Text;
import luxe.Vector;
import phoenix.Texture;

/**
 * ...
 * @author Josu Igoa
 */
class Button extends Entity
{
	static public inline var CLICK:String = "button.click";
	
    var geom : NineSlice;
    var text : Text;
	public var size_rect (default, null): Rectangle;
	
	public function new(txt:String = null, btnTexture:Texture = null, _options:VisualOptions = null) 
	{
		super(_options);
		
		var mb = (_options != null && _options.batcher != null) ? _options.batcher : Luxe.renderer.batcher;
		
		geom = new NineSlice({
            texture : (btnTexture == null) ? Luxe.loadTexture('tiny.button.png') : btnTexture,
			parent: this,
			batcher: mb,
            top : 4, left : 4, right : 4, bottom : 4
        });
		
		if (txt == null) txt = "Hello Luxe";
		
		text = new Text( { name: "btn_" + txt,
							color: new Color().rgb(0x663333),
							parent: this,
							depth: 1,
							batcher: mb,
							text: txt,
							point_size: 35
							} );
		
		var size_vector = new Vector();
		text.font.dimensions_of(txt, 35, size_vector);
		size_rect = new Rectangle(pos.x - size_vector.x * .1, pos.y - size_vector.y * .1, size_vector.x * 1.2, size_vector.y * 1.2);
		
        geom.create( new Vector(size_rect.x, size_rect.y), size_rect.w, size_rect.h);
	}
	
	override public function onmouseup(event:MouseEvent)
	{
		super.onmouseup(event);
		
		point_inside(event.pos);
	}
	
	override public function ontouchup(event:TouchEvent) 
	{
		super.ontouchup(event);
		
		point_inside(event.pos);
	}
	
	function point_inside(point:Vector):Void 
	{
		if (size_rect.point_inside(point))
			events.fire(CLICK, { type:text.text.toLowerCase() } );
	}
}