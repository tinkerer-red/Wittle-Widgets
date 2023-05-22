#region jsDoc
/// @func    GUICompSlider()
/// @desc    Creates a slider.
/// @param   {Real} x : The x possition of the component on screen.
/// @param   {Real} y : The y possition of the component on screen.
/// @returns {Struct.GUICompSlider}
#endregion
function GUICompSlider(_x, _y) : GUICompCore(_x, _y) constructor {//log(["GUICompSlider", GUICompSlider])
	debug_name = "GUICompSlider";
	
	#region Public
		
		#region Builder Functions
			
			#region jsDoc
			/// @func    set_region()
			/// @desc    Set the reletive region for all click selections. Reletive to the x,y of the component.
			/// @self    GUICompCore
			/// @param   {real} left : The left side of the bounding box
			/// @param   {real} top : The top side of the bounding box
			/// @param   {real} right : The right side of the bounding box
			/// @param   {real} bottom : The bottom side of the bounding box
			/// @returns {Struct.GUICompCore}
			#endregion
			static set_region = function(_left, _top, _right, _bottom) {//log(["set_region", set_region])log(["set_region", set_region])
				static super = __CREATE_SUPER__
				method(self, super.set_region)(_left, _top, _right, _bottom);
				
				__find_slider_bounds__();
				
				return self;
			}
			
			#region jsDoc
			/// @func    set_value()
			/// @desc    Sets the value of the slider
			/// @self    GUICompSlider
			/// @param   {Real} value : The value to set the slider to.
			/// @returns {Struct.GUICompSlider}
			#endregion
			static set_value = function(_value) {//log(["set_value", set_value])log(["set_value", set_value])
				__set_value__(_value)
				
				target_value = value;
				
				return self;
			}
			
			#region jsDoc
			/// @func    set_normalized_value()
			/// @desc    Sets the value of the slider using a normalized input, The input must be a value between 0 and 1. This is similar to the lerp function.
			/// @self    GUICompSlider
			/// @param   {Real} value : The normalized value to set the slider to.
			/// @returns {Struct.GUICompSlider}
			#endregion
			static set_normalized_value = function(_value) {//log(["set_normalized_value", set_normalized_value])
				__set_normalized_value__(_value);
				
				target_value = value;
				
				return self;
			}
			
			#region jsDoc
			/// @func    set_clamp_values()
			/// @desc    Sets the slider's min and max bounds.
			/// @self    GUICompSlider
			/// @param   {Real} min : The min value of the slider.
			/// @param   {Real} max : The max value of the slider.
			/// @returns {Struct.GUICompSlider}
			#endregion
			static set_clamp_values = function(_min=0, _max=10) {//log(["set_clamp_values", set_clamp_values])
				
				min_value = _min;
				max_value = _max;
				
				set_value(value);
				
				return self;
			}
			
			#region jsDoc
			/// @func    set_rounding()
			/// @desc    Sets the rounding of the slider. Good for gathering integers from sliders
			/// @self    GUICompSlider
			/// @param   {Bool} should_round : If the slider's value should be rounded. true = round, false = no rounding.
			/// @returns {Struct.GUICompSlider}
			#endregion
			static set_rounding = function(_round=false) {//log(["set_rounding", set_rounding])
				
				round_value = _round
				set_value(value);
				
				return self;
			}
			
			#region jsDoc
			/// @func    set_input_enabled()
			/// @desc    Enable or disable the ability to adjust the slider, typically used for when you wish to make a progress bar so you can disable inputs.
			/// @self    GUICompSlider
			/// @param   {Bool} input_enabled : If the input is enabled or not. true = enabled, false = disabled.
			/// @returns {Struct.GUICompSlider}
			#endregion
			static set_input_enabled = function(_input_enabled=true) {//log(["set_input_enabled", set_input_enabled])
				
				input_enabled = _input_enabled;
		
				return self;
			}
			
			#region jsDoc
			/// @func    set_tracker()
			/// @desc    Sets a tracker function. A tracker function is typically used when you wish to edit a slider based off another objects variables. This function should always return the value which the slider will set it's self to.
			/// @self    GUICompSlider
			/// @param   {Function} func : The tracker function the slider will addapt with.
			/// @returns {Struct.GUICompSlider}
			#endregion
			static set_tracker = function(_func) {//log(["set_tracker", set_tracker])
				//the function should return the value it wishes to set the slider to, useful for methoding an instance to always apply it's variable to the slider as a progress bar.
				tracker_func = _func;
				
				return self;
			}
			
			#region jsDoc
			/// @func    set_vertical()
			/// @desc    Sets the slider to be vertical, this does not rotate the slider, only how the inputs and drawing are calculated.
			/// @self    GUICompSlider
			/// @param   {Bool} is_vertical : If the slider is vertically oriented. true = vertical, false = horizontal
			/// @returns {Struct.GUICompSlider}
			#endregion
			static set_vertical = function(_vert) {//log(["set_vertical", set_vertical])
				
				is_vertical = _vert
				
				return self;
			}
			
			#region jsDoc
			/// @func    set_thumb_only_input()
			/// @desc    Sets the slider to only accept inputs from the thumb. Normally used for when you which to have a scroll bar or lever style input.
			/// @self    GUICompSlider
			/// @param   {Bool} thumb_only_input : If the only available way to change the slider's value is with the thumb. true = thumb only, false = normal slider functionality.
			/// @returns {Struct.GUICompSlider}
			#endregion
			static set_thumb_only_input = function(_thumb_only_input) {//log(["set_thumb_only_input", set_thumb_only_input])
				
				thumb_only_input = _thumb_only_input
				
				return self;
			}
			
			#region jsDoc
			/// @func    set_target_value()
			/// @desc    This function will smoothly set the slider's value to a target value.
			/// @self    GUICompSlider
			/// @param   {Real} target_value : The target value the slider should smooth towards.
			/// @returns {Struct.GUICompSlider}
			#endregion
			static set_target_value = function(_target_value) {//log(["set_target_value", set_target_value])
				
				target_value = clamp(_target_value, min_value, max_value);
				
				if (round_value) {
					target_value = floor(target_value + 0.5);
				}
				
				return self;
			}
			
			#region Thumb
				
				#region jsDoc
				/// @func    set_thumb_enabled()
				/// @desc    Sets the thumb to be enabled
				/// @self    GUICompSlider
				/// @param   {Real} enabled : If the thumb is enabled
				/// @returns {Struct.GUICompSlider}
				#endregion
				static set_thumb_enabled = function(_enabled=true) {//log(["set_thumb_enabled", set_thumb_enabled])
					thumb.enabled = _enabled
					
					__find_slider_bounds__();
					
					return self;
				}
				
				#region jsDoc
				/// @func    set_thumb_sprite()
				/// @desc    Sets the thumb sprite to be used in the slider component.
				/// @self    GUICompSlider
				/// @param   {Asset.GMSprite} sprite : The sprite to use for the thumb.
				/// @returns {Struct.GUICompSlider}
				#endregion
				static set_thumb_sprite = function(_sprite=-1) {//log(["set_thumb_sprite", set_thumb_sprite])
					thumb.sprite = _sprite
					set_thumb_min_colors(c_white, c_white, c_white, c_white)
					set_thumb_max_colors(c_white, c_white, c_white, c_white)
					
					__find_slider_bounds__();
					
					return self;
				}
				
				#region jsDoc
				/// @func    set_thumb_alpha()
				/// @desc    Sets the alpha value of the thumb sprite in the slider component.
				/// @self    GUICompSlider
				/// @param   {Real} alpha : The alpha value to set for the thumb.
				/// @returns {Struct.GUICompSlider}
				#endregion
				static set_thumb_alpha = function(_alpha=1) {//log(["set_thumb_alpha", set_thumb_alpha])
					thumb.alpha = _alpha
					
					return self;
				}
				
				#region jsDoc
				/// @func    set_thumb_min_colors()
				/// @desc    Sets the colors of the thumb sprite when at minimum value in the slider component.
				/// @self    GUICompSlider
				/// @param   {Real} idle_col : The idle color for the thumb.
				/// @param   {Real} hover_col : The hover color for the thumb.
				/// @param   {Real} clicked_col : The clicked color for the thumb.
				/// @param   {Real} disabled_col : The disabled color for the thumb.
				/// @returns {Struct.GUICompSlider}
				#endregion
				static set_thumb_min_colors = function(_idle=c_white,_hover=c_white,_clicked=c_white,_disabled=c_gray) {//log(["set_thumb_min_colors", set_thumb_min_colors])
					thumb.min_color.idle     = _idle;
					thumb.min_color.hover    = _hover;
					thumb.min_color.clicked  = _clicked;
					thumb.min_color.disabled = _disabled;
					
					return self;
				}
				
				#region jsDoc
				/// @func    set_thumb_max_colors()
				/// @desc    Sets the colors of the thumb sprite when at maximum value in the slider component.
				/// @self    GUICompSlider
				/// @param   {Real} idle_col : The idle color for the thumb.
				/// @param   {Real} hover_col : The hover color for the thumb.
				/// @param   {Real} clicked_col : The clicked color for the thumb.
				/// @param   {Real} disabled_col : The disabled color for the thumb.
				/// @returns {Struct.GUICompSlider}
				#endregion
				static set_thumb_max_colors = function(_idle=c_white,_hover=c_white,_clicked=c_white,_disabled=c_gray) {//log(["set_thumb_max_colors", set_thumb_max_colors])
					thumb.max_color.idle     = _idle;
					thumb.max_color.hover    = _hover;
					thumb.max_color.clicked  = _clicked;
					thumb.max_color.disabled = _disabled;
					
					return self;
				}
				
				#region jsDoc
				/// @func    set_thumb_scales()
				/// @desc    Sets the scales of the thumb sprite in the slider component.
				/// @self    GUICompSlider
				/// @param   {Real} xscale : The X scale to set for the thumb.
				/// @param   {Real} yscale : The Y scale to set for the thumb.
				/// @returns {Struct.GUICompSlider}
				#endregion
				static set_thumb_scales = function(_xscale=0, _yscale=0) {//log(["set_thumb_scales", set_thumb_scales])
					//sets the width and height of the thumb. Note: a value of 0 will always use it's default size. If you wish to prevent the thumbs drawing use "set_thumb_enabled".
					
					thumb.xscale = _xscale;
					thumb.yscale = _yscale;
					
					__find_slider_bounds__();
					
					return self;
				}
				
				#region jsDoc
				/// @func    set_thumb_clamped_in_bounds()
				/// @desc    Sets whether the thumb sprite is clamped within the bounds of the slider component or not. This is usually only used if you are attempting to create a scroll bar
				/// @self    GUICompSlider
				/// @param   {Real} clamped : If the thumb is clamped in bounds. true = clamped, false = not clamped.
				/// @returns {Struct.GUICompSlider}
				#endregion
				static set_thumb_clamped_in_bounds = function(_clamped=true) {//log(["set_thumb_clamped_in_bounds", set_thumb_clamped_in_bounds])
					
					thumb.clamped = _clamped;
					
					__find_slider_bounds__();
					
					return self;
				}
				
			#endregion
			
			#region Bar
				
				#region jsDoc
				/// @func    set_bar_enabled()
				/// @desc    Sets the bar to be enabled
				/// @self    GUICompSlider
				/// @param   {Real} enabled : If the bar is enabled
				/// @returns {Struct.GUICompSlider}
				#endregion
				static set_bar_enabled = function(_enabled=1) {//log(["set_bar_enabled", set_bar_enabled])
					bar.enabled = _enabled
					
					return self;
				}
				
				#region jsDoc
				/// @func    set_bar_sprite()
				/// @desc    Sets the bar to be used in the slider component.
				/// @self    GUICompSlider
				/// @param   {Asset.GMSprite} sprite : The sprite to use for the bar.
				/// @returns {Struct.GUICompSlider}
				#endregion
				static set_bar_sprite = function(_sprite=-1) {//log(["set_bar_sprite", set_bar_sprite])
					bar.sprite = _sprite
					set_bar_min_colors(c_white, c_white, c_white, c_white)
					set_bar_max_colors(c_white, c_white, c_white, c_white)
					
					return self;
				}
				
				#region jsDoc
				/// @func    set_bar_alpha()
				/// @desc    Sets the alpha value of the bar sprite in the slider component.
				/// @self    GUICompSlider
				/// @param   {Real} alpha : The alpha value to set for the bar.
				/// @returns {Struct.GUICompSlider}
				#endregion
				static set_bar_alpha = function(_alpha=1) {//log(["set_bar_alpha", set_bar_alpha])
					bar.alpha = _alpha
					
					return self;
				}
				
				#region jsDoc
				/// @func    set_bar_min_colors()
				/// @desc    Sets the colors of the bar sprite when at minimum value in the slider component.
				/// @self    GUICompSlider
				/// @param   {Real} idle_col : The idle color for the bar.
				/// @param   {Real} hover_col : The hover color for the bar.
				/// @param   {Real} clicked_col : The clicked color for the bar.
				/// @param   {Real} disabled_col : The disabled color for the bar.
				/// @returns {Struct.GUICompSlider}
				#endregion
				static set_bar_min_colors = function(_idle=c_white,_hover=c_white,_clicked=c_white,_disabled=c_gray) {//log(["set_bar_min_colors", set_bar_min_colors])
					bar.min_color.idle     = _idle;
					bar.min_color.hover    = _hover;
					bar.min_color.clicked  = _clicked;
					bar.min_color.disabled = _disabled;
					
					return self;
				}
				
				#region jsDoc
				/// @func    set_bar_max_colors()
				/// @desc    Sets the colors of the bar sprite when at maximum value in the slider component.
				/// @self    GUICompSlider
				/// @param   {Real} idle_col : The idle color for the bar.
				/// @param   {Real} hover_col : The hover color for the bar.
				/// @param   {Real} clicked_col : The clicked color for the bar.
				/// @param   {Real} disabled_col : The disabled color for the bar.
				/// @returns {Struct.GUICompSlider}
				#endregion
				static set_bar_max_colors = function(_idle=c_white,_hover=c_white,_clicked=c_white,_disabled=c_gray) {//log(["set_bar_max_colors", set_bar_max_colors])
					bar.max_color.idle     = _idle;
					bar.max_color.hover    = _hover;
					bar.max_color.clicked  = _clicked;
					bar.max_color.disabled = _disabled;
					
					return self;
				}
				
				#region jsDoc
				/// @func    set_bar_margin()
				/// @desc    Sets the border margins of the bar. This is the distance from the background's border the bar should stay away from.
				/// @self    GUICompSlider
				/// @param   {Real} margin : The margin to set for the bar. A margin of -1 will make the bar automatically scale to the background's center region of its nineslice if it's enabled.
				/// @returns {Struct.GUICompSlider}
				#endregion
				static set_bar_margin = function(_margin=1) {//log(["set_bar_margin", set_bar_margin])
					
					bar.margin = _margin
					
					__find_slider_bounds__();
					
					return self;
				}
				
				#region jsDoc
				/// @func    set_bar_auto_fill()
				/// @desc    Sets whether the bar should automatically fill its background.
				/// @self    GUICompSlider
				/// @param   {Bool} auto_fill : A boolean value indicating whether the bar should automatically fill its background or not.
				/// @returns {Struct.GUICompSlider}
				#endregion
				static set_bar_auto_fill = function(_auto_fill=true) {//log(["set_bar_auto_fill", set_bar_auto_fill])
					
					bar.margin = (_auto_fill) ? -1 : 0;
					
					return self;
				}
				
			#endregion
			
			#region Background
				
				#region jsDoc
				/// @func    set_background_enabled()
				/// @desc    Sets the background to be enabled
				/// @self    GUICompSlider
				/// @param   {Real} enabled : If the background is enabled
				/// @returns {Struct.GUICompSlider}
				#endregion
				static set_background_enabled = function(_enabled=1) {//log(["set_background_enabled", set_background_enabled])
					background.enabled = _enabled
					
					__find_slider_bounds__();
					
					return self;
				}
				
				#region jsDoc
				/// @func    set_background_sprite()
				/// @desc    Sets the background to be used in the slider component.
				/// @self    GUICompSlider
				/// @param   {Asset.GMSprite} sprite : The sprite to use for the background.
				/// @returns {Struct.GUICompSlider}
				#endregion
				static set_background_sprite = function(_sprite=-1) {//log(["set_background_sprite", set_background_sprite])
					background.sprite = _sprite
					
					set_background_min_colors(c_white, c_white, c_white, c_white)
					set_background_max_colors(c_white, c_white, c_white, c_white)
					
					__find_slider_bounds__();
					
					return self;
				}
				
				#region jsDoc
				/// @func    set_background_alpha()
				/// @desc    Sets the alpha value of the background sprite in the slider component.
				/// @self    GUICompSlider
				/// @param   {Real} alpha : The alpha value to set for the background.
				/// @returns {Struct.GUICompSlider}
				#endregion
				static set_background_alpha = function(_alpha=1) {//log(["set_background_alpha", set_background_alpha])
					background.alpha = _alpha
					
					return self;
				}
				
				#region jsDoc
				/// @func    set_background_min_colors()
				/// @desc    Sets the colors of the background sprite when at minimum value in the slider component.
				/// @self    GUICompSlider
				/// @param   {Real} idle_col : The idle color for the background.
				/// @param   {Real} hover_col : The hover color for the background.
				/// @param   {Real} clicked_col : The clicked color for the background.
				/// @param   {Real} disabled_col : The disabled color for the background.
				/// @returns {Struct.GUICompSlider}
				#endregion
				static set_background_min_colors = function(_idle=c_white,_hover=c_white,_clicked=c_white,_disabled=c_gray) {//log(["set_background_min_colors", set_background_min_colors])
					background.min_color.idle     = _idle;
					background.min_color.hover    = _hover;
					background.min_color.clicked  = _clicked;
					background.min_color.disabled = _disabled;
					
					return self;
				}
				
				#region jsDoc
				/// @func    set_background_max_colors()
				/// @desc    Sets the colors of the background sprite when at maximum value in the slider component.
				/// @self    GUICompSlider
				/// @param   {Real} idle_col : The idle color for the background.
				/// @param   {Real} hover_col : The hover color for the background.
				/// @param   {Real} clicked_col : The clicked color for the background.
				/// @param   {Real} disabled_col : The disabled color for the background.
				/// @returns {Struct.GUICompSlider}
				#endregion
				static set_background_max_colors = function(_idle=c_white,_hover=c_white,_clicked=c_white,_disabled=c_gray) {//log(["set_background_max_colors", set_background_max_colors])
					background.max_color.idle     = _idle;
					background.max_color.hover    = _hover;
					background.max_color.clicked  = _clicked;
					background.max_color.disabled = _disabled;
					
					return self;
				}
				
			#endregion
			
			#region Text
				
				#region jsDoc
				/// @func    set_text_enabled()
				/// @desc    Sets the text to be enabled
				/// @self    GUICompSlider
				/// @param   {Real} enabled : If the text is enabled
				/// @returns {Struct.GUICompSlider}
				#endregion
				static set_text_enabled = function(_enabled=1) {//log(["set_text_enabled", set_text_enabled])
					text.enabled = _enabled
					
					return self;
				}
				
				#region jsDoc
				/// @func    set_text_alignment()
				/// @desc    Sets how the text is aligned when drawing
				/// @self    GUICompSlider
				/// @param   {Constant.HAlign} halign : Horizontal alignment
				/// @param   {Constant.VAlign} valign : Vertical alignment
				/// @returns {Struct.GUICompSlider}
				#endregion
				static set_text_alignment = function(_alpha=1) {//log(["set_text_alignment", set_text_alignment])
					text.alpha = _alpha
					
					return self;
				}
				
				#region jsDoc
				/// @func    set_text_offsets()
				/// @desc    Sets the Text's offsets reletive to the component's x/y. Note: click_y will be applied in addition to the y, when the component is actively being pressed.
				/// @self    GUICompSlider
				/// @param   {Real} x : The x offset
				/// @param   {Real} y : The y offset
				/// @param   {Real} click_y : The additional y offset used when 
				/// @returns {Struct.GUICompSlider}
				#endregion
				static set_text_offsets = function(_x=0, _y=0, _click_y=2) {//log(["set_text_offsets", set_text_offsets])
					text.xoff = _x;
					text.yoff = _y;
					text.click_y_off = _click_y;
					
					return self;
				}
				
				#region jsDoc
				/// @func    set_text_min_colors()
				/// @desc    Sets the colors of the text sprite when at minimum value in the slider component.
				/// @self    GUICompSlider
				/// @param   {Real} idle_col : The idle color for the text.
				/// @param   {Real} hover_col : The hover color for the text.
				/// @param   {Real} clicked_col : The clicked color for the text.
				/// @param   {Real} disabled_col : The disabled color for the text.
				/// @returns {Struct.GUICompSlider}
				#endregion
				static set_text_min_colors = function(_idle=c_white,_hover=c_white,_clicked=c_white,_disabled=c_gray) {//log(["set_text_min_colors", set_text_min_colors])
					text.min_color.idle     = _idle;
					text.min_color.hover    = _hover;
					text.min_color.clicked = _clicked;
					text.min_color.disabled = _disabled;
					
					return self;
				}
				
				#region jsDoc
				/// @func    set_text_max_colors()
				/// @desc    Sets the colors of the text sprite when at maximum value in the slider component.
				/// @self    GUICompSlider
				/// @param   {Real} idle_col : The idle color for the text.
				/// @param   {Real} hover_col : The hover color for the text.
				/// @param   {Real} clicked_col : The clicked color for the text.
				/// @param   {Real} disabled_col : The disabled color for the text.
				/// @returns {Struct.GUICompSlider}
				#endregion
				static set_text_max_colors = function(_idle=c_white,_hover=c_white,_clicked=c_white,_disabled=c_gray) {//log(["set_text_max_colors", set_text_max_colors])
					text.max_color.idle     = _idle;
					text.max_color.hover    = _hover;
					text.max_color.clicked = _clicked;
					text.max_color.disabled = _disabled;
					
					return self;
				}
				
				#region jsDoc
				/// @func    set_text_font()
				/// @desc    Sets the font which will be used for drawing the text
				/// @self    GUICompButtonText
				/// @param   {Asset.GMFont} font : The font to use when drawing the text
				/// @returns {Struct.GUICompSlider}
				#endregion
				static set_text_font = function(_font=1) {//log(["set_text_font", set_text_font])
					text.font = _font
					
					return self;
				}
				
				#region jsDoc
				/// @func    set_text_alpha()
				/// @desc    Sets the alpha for the text.
				/// @self    GUICompSlider
				/// @param   {Real} alpha : The alpha to draw the text
				/// @returns {Struct.GUICompSlider}
				#endregion
				static set_text_alpha = function(_alpha=1) {//log(["set_text_alpha", set_text_alpha])
					text.alpha = _alpha
					
					return self;
				}
				
				#region jsDoc
				/// @func    set_text_to_string()
				/// @desc    Sets the function which is used to convert the value to a string. The functions input variables are "(value, min, max)". An example function which shows a percentage looks like "function(value, min, max){ return string((value-min_value) / (max_value-min_value)) + "%" }"
				/// @self    GUICompSlider
				/// @param   {Real} alpha : The alpha to draw the text
				/// @returns {Struct.GUICompSlider}
				#endregion
				static set_text_to_string = function(_func) {//log(["set_text_to_string", set_text_to_string])
					
					text.to_string = _func;
					
					return self;
				}
				
				#region jsDoc
				/// @func    set_text_outline_min_colors()
				/// @desc    Sets the colors of the text outline sprite when at minimum value in the slider component.
				/// @self    GUICompSlider
				/// @param   {Real} idle_col : The idle color for the text outline.
				/// @param   {Real} hover_col : The hover color for the text outline.
				/// @param   {Real} clicked_col : The clicked color for the text outline.
				/// @param   {Real} disabled_col : The disabled color for the text outline.
				/// @returns {Struct.GUICompSlider}
				#endregion
				static set_text_outline_min_colors = function(_idle=c_white,_hover=c_white,_clicked=c_white,_disabled=c_gray) {//log(["set_text_outline_min_colors", set_text_outline_min_colors])
					text.outline.min_color.idle     = _idle;
					text.outline.min_color.hover    = _hover;
					text.outline.min_color.clicked  = _clicked;
					text.outline.min_color.disabled = _disabled;
					
					return self;
				}
				
				#region jsDoc
				/// @func    set_text_outline_max_colors()
				/// @desc    Sets the colors of the text outline sprite when at maximum value in the slider component.
				/// @self    GUICompSlider
				/// @param   {Real} idle_col : The idle color for the text outline.
				/// @param   {Real} hover_col : The hover color for the text outline.
				/// @param   {Real} clicked_col : The clicked color for the text outline.
				/// @param   {Real} disabled_col : The disabled color for the text outline.
				/// @returns {Struct.GUICompSlider}
				#endregion
				static set_text_outline_max_colors = function(_idle=c_white,_hover=c_white,_clicked=c_white,_disabled=c_gray) {//log(["set_text_outline_max_colors", set_text_outline_max_colors])
					text.outline.max_color.idle     = _idle;
					text.outline.max_color.hover    = _hover;
					text.outline.max_color.clicked  = _clicked;
					text.outline.max_color.disabled = _disabled;
					
					return self;
				}
				
				#region jsDoc
				/// @func    set_text_outline_thickness()
				/// @desc    Sets the outline thickness for the text.
				/// @self    GUICompSlider
				/// @param   {Real} thickness : The thickness to draw the text outline.
				/// @returns {Struct.GUICompSlider}
				#endregion
				static set_text_outline_thickness = function(_thickness=0) {//log(["set_text_outline_thickness", set_text_outline_thickness])
					text.outline.thickness = _thickness;
					
					return self;
				}
				
				#region jsDoc
				/// @func    set_text_outline_alpha()
				/// @desc    Sets the alpha for the text outline.
				/// @self    GUICompSlider
				/// @param   {Real} alpha : The alpha to draw the text
				/// @returns {Struct.GUICompSlider}
				#endregion
				static set_text_outline_alpha = function(_alpha=0) {//log(["set_text_outline_alpha", set_text_outline_alpha])
					text.outline.alpha = _alpha;
					
					return self;
				}
				
			#endregion
			
		#endregion
		
		#region Events
			
			self.events.mouse_over = "mouse_over";
			self.events.pressed    = "pressed";
			self.events.held       = "held";
			self.events.released   = "released";
			
			self.events.value_input       = "value_input"; //if a value was input in any way, this will trigger every frame the slider is interacted wtih
			self.events.value_changed     = "value_changed"; //if a value was changed in any way, this will trigger only when the previous frame's value does not equal the current frames value
			self.events.value_incremented = "value_incremented"; //if a value was incremented, this will trigger only when the previous frame's value is less than the current frames value
			self.events.value_decremented = "value_decremented"; //if a value was decremented, this will trigger only when the previous frame's value greater than the current frames value
			
		#endregion
		
		#region Variables
			
			//pieces of the slider
			thumb = {
				sprite: -1,
				alpha : 1,
				min_color : {
					idle: c_white,
					hover: c_white,
					clicked: c_white,
					disabled: c_grey,
				},
				max_color : {
					idle: c_white,
					hover: c_white,
					clicked: c_white,
					disabled: c_grey,
				},
				image : {
					index : GUI_IMAGE_ENABLED,
				},
				clamped: false,
				enabled: false,
				xscale: 1,
				yscale: 1,
			};
			bar = {
				sprite: -1,
				alpha : 1,
				min_color : {
					idle: c_white,
					hover: c_white,
					clicked: c_white,
					disabled: c_grey,
				},
				max_color : {
					idle: c_white,
					hover: c_white,
					clicked: c_white,
					disabled: c_grey,
				},
				image : {
					index : GUI_IMAGE_ENABLED,
				},
				enabled: true,
				margin: 1,
			};
			background = {
				sprite: -1,
				alpha : 1,
				min_color : {
					idle: c_grey,
					hover: c_grey,
					clicked: c_grey,
					disabled: c_dkgrey,
				},
				max_color : {
					idle: c_grey,
					hover: c_grey,
					clicked: c_grey,
					disabled: c_dkgrey,
				},
				image : {
					index : GUI_IMAGE_ENABLED,
				},
				enabled: true,
			};
			text = {
				to_string: function(_val, _min, _max) {
					return string(_val)
				},
				enabled: false,
				font: fGUIDefault,
				alpha: 1,
				min_color : {
					idle: c_white,
					hover: c_white,
					clicked: c_white,
					disabled: c_grey,
				},
				max_color : {
					idle: c_white,
					hover: c_white,
					clicked: c_white,
					disabled: c_grey,
				},
				halign: fa_center,
				valign: fa_middle,
				xoff: 0,
				yoff: 0,
				outline: {
					min_color : {
						idle: c_white,
						hover: c_white,
						clicked: c_white,
						disabled: c_grey,
					},
					max_color : {
						idle: c_white,
						hover: c_white,
						clicked: c_white,
						disabled: c_grey,
					},
					alpha: 1,
					thickness: 0,
				}
			};
			
			input_enabled = true;
			
			min_value = 0;
			max_value = 1;
			value = 0.5;
			target_value = value;
			normalized_value = (0.5-min_value) / (max_value-min_value);
			round_value = false;
			
			is_vertical = false;
			thumb_only_input = false;
			
			tracker_func = undefined;
			
		#endregion
		
		#region Functions
			
			#region jsDoc
			/// @func    get_value()
			/// @desc    Returns the value of the component
			/// @self    GUICompSlider
			/// @returns {Real}
			#endregion
			static get_value = function() {//log(["get_value", get_value])
				return value;
			}
			
			static mouse_on_thumb = function() {//log(["mouse_on_thumb", mouse_on_thumb])
				
				var _x = __slider_bounds__.x;
				var _y = __slider_bounds__.y;
				
				var _w = __slider_bounds__.w;
				var _h = __slider_bounds__.h;
				
				var _min_x = __slider_bounds__.min_x;
				var _min_y = __slider_bounds__.min_y;
				
				var _max_x = __slider_bounds__.max_x;
				var _max_y = __slider_bounds__.max_y;
				
				var _thumb_x = (is_vertical)  ? _x + _w*0.5 : lerp(_min_x, _max_x, normalized_value);
				var _thumb_y = (!is_vertical) ? _y + _h*0.5 : lerp(_min_y, _max_y, normalized_value);
				
				
				var _left   = _thumb_x + sprite_get_xoffset(thumb.sprite) * thumb.xscale;
				var _top    = _thumb_y + sprite_get_yoffset(thumb.sprite) * thumb.yscale;
				var _right  = _left + sprite_get_width(thumb.sprite) * thumb.xscale;
				var _bottom = _top + sprite_get_height(thumb.sprite) * thumb.yscale;
				
				return point_in_rectangle(
						device_mouse_x_to_gui(0),
						device_mouse_y_to_gui(0),
						_left,
						_top,
						_right,
						_bottom
					);
			}
			
			#region GML Events
				
				static draw_gui = function(_input) {//log(["draw_gui", draw_gui])
					//early out if scrollbar is too small
					if (region.get_width() <= 0)
					|| (region.get_height() <= 0) {
						return
					}
				
					//define a function used in many places
					var _color_blend = function(_c1, _c2, _amt) {
						// Extract the red, green, and blue components of each color
						var _r1 = _c1 >> 16;
						var _g1 = (_c1 >> 8) & 0xFF;
						var _b1 = _c1 & 0xFF;
					
						var _r2 = _c2 >> 16;
						var _g2 = (_c2 >> 8) & 0xFF;
						var _b2 = _c2 & 0xFF;
					
						// Calculate the average RGB values of the two colors
						var _lerpedR = floor((1 - _amt) * _r1 + _amt * _r2);
						var _lerpedG = floor((1 - _amt) * _g1 + _amt * _g2);
						var _lerpedB = floor((1 - _amt) * _b1 + _amt * _b2);
					
						// Combine the RGB components into a single color integer
						var _blend = (_lerpedR << 16) | (_lerpedG << 8) | _lerpedB;
					
						return _blend;
					}
				
					#region Calculate Colors
						var _state;
						
						switch (image.index) {
							default:
							case GUI_IMAGE_ENABLED: {
									_state = "idle";
							break;}
							case GUI_IMAGE_HOVER: {
									_state = "hover";
							break;}
							case GUI_IMAGE_CLICKED: {
									_state = "clicked";
							break;}
							case GUI_IMAGE_DISABLED: {
									_state = "disabled";
							break;}
						}
						
						var _thumb_col    = (!thumb.enabled)    ? 0 : _color_blend(thumb.min_color[$ _state],      thumb.max_color[$ _state],      normalized_value);
						var _bar_col      = (!bar.enabled)      ? 0 : _color_blend(bar.min_color[$ _state],        bar.max_color[$ _state],        normalized_value);
						var _background_col = (!background.enabled) ? 0 : _color_blend(background.min_color[$ _state], background.max_color[$ _state], normalized_value);
						var _text_col     = (!text.enabled)     ? 0 : _color_blend(text.min_color[$ _state],       text.max_color[$ _state],       normalized_value);
						
						var _text_outline_col = ((!text.enabled) || (text.outline.thickness == 0)) ? 0 : _color_blend(text.outline.min_color[$ _state], text.outline.max_color[$ _state], normalized_value);
						
					#endregion
				
					var _x, _y, _w, _h;
				
					//draw background
					if (background.enabled) {
						if (sprite_exists(background.sprite)) {
							draw_sprite_stretched_ext(
									background.sprite,
									image.index,
									x+region.left,
									y+region.top,
									region.get_width(),
									region.get_height(),
									_background_col,
									background.alpha
							)
						}
						else {
							draw_sprite_stretched_ext(
									s9GUIPixel,
									0,
									x+region.left,
									y+region.top,
									region.get_width(),
									region.get_height(),
									_background_col,
									background.alpha
							)
						}
					}
				
					//calculate the bar's data for use with the bar and the thumb
					if (bar.enabled) || (thumb.enabled) {
						_x = __slider_bounds__.x;
						_y = __slider_bounds__.y;
						
						_w = __slider_bounds__.w;
						_h = __slider_bounds__.h;
					}
				
					//draw bar
					if (bar.enabled) {
						var _bar_w = (is_vertical)  ? _w : _w * normalized_value
						var _bar_h = (!is_vertical) ? _h : _h * normalized_value
					
						if (sprite_exists(bar.sprite)) {
							draw_sprite_stretched_ext(
									bar.sprite,
									image.index,
									_x,
									_y,
									_bar_w,
									_bar_h,
									_bar_col,
									bar.alpha
							);
						}
						else {
							draw_sprite_stretched_ext(
									s9GUIPixel,
									0,
									_x,
									_y,
									_bar_w,
									_bar_h,
									_bar_col,
									bar.alpha
							);
						}
					}
				
					//draw thumb
					if(thumb.enabled) {
					
					
						if (sprite_exists(thumb.sprite)) {
							var _min_x = __slider_bounds__.min_x;
							var _min_y = __slider_bounds__.min_y;
							
							var _max_x = __slider_bounds__.max_x;
							var _max_y = __slider_bounds__.max_y;
							
							var _thumb_x = (is_vertical)  ? _x + _w*0.5 : lerp(_min_x, _max_x, normalized_value);
							var _thumb_y = (!is_vertical) ? _y + _h*0.5 : lerp(_min_y, _max_y, normalized_value);
							
							draw_sprite_ext(
									thumb.sprite,
									image.index,
									_thumb_x,
									_thumb_y,
									thumb.xscale,
									thumb.yscale,
									0,
									_thumb_col,
									thumb.alpha
							);
						}
						else {
							var _thumb_w = (is_vertical)  ? _w : _w * 0.25;
							var _thumb_h = (!is_vertical) ? _h : _h * 0.25;
						
							var _min_x = (!thumb.clamped) ? _x : _x + _thumb_w * 0.5;
							var _min_y = (!thumb.clamped) ? _y : _y + _thumb_h * 0.5;
						
							var _max_x = (!thumb.clamped) ? _x + _w  : _x + _w - _thumb_w * 0.5;
							var _max_y = (!thumb.clamped) ? _y + _h  : _y + _h - _thumb_h * 0.5;
						
							var _thumb_x = (is_vertical)  ? _x + _w*0.5 : lerp(_min_x, _max_x, normalized_value);
							var _thumb_y = (!is_vertical) ? _y + _h*0.5 : lerp(_min_y, _max_y, normalized_value);
						
							draw_sprite_stretched_ext(
									s9GUIPixel,
									0,
									_thumb_x - _thumb_w*0.5,
									_thumb_y - _thumb_h*0.5,
									_thumb_w,
									_thumb_h,
									_thumb_col,
									thumb.alpha
							);
						}
					
					}
					
					//draw text
					if (text.enabled) {
						
						draw_set_halign(text.halign);
						draw_set_valign(text.valign);
						draw_set_font(text.font);
						
						var _str = text.to_string(value, min_value, max_value);
						
						//draw outline
						if (text.outline.thickness > 0) {
							var _i, _j;
							_i=-text.outline.thickness; repeat(1+text.outline.thickness*2) {
								_j=-text.outline.thickness; repeat(1+text.outline.thickness*2) {
									draw_text_color(
											x + text.xoff + _i,
											y + text.yoff + _j,
											_str,
											_text_outline_col,
											_text_outline_col,
											_text_outline_col,
											_text_outline_col,
											text.outline.alpha
									);
								_j++; }; //end inner repeat
							_i++; }; //end outer repeat
						}
						
						draw_text_color(
								x + text.xoff,
								y + text.yoff,
								_str,
								_text_col,
								_text_col,
								_text_col,
								_text_col, text.alpha
						);
					}
					
				}
				
			#endregion
			
		#endregion
		
	#endregion
	
	#region Private Library
		
		#region Variables
			
			__prev_value__ = value
			__click_xoff__ = 0;
			__click_yoff__ = 0;
			__slider_bounds__ = {
				min_x : 0,
				min_y : 0,
				max_x : 0,
				max_y : 0
			};
			
		#endregion
		
		#region Functions
			
			static __set_value__ = function(_value) {//log(["__set_value__", __set_value__])
				__prev_value__ = value;
				
				value = clamp(_value, min_value, max_value);
				
				if (round_value) {
					value = floor(value + 0.5);
				}
				normalized_value = (value-min_value) / (max_value-min_value);
				
				__trigger_event__(self.events.value_input, self.value);
			}
			
			static __set_normalized_value__ = function(_value) {//log(["__set_normalized_value__", __set_normalized_value__])
				__prev_value__ = value;
				
				normalized_value = clamp(_value, 0, 1);
				
				value = lerp(min_value, max_value, normalized_value)
				
				if (round_value) {
					value = floor(value + 0.5);
				}
				normalized_value = (value-min_value) / (max_value-min_value);
				
				__trigger_event__(self.events.value_input, self.value);
			}
			
			static __find_slider_bounds__ = function() {//log(["__find_slider_bounds__", __find_slider_bounds__])
				var _x, _y, _w, _h;
				//find out our bounds
				if (bar.margin == -1)
				&& (background.enabled)
				&& (sprite_exists(background.sprite))
				&& (sprite_get_nineslice(background.sprite).enabled) {
					var _slice = sprite_get_nineslice(background.sprite);
					_x = x + _slice.left;
					_y = y + _slice.top;
					_w = region.get_width()  - _slice.right - _slice.left;
					_h = region.get_height() - _slice.bottom - _slice.top;
				}
				else {
					_x = x + region.left + bar.margin;
					_y = y + region.top  + bar.margin;
					_w = region.get_width() - bar.margin - bar.margin;
					_h = region.get_height() - bar.margin - bar.margin;
				}
				
				__slider_bounds__.x = _x;
				__slider_bounds__.y = _y;
				
				__slider_bounds__.w = _w;
				__slider_bounds__.h = _h;
				
				__slider_bounds__.min_x = (!thumb.clamped || !thumb.enabled) ? _x : _x + sprite_get_xoffset(thumb.sprite) * thumb.xscale;
				__slider_bounds__.min_y = (!thumb.clamped || !thumb.enabled) ? _y : _y + sprite_get_yoffset(thumb.sprite) * thumb.yscale;
				
				__slider_bounds__.max_x = (!thumb.clamped || !thumb.enabled) ? _x + _w  : _x + _w - (sprite_get_width(thumb.sprite)  - sprite_get_xoffset(thumb.sprite)) * thumb.xscale;
				__slider_bounds__.max_y = (!thumb.clamped || !thumb.enabled) ? _y + _h  : _y + _h - (sprite_get_height(thumb.sprite) - sprite_get_yoffset(thumb.sprite)) * thumb.yscale;
				
			}
			
			#region Private Event Hooks
				
				__add_event_listener_priv__(self.events.value_input, function() {
					if (value != __prev_value__) {
						__trigger_event__(self.events.value_changed, self.value);
						
						if (value > __prev_value__) __trigger_event__(self.events.value_incremented, self.value);
						if (value < __prev_value__) __trigger_event__(self.events.value_decremented, self.value);
					}
				});
				
				
			#endregion
			
			#region GML Events
				
				static __step__ = function(_input) {//log(["__step__", __step__])
				
					step(_input);
				
					//early out if scrollbar is too small
					if (region.get_width() <= 0)
					|| (region.get_height() <= 0) {
						return
					}
					
					//apply smoothing from target value
					if (target_value != value) {
						if ( abs(target_value - value) < 0.0025 ) {
						   __set_value__(target_value);
						}
						else {
							 __set_value__(value + (target_value - value) * 0.175);
						}
					}
					
					//apply the tracker
					if (!is_undefined(tracker_func)) {
						var _tracked_val = tracker_func();
						//safety check
						if (GUI_GLOBAL_DEBUG) {
							if (!is_real(_tracked_val)) {
								show_error("The tracked value returned from the tracker function is not a valid {Real} variable.\nWhen using \"set_tracker\", the applied function must return a {Real}", true);
							}
						}
						//apply new value
						if (_tracked_val != value) {
							set_value(_tracked_val);
						}
					}
					
					var _input_captured = _input.consumed
					
					//capture input if we still have focus
					if (__is_on_focus__)
					&& (is_enabled) {
						capture_input();
					}
					
					//early out if we're disabled
					if (!is_enabled)
					|| (!input_enabled) {
						__reset_focus__();
						if (!input_enabled) {
							image.index = GUI_IMAGE_ENABLED;
						}
						else { //(!is_enabled)
							image.index = GUI_IMAGE_DISABLED;
						}
						return;
					}
					
					//define a function which will be reused in many places
					var _apply_value = function() {
						
						var _xoff = 0;
						var _yoff = 0;
						if (thumb_only_input) {
							_xoff = __click_xoff__;
							_yoff = __click_yoff__;
						}
						
						
						var _min_x = __slider_bounds__.min_x;
						var _min_y = __slider_bounds__.min_y;
						
						var _max_x = __slider_bounds__.max_x;
						var _max_y = __slider_bounds__.max_y;
						
						var _norm_val = (!is_vertical) ? (device_mouse_x_to_gui(0) - _xoff - _min_x) / (_max_x-_min_x) : (device_mouse_y_to_gui(0) - _yoff - _min_y) / (_max_y-_min_y);
						_norm_val = clamp(_norm_val, 0, 1);
						
						set_normalized_value(_norm_val);
					}
					
					//run the internal step
					if ((!_input_captured) && (mouse_on_comp())) {
						
						capture_input();
					
						//trigger the event for mouse over
						__trigger_event__(self.events.mouse_over);
						
						image.index = GUI_IMAGE_HOVER;
						
						//mouse button checks
						if (mouse_check_button_pressed(mb_left)) {
							__is_on_focus__ = true;
							image.index = GUI_IMAGE_CLICKED;
							
							if (thumb_only_input) {
								__find_slider_bounds__();
							
								var _orig_x = lerp(
										__slider_bounds__.min_x,
										__slider_bounds__.max_x,
										normalized_value
								);
								var _orig_y = lerp(
										__slider_bounds__.min_y,
										__slider_bounds__.max_y,
										normalized_value
								);
							
							
								__click_xoff__ = device_mouse_x_to_gui(0) - _orig_x;
								__click_yoff__ = device_mouse_y_to_gui(0) - _orig_y;
							}
							
							_apply_value();
							__trigger_event__(self.events.pressed, self.value);
						}
						else if (__is_on_focus__) && (mouse_check_button(mb_left)) {
							image.index = GUI_IMAGE_CLICKED;
							_apply_value();
							__trigger_event__(self.events.held, self.value);
						}
						else if (__is_on_focus__) && (mouse_check_button_released(mb_left)) {
							__reset_focus__();
							image.index = GUI_IMAGE_HOVER;
							_apply_value();
							__trigger_event__(self.events.released, self.value);
						}
					
					}
					else {
						if (__is_on_focus__) {
							_apply_value();
							image.index = GUI_IMAGE_CLICKED;
							
							if (mouse_check_button_released(mb_left)) {
								__reset_focus__();
								image.index = GUI_IMAGE_ENABLED;
								__trigger_event__(self.events.released, self.value);
							}
							else {
								__trigger_event__(self.events.held, self.value);
							}
						}
						else {
							image.index = GUI_IMAGE_ENABLED;
						}
					}
				
				}
				
			#endregion
			
		#endregion
		
	#endregion
	
	static draw_debug = function(_input) {//log(["draw_debug", draw_debug])
		draw_set_color(c_aqua)
		draw_text(x,y, ""
		+ "\n" + "normalized_value = "+string(normalized_value)
		+ "\n" + "value = "+string(value)
		+ "\n" + "min_value = "+string(min_value)
		+ "\n" + "max_value = "+string(max_value)
		+ "\n" + "normalized_value = "+string(normalized_value)
		);
		
	}
	
}
