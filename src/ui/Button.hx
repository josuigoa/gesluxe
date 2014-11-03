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
	
    var nineSlice : NineSlice;
    var text : Text;
	public var size_rect (default, null): Rectangle;
	
	public function new(txt:String = null, btnTexture:Texture = null, _options:VisualOptions = null) 
	{
		super(_options);
		
		var mb = (_options != null && _options.batcher != null) ? _options.batcher : Luxe.renderer.batcher;
		
		nineSlice = new NineSlice({
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
							size: 35
							} );
		
		var sc = text.text_options.size / text.font.font_size;
        var textSize = text.font.get_text_dimensions(txt, new Vector(sc, sc));
		size_rect = new Rectangle(pos.x - textSize.x * .1, pos.y - textSize.y * .1, textSize.x * 1.2, textSize.y * 1.2);
		
        nineSlice.create( new Vector(size_rect.x, size_rect.y), size_rect.w, size_rect.h);
	}
	
	#if !mobile
	override public function ontouchdown(event:TouchEvent) 
	{
		super.ontouchdown(event);
		
		if (size_rect.point_inside(event.))
			nineSlice.color = new Color().rgb(0x009900);
	}
	
	override public function ontouchup(event:TouchEvent) 
	{
		super.ontouchup(event);
		
		nineSlice.color = new Color().rgb(0x009900);
		if (size_rect.point_inside(point))
			events.fire(CLICK, { type:text.text.toLowerCase() } );
	}
	#else
	override public function onmousedown(event:MouseEvent)
	{
		super.onmousedown(event);
		
		if (size_rect.point_inside(event.pos))
			nineSlice.color = new Color().rgb(0x009900);
	}
	override public function onmouseup(event:MouseEvent)
	{
		super.onmouseup(event);
		
		nineSlice.color = new Color().rgb(0x009900);
		if (size_rect.point_inside(event.pos))
			events.fire(CLICK, { type:text.text.toLowerCase() } );
	}
	#end
}