#region jsDoc
/// @func    GUICompScrollingText()
/// @desc    Creates a scrolling text component
/// @self    GUICompScrollingText
/// @param   {Real} x : The x possition of the component on screen.
/// @param   {Real} y : The y possition of the component on screen.
/// @return {Struct.GUICompScrollingText}
#endregion
function GUICompScrollingText() : GUICompCore() constructor {
	debug_name = "GUICompScrollingText"
	
	#region Public
		
		#region Builder functions
			
			static set_region = function(_left, _top, _right, _bottom) {
				__SUPER__.set_region(_left, _top, _right, _bottom)
				
				__update_clip_region__()
				
				return self;
			}
			#region jsDoc
			/// @func    set_scroll_speeds()
			/// @desc    Sets the current speed of the scrolling text. These speeds act like velocity and will imply moving left or right depending on if it's positive or negative.
			/// @self    GUICompScrollingText
			/// @param   {Real} hspeed : The text's horizontal speed.
			/// @param   {Real} vspeed : The text's vertical speed.
			/// @returns {Struct.GUICompScrollingText}
			#endregion
			static set_scroll_speeds = function(_hspeed=-2, _vspeed=0) {
				scroll.x_speed = _hspeed;
				scroll.y_speed = _vspeed;
				
				scroll.orig_y_speed = scroll.y_speed;
				scroll.orig_x_speed = scroll.x_speed;
				
				return self;
			}
			#region jsDoc
			/// @func    set_scroll_looping()
			/// @desc    Sets if the x and/or y directions should loop around the canvas, setting one to false will cause the scrolling text to bounce back and forth.
			/// @self    GUICompScrollingText
			/// @param   {Bool} x_loop : If the horizontal direction should loop around the canvase
			/// @param   {Bool} y_loop : If the horizontal direction should loop around the canvase
			/// @returns {Struct.GUICompScrollingText}
			#endregion
			static set_scroll_looping = function(_x_loop=false, _y_loop=false) {
				scroll.x_looping = _x_loop;
				scroll.y_looping = _y_loop;
				
				return self;
			}
			#region jsDoc
			/// @func    set_scroll_pause()
			/// @desc    Sets the text's scrolling to either be paused or unpaused. true = paused, false = unpaused.
			/// @self    GUICompScrollingText
			/// @param   {Bool} paused : If scrolling is paused.
			/// @returns {Struct.GUICompScrollingText}
			#endregion
			static set_scroll_pause = function(_paused=true){
				scroll.paused = _paused;
				
				return self;
			}
			#region jsDoc
			/// @func    set_scroll_offsets()
			/// @desc    Sets the current position of the scrolling text.
			/// @self    GUICompScrollingText
			/// @param   {Real} xoff : The current x possition of the scrolling text.
			/// @param   {Real} yoff : The current y possition of the scrolling text.
			/// @returns {Struct.GUICompScrollingText}
			#endregion
			static set_scroll_offsets = function(_xoff=0, _yoff=0){
				scroll.x_off = _xoff;
				scroll.y_off = _yoff;
				
				scroll.orig_x_off   = scroll.x_off;
				scroll.orig_y_off   = scroll.y_off;
				
				return self;
			}
			#region jsDoc
			/// @func    set_text()
			/// @desc    Sets the variables for text drawing
			/// @self    GUICompScrollingText
			/// @param   {String} text : The text to write on the button
			/// @param   {Real} text_click_y_off : How much the text should be moved when the mouse button is held down on the button
			/// @returns {Struct.GUICompScrollingText}
			#endregion
			static set_text = function(_text="DefaultText") {
				text.text = _text;
				
				draw_set_font(text.font);
				text.width  = string_width(text.text);
				text.height = string_height(text.text);
				
				return self;
			}
			#region jsDoc
			/// @func    set_text_font()
			/// @desc    Sets the font which will be used for drawing the text
			/// @self    GUICompScrollingText
			/// @param   {Asset.GMFont} font : The font to use when drawing the text
			/// @returns {Struct.GUICompScrollingText}
			#endregion
			static set_text_font = function(_font=fGUIDefault) {
				text.font = _font;								// font
				
				draw_set_font(text.font);
				text.width  = string_width(text.text);
				text.height = string_height(text.text);
				
				
				return self;
			}
			#region jsDoc
			/// @func    set_text_color()
			/// @desc    Sets the colors for the text.
			/// @self    GUICompScrollingText
			/// @param   {Real} color : The color to draw the text
			/// @returns {Struct.GUICompScrollingText}
			#endregion
			static set_text_color = function(_color=c_white) {
				text.color = _color;
				
				return self;
			}
			#region jsDoc
			/// @func    set_text_alpha()
			/// @desc    Sets the alpha for the text.
			/// @self    GUICompScrollingText
			/// @param   {Real} alpha : The alpha to draw the text
			/// @returns {Struct.GUICompScrollingText}
			#endregion
			static set_text_alpha = function(_alpha=1) {
				text.alpha = _alpha;
				
				return self;
			}
			#region jsDoc
			/// @func    set_text_alignment()
			/// @desc    Sets how the text is aligned when drawing
			/// @self    GUICompScrollingText
			/// @param   {Constant.HAlign} halign : The text horizontal alignment.
			/// @param   {Constant.VAlign} valign : The text vertical alignment.
			/// @returns {Struct.GUICompScrollingText}
			#endregion
			static set_text_alignment = function(_h=fa_left, _v=fa_top) {
				text.halign = _h;
				text.valign = _v;
				
				__update_clip_region__()
				
				return self;
			};
			#region jsDoc
			/// @func    set_text_offsets()
			/// @desc    Sets the Text's offsets
			/// @self    GUICompScrollingText
			/// @param   {Real} x : The x offset
			/// @param   {Real} y : The y offset
			/// @returns {Struct.GUICompScrollingText}
			#endregion
			static set_text_offsets = function(_x=0, _y=0) {
				text.x_off = _x;
				text.y_off = _y;
				
				__update_clip_region__()
				
				return self;
			};
			
		#endregion
		
		#region Variables
			
			is_open = true; // unused, but left here so buttons can minimize this component in the future
			
			text = {};
			text.text = "<Undefined>";
			text.font = fGUIDefault;
			text.width  = 0;
			text.height = 0;
			text.color = c_white;
			text.alpha = 1;
			text.x_off = 0;
			text.y_off = 0;
			
			scroll = {};
			scroll.y_off = 0;
			scroll.x_off = 0;
			scroll.y_speed = 0;
			scroll.x_speed = 0;
			scroll.x_looping = true;
			scroll.y_looping = true;
			//origin variables for setting and reseting
			scroll.orig_y_off   = scroll.y_off;
			scroll.orig_x_off   = scroll.x_off;
			scroll.orig_y_speed = scroll.y_speed;
			scroll.orig_x_speed = scroll.x_speed;
			
			scroll.paused = false;
			
		#endregion
		
		#region Functions
			
			#region GML Events
				
				static draw_gui = function(_input) {
					draw_set_font(text.font);
					draw_set_alpha(text.alpha);
					draw_set_color(text.color);
					draw_set_halign(text.halign);
					draw_set_valign(text.valign);
					
					draw_text(
							x + scroll.x_off + text.x_off,
							y + scroll.y_off + text.y_off,
							text.text
					)
				}
				
			#endregion
			
			#region jsDoc
			/// @func    reset_scrolling()
			/// @desc    Resets the text scrolling back to the originally defiened locations.
			/// @self    GUICompScrollingText
			/// @returns {Undefined}
			#endregion
			static reset_scrolling = function() {
				scroll.x_off = scroll.orig_x_off;
				scroll.y_off = scroll.orig_y_off;
				scroll.y_speed = scroll.orig_y_speed;
				scroll.x_speed = scroll.orig_x_speed;
			}
			#region jsDoc
			/// @func    scroll_pause()
			/// @desc    Pauses the scrolling. Commonly used when no longer mousing over a component.
			/// @self    GUICompScrollingText
			/// @returns {Undefined}
			#endregion
			static scroll_pause = function(){
				set_scroll_pause(true)
			};
			#region jsDoc
			/// @func    scroll_unpause()
			/// @desc    Unpauses the scrolling. Commonly used when mousing over a component.
			/// @self    GUICompScrollingText
			/// @returns {Undefined}
			#endregion
			static scroll_unpause = function(){
				set_scroll_pause(false)
			};
			
			static draw_debug = function(_input) {
				
				
				
				draw_line(x, y, x+scroll.x_off, y+scroll.y_off);
				draw_text(x,y,string(scroll.x_off)+"\n"+string(scroll.y_off));
				draw_rectangle(x, y, x+region.get_width(), y+region.get_height(), true);
				draw_rectangle(
						x+scroll.x_off,
						y+scroll.y_off,
						x+scroll.x_off+text.width,
						y+scroll.y_off+text.height,
						true
				);
				
				draw_set_color(c_yellow)
				draw_rectangle(
						x+clip_region.left,
						y+clip_region.top,
						x+clip_region.right,
						y+clip_region.bottom,
						true
				);
				
			}
			
		#endregion
		
	#endregion
	
	#region Private Library
		
		#region Variables
			
			//used as a custom clipping tool for the shader
			clip_region = new __region__(0,0,0,0);
			
		#endregion
		
		#region Functions
			
			static __draw_gui_begin__ = function(_input) {
				
				#region jsDoc
				/// @func    _wrap()
				/// @desc    Similar to clamp but will wrap the value, instead of clamping it.
				/// @param   {Real} value : The value to wrap.
				/// @param   {Real} min   : The minimum value.
				/// @param   {Real} max   : The maximum value.
				/// @returns {Real}
				/// @ignore
				#endregion
				static _wrap = function(_value,_min,_max) {
					if ( max == 0 ) { return 0; }
	
					var _mod = ( _value - _min ) mod ( _max - _min );
					if ( _mod < 0 ) return _mod + _max else return _mod + _min;
				}
				
				if (text.width > region.get_width())
				&& (!scroll.paused) {
					scroll.x_off += scroll.x_speed;
					//if x looping
					if (scroll.x_looping) {
						scroll.x_off = _wrap(
								scroll.x_off,
								-text.width,
								region.get_width()
						)
					}
					else {
						//if moving right
						if (scroll.x_off >= 0) {
							scroll.x_off = 0;
							scroll.x_speed *= -1;
						}
						//if moving left
						else if (scroll.x_off <= -text.width+region.get_width()) {
							scroll.x_off = -text.width+region.get_width();
							scroll.x_speed *= -1;
						};
				
					}
				}
				
				if (text.height > region.get_height())
				&& (!scroll.paused) {
					scroll.y_off += scroll.y_speed;
					// if y looping
					if (scroll.y_looping) {
						scroll.y_off = _wrap(
								scroll.y_off,
								-text.height,
								region.get_height()
						)
					}
					else {
						//if moving right
						if (scroll.y_off >= 0) {
							scroll.y_off = 0;
							scroll.y_speed *= -1;
						}
						//if moving left
						else if (scroll.y_off <= -text.height+region.get_height()) {
							scroll.y_off = -text.height+region.get_height();
							scroll.y_speed *= -1;
						};
				
					}
				}
				
				__shader_set__(clip_region);
				draw_gui_begin(_input)
				__shader_reset__();
				//__draw_component_surface__(_x, _y);
				
			}
			static __draw_gui__ = function(_input) {
				__shader_set__(clip_region);
				draw_gui(_input)
				__shader_reset__();
				//__draw_component_surface__(_x, _y);
			}
			static __draw_gui_end__ = function(_input) {
				__shader_set__(clip_region);
				draw_gui_end(_input);
				__shader_reset__();
				
				xprevious = x;
				yprevious = y;
				
				if (GUI_GLOBAL_DEBUG) {
					draw_debug(_input);
				}
				
				//__draw_component_surface__(_x, _y);
			}
			
			#region jsDoc
			/// @func    __update_clip_region__()
			/// @desc    Update the shader's bounding box for clipping
			/// @self    GUICompScrollingText
			/// @returns {Undefined}
			#endregion
			static __update_clip_region__ = function() {
				var _left   = 0;
				var _right  = 0;
				var _top    = 0;
				var _bottom = 0;
				
				switch (text.halign) {
					default:
					case fa_left:{
						_left   = min(_left,   text.x_off);
						_right  = max(_right,  text.x_off + region.get_width());
					break;}
					case fa_center:{
						_left   = min(_left,   text.x_off - region.get_width()*0.5);
						_right  = max(_right,  text.x_off + region.get_width()*0.5);
					break;}
					case fa_right:{
						_left   = min(_left,   text.x_off - region.get_width());
						_right  = max(_right,  text.x_off);
					break;}
				}
				
				switch (text.valign) {
					default:
					case fa_top:{
						_top    = min(_top,    text.y_off);
						_bottom = max(_bottom, text.y_off + region.get_height());
					break;}
					case fa_middle:{
						_top    = min(_top,    text.y_off - region.get_height()*0.5);
						_bottom = max(_bottom, text.y_off + region.get_height()*0.5);
					break;}
					case fa_bottom:{
						_top    = min(_top,    text.y_off - region.get_height());
						_bottom = max(_bottom, text.y_off);
					break;}
				}
				
				clip_region.left   = _left;
				clip_region.right  = _right;
				clip_region.top    = _top;
				clip_region.bottom = _bottom;
			}
		#endregion
		
	#endregion
	
}


