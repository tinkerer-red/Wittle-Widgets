#region jsDoc
/// @func    WWTextScrolling()
/// @desc    Creates a scrolling text component
/// @self    WWTextScrolling
/// @param   {Real} x : The x possition of the component on screen.
/// @param   {Real} y : The y possition of the component on screen.
/// @return {Struct.WWTextScrolling}
#endregion
function WWTextScrolling() : WWCore() constructor {
	debug_name = "WWTextScrolling"
	
	#region Public
		
		#region Builder functions
			
			#region jsDoc
			/// @func    set_scroll_speeds()
			/// @desc    Sets the current speed of the scrolling text. These speeds act like velocity and will imply moving left or right depending on if it's positive or negative.
			/// @self    WWScrollingText
			/// @param   {Real} hspeed : The text's horizontal speed.
			/// @param   {Real} vspeed : The text's vertical speed.
			/// @returns {Struct.WWScrollingText}
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
			/// @self    WWScrollingText
			/// @param   {Bool} x_loop : If the horizontal direction should loop around the canvase
			/// @param   {Bool} y_loop : If the horizontal direction should loop around the canvase
			/// @returns {Struct.WWScrollingText}
			#endregion
			static set_scroll_looping = function(_x_loop=false, _y_loop=false) {
				scroll.x_looping = _x_loop;
				scroll.y_looping = _y_loop;
				
				return self;
			}
			#region jsDoc
			/// @func    set_scroll_pause()
			/// @desc    Sets the text's scrolling to either be paused or unpaused. true = paused, false = unpaused.
			/// @self    WWScrollingText
			/// @param   {Bool} paused : If scrolling is paused.
			/// @returns {Struct.WWScrollingText}
			#endregion
			static set_scroll_pause = function(_paused=true){
				scroll.paused = _paused;
				
				return self;
			}
			#region jsDoc
			/// @func    set_scroll_offsets()
			/// @desc    Sets the current position of the scrolling text.
			/// @self    WWScrollingText
			/// @param   {Real} xoff : The current x possition of the scrolling text.
			/// @param   {Real} yoff : The current y possition of the scrolling text.
			/// @returns {Struct.WWScrollingText}
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
			/// @self    WWScrollingText
			/// @param   {String} text : The text to write on the button
			/// @param   {Real} text.click_yoff : How much the text should be moved when the mouse button is held down on the button
			/// @returns {Struct.WWScrollingText}
			#endregion
			static set_text = function(_text="DefaultText") {
				text.content = _text;
				
				draw_set_font(text.font);
				text.width  = string_width(text.content);
				text.height = font_get_info(text.font).size;
				
				if (!__size_set__) {
					__update_region_from_text__();
				}
				
				return self;
			}
			#region jsDoc
			/// @func    set_text_font()
			/// @desc    Sets the font which will be used for drawing the text
			/// @self    WWScrollingText
			/// @param   {Asset.GMFont} font : The font to use when drawing the text
			/// @returns {Struct.WWScrollingText}
			#endregion
			static set_text_font = function(_font=fGUIDefault) {
				text.font = _font;								// font
				
				draw_set_font(text.font);
				text.width  = string_width(text.content);
				text.height = font_get_info(text.font).size;
				
				if (!__size_set__) {
					__update_region_from_text__();
				}
				
				return self;
			}
			#region jsDoc
			/// @func    set_text_color()
			/// @desc    Sets the colors for the text.
			/// @self    WWScrollingText
			/// @param   {Real} color : The color to draw the text
			/// @returns {Struct.WWScrollingText}
			#endregion
			static set_text_color = function(_color=c_white) {
				text.color = _color;
				
				return self;
			}
			#region jsDoc
			/// @func    set_text_alpha()
			/// @desc    Sets the alpha for the text.
			/// @self    WWScrollingText
			/// @param   {Real} alpha : The alpha to draw the text
			/// @returns {Struct.WWScrollingText}
			#endregion
			static set_text_alpha = function(_alpha=1) {
				text.alpha = _alpha;
				
				return self;
			}
			#region jsDoc
			/// @func    set_text_alignment()
			/// @desc    Sets how the text is aligned when drawing
			/// @self    WWScrollingText
			/// @param   {Constant.HAlign} halign : The text horizontal alignment.
			/// @param   {Constant.VAlign} valign : The text vertical alignment.
			/// @returns {Struct.WWScrollingText}
			#endregion
			static set_text_alignment = function(_h=fa_left, _v=fa_top) {
				text.halign = _h;
				text.valign = _v;
				
				return self;
			};
			#region jsDoc
			/// @func    set_text_offsets()
			/// @desc    Sets the Text's offsets
			/// @self    WWScrollingText
			/// @param   {Real} x : The x offset
			/// @param   {Real} y : The y offset
			/// @returns {Struct.WWScrollingText}
			#endregion
			static set_text_offsets = function(_x=0, _y=0) {
				text.xoff = _x;
				text.yoff = _y;
				
				if (!__size_set__) {
					__update_region_from_text__();
				}
				
				return self;
			};
			
		#endregion
		
		#region Variables
			
			text.color = c_white;
			
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
				
				static draw_my_text = function() {
					draw_set_font(text.font);
					draw_set_alpha(text.alpha);
					draw_set_color(text.color);
					draw_set_halign(text.halign);
					draw_set_valign(text.valign);
					
					draw_text(
						x + scroll.x_off + text.xoff,
						y + scroll.y_off + text.yoff,
						text.content
					)
					
				}
				on_pre_draw(function(_input) {
					
					var _should_cull = false;
					if (text.width > region.get_width())
					|| (text.height > region.get_height()) {
						_should_cull = true;
						var _scissor = gpu_get_scissor();
						gpu_set_scissor(
							x+region.left,
							y+region.top,
							region.get_width(),
							region.get_height()
						)
						
					}
					
					//do drawing
					draw_my_text()
					
					if (_should_cull) gpu_set_scissor(_scissor)
					
				})
				on_pre_draw(function(_input) {
					
					#region jsDoc
					/// @func    __wrap()
					/// @desc    Similar to clamp but will wrap the value, instead of clamping it.
					/// @param   {Real} value : The value to wrap.
					/// @param   {Real} min   : The minimum value.
					/// @param   {Real} max   : The maximum value.
					/// @returns {Real}
					/// @ignore
					#endregion
					static __wrap = function(_value,_min,_max) {
						if ( max == 0 ) { return 0; }
						
						var _mod = ( _value - _min ) mod ( _max - _min );
						if ( _mod < 0 ) return _mod + _max else return _mod + _min;
					}
					
					if (text.width > region.get_width())
					&& (!scroll.paused) {
						scroll.x_off += scroll.x_speed;
						//if x looping
						if (scroll.x_looping) {
							scroll.x_off = __wrap(
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
							scroll.y_off = __wrap(
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
					
				})
			#endregion
			
			#region jsDoc
			/// @func    reset_scrolling()
			/// @desc    Resets the text scrolling back to the originally defiened locations.
			/// @self    WWScrollingText
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
			/// @self    WWScrollingText
			/// @returns {Undefined}
			#endregion
			static scroll_pause = function(){
				set_scroll_pause(true)
			};
			#region jsDoc
			/// @func    scroll_unpause()
			/// @desc    Unpauses the scrolling. Commonly used when mousing over a component.
			/// @self    WWScrollingText
			/// @returns {Undefined}
			#endregion
			static scroll_unpause = function(){
				set_scroll_pause(false)
			};
			
		#endregion
		
	#endregion
	
	#region Private Library
		
		#region Variables
			
			
			
		#endregion
		
		#region Functions
			
			static __update_region_from_text__ = function() {
				var _left, _right, _top, _bottom;
				
				// Get text width & height
			    var _text_width = text.width;
			    var _text_height = text.height;
				
				// Adjust the bounding box based on alignment
				switch (text.halign) {
				    case fa_left:
				        _left  = text.xoff;
				        _right = text.xoff + _text_width;
				        break;
				    case fa_center:
				        _left = text.xoff - _text_width * 0.5;
				        _right = text.xoff + _text_width * 0.5;
				        break;
				    case fa_right:
				        _left = text.xoff - _text_width;
				        _right = text.xoff;
				        break;
				}
				
				switch (text.valign) {
				    case fa_top:
				        _top = text.yoff;
				        _bottom = text.yoff + _text_height;
				        break;
				    case fa_middle:
				        _top = text.yoff - _text_height * 0.5;
				        _bottom = text.yoff + _text_height * 0.5;
				        break;
				    case fa_bottom:
				        _top = text.yoff - _text_height;
				        _bottom = text.yoff;
				        break;
				}
				
				__set_size__(_left, _top, _right, _bottom);
				
			}
			
		#endregion
		
	#endregion
	
}

function WWTextScribbleScrolling() : WWTextScrolling() constructor {
	
	#region Public
		
		#region Builder functions
			
			static set_scribble = function(_scrib) {
				my_scribble = _scrib;
				if (!__size_set__) {
					__update_region_from_text__()
				}
				return self;
			}
			static set_scribble_typist = function(_typist) {
				my_typist = _typist;
				if (!__size_set__) {
					__update_region_from_text__()
				}
				return self;
			}
			
		#endregion
		
		#region Variables
			
			my_scribble = scribble("");
			my_typist   = undefined;
			
		#endregion
		
		#region Functions
			
			#region GML Events
				
				static draw_my_text = function() {
					my_scribble.draw(
						x + scroll.x_off + text.xoff,
						y + scroll.y_off + text.yoff,
						my_typist
					)
				}
				
			#endregion
			
		#endregion
		
	#endregion
	
	#region Private Library
		
		#region Variables
			
			
			
		#endregion
		
		#region Functions
			
			static __update_region_from_text__ = function() {
				var _left   = x - _scrib.get_left();
				var _top    = y - _scrib.get_top();
				var _right  = x - _scrib.get_right();
				var _bottom = y - _scrib.get_bottom();
				__set_size__(_left, _top, _right, _bottom);
			}
			
		#endregion
		
	#endregion
	
}
