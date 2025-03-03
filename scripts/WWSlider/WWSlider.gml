#region jsDoc
/// @func    WWSlider()
/// @desc    Creates a slider.
/// @param   {Real} x : The x possition of the component on screen.
/// @param   {Real} y : The y possition of the component on screen.
/// @returns {Struct.WWSlider}
#endregion
function WWSlider() : WWSliderHorz() constructor {}
#region jsDoc
/// @func    WWSliderHorz()
/// @desc    Creates a slider.
/// @param   {Real} x : The x possition of the component on screen.
/// @param   {Real} y : The y possition of the component on screen.
/// @returns {Struct.WWSliderHorz}
#endregion
function WWSliderHorz() : WWSliderBase() constructor {
	debug_name = "WWSliderHorz";
	
	on_interact(function(_input) {
		if (!input_enabled) return;
		
		var _norm_val;
        if (is_inverted) {
            _norm_val = (x + width - device_mouse_x_to_gui(0)) / width;
        } else {
			_norm_val = (device_mouse_x_to_gui(0) - x) / width;
		}
		_norm_val = clamp(_norm_val, 0, 1);
				
		set_normalized_value(_norm_val);
    });
	on_pre_draw(function(_input) {
		var _bar_width = width * normalized_value;
		if (is_inverted) {
            bar.set_size(width - _bar_width, 0, width, height);
        } else {
			bar.set_size(_bar_width, height);
		}
    });
	
}
#region jsDoc
/// @func    WWSliderVert()
/// @desc    Creates a slider.
/// @param   {Real} x : The x possition of the component on screen.
/// @param   {Real} y : The y possition of the component on screen.
/// @returns {Struct.WWSliderVert}
#endregion
function WWSliderVert() : WWSliderBase() constructor {
	debug_name = "WWSliderVert";
	
	on_interact(function(_input) {
		if (!input_enabled) return;
		
        var _norm_val;
		if (is_inverted) {
            _norm_val = (device_mouse_y_to_gui(0) - y) / height;
        } else {
            _norm_val = (y + height - device_mouse_y_to_gui(0)) / height;
        }
		
		_norm_val = clamp(_norm_val, 0, 1);
				
		set_normalized_value(_norm_val);
    });
	on_pre_draw(function(_input) {
		var _bar_height = height * normalized_value;
		if (is_inverted) {
            bar.set_size(width, _bar_height);
        } else {
            bar.set_size(0, height - _bar_height, width, height);
        }
    });
}

#region jsDoc
/// @func    WWSliderHorzThumb()
/// @desc    Creates a horizontal slider with a draggable thumb.
/// @param   {Real} x : The x position of the component on screen.
/// @param   {Real} y : The y position of the component on screen.
/// @returns {Struct.WWSliderHorzThumb}
#endregion
function WWSliderHorzThumb() : WWSliderHorz() constructor {
    debug_name = "WWSliderHorzThumb";

    thumb = new WWSliderThumb()
        .set_sprite(s9GUIPixel)
        .set_sprite_color(c_white)
        .set_size(16, 16);

    add(thumb);

    on_post_step(function(_input) {
		var _thumb_x;
		if (is_inverted) {
			_thumb_x = width * (1 - normalized_value) - thumb.width / 2;
		} else {
			_thumb_x = width * normalized_value - thumb.width / 2;
		}
		thumb.set_offset(_thumb_x, (height - thumb.height) / 2);
    });

    thumb.on_interact(function(_input) {
        var _norm_val;
        if (is_inverted) {
            _norm_val = (x + width - device_mouse_x_to_gui(0)) / width;
        } else {
            _norm_val = (device_mouse_x_to_gui(0) - x) / width;
        }
        _norm_val = clamp(_norm_val, 0, 1);
        set_normalized_value(_norm_val);
    });
}
#region jsDoc
/// @func    WWSliderVertThumb()
/// @desc    Creates a horizontal slider with a draggable thumb.
/// @param   {Real} x : The x position of the component on screen.
/// @param   {Real} y : The y position of the component on screen.
/// @returns {Struct.WWSliderVertThumb}
#endregion
function WWSliderVertThumb() : WWSliderVert() constructor {
    debug_name = "WWSliderVertThumb";

    thumb = new WWSliderThumb()
        .set_sprite(s9GUIPixel)
        .set_sprite_color(c_white)
        .set_size(16, 16);

    add(thumb);

    on_post_step(function(_input) {
        var _thumb_y;
        if (is_inverted) {
            _thumb_y = height * normalized_value - thumb.height / 2;
        } else {
            _thumb_y = height * (1 - normalized_value) - thumb.height / 2;
        }
        thumb.set_offset((width - thumb.width) / 2, _thumb_y);
    });

    thumb.on_interact(function(_input) {
        var _norm_val;
		if (is_inverted) {
            _norm_val = (device_mouse_y_to_gui(0) - y) / height;
        } else {
            _norm_val = (y+height - device_mouse_y_to_gui(0)) / height;
        }
		
		_norm_val = clamp(_norm_val, 0, 1);
		set_normalized_value(_norm_val);
    });
}


///@ignore
#region jsDoc
/// @func    WWSliderBase()
/// @desc    Creates a simple slider component.
/// @returns {Struct.WWSliderBase}
#endregion
function WWSliderBase() : WWButton() constructor {
    debug_name = "WWSliderBase";

    #region Public

        #region Builder Functions
		
		#region jsDoc
		/// @func    set_size()
		/// @desc    Set the reletive region for the bar sub component. Reletive to the x,y of the component.
		/// @self    WWCore
		/// @param   {real} left : The left side of the bounding box
		/// @param   {real} top : The top side of the bounding box
		/// @param   {real} right : The right side of the bounding box
		/// @param   {real} bottom : The bottom side of the bounding box
		/// @returns {Struct.WWCore}
		#endregion
		static set_size = function(_width, _height) {
			static __set_size = WWCore.set_size;
			__set_size(_width, _height)
			if (!background.__size_set__) {
				background.__set_size__(_width, _height);
			}
			return self;
		}
		#region jsDoc
		/// @func    set_value()
		/// @desc    Sets the value of the slider
		/// @self    WWSlider
		/// @param   {Real} value : The value to set the slider to.
		/// @returns {Struct.WWSlider}
		#endregion
		static set_value = function(_value) {
			__set_value__(_value);
			lerp_target = value;
			return self;
		}
		#region jsDoc
		/// @func    set_normalized_value()
		/// @desc    Sets the value of the slider using a normalized input, The input must be a value between 0 and 1. This is similar to the lerp function.
		/// @self    WWSlider
		/// @param   {Real} value : The normalized value to set the slider to.
		/// @returns {Struct.WWSlider}
		#endregion
		static set_normalized_value = function(_value) {
			__set_normalized_value__(_value);
			lerp_target = value;
			return self;
		}
		#region jsDoc
		/// @func    set_clamp_values()
		/// @desc    Sets the slider's min and max bounds.
		/// @self    WWSlider
		/// @param   {Real} min : The min value of the slider.
		/// @param   {Real} max : The max value of the slider.
		/// @returns {Struct.WWSlider}
		#endregion
		static set_clamp_values = function(_min=0, _max=10) {
			min_value = _min;
			max_value = _max;
			
			lerp_target = clamp(lerp_target, min_value, max_value);
			__set_value__(value);
				
			return self;
		}
		#region jsDoc
		/// @func    set_rounding()
		/// @desc    Sets the rounding of the slider. Good for gathering integers from sliders
		/// @self    WWSlider
		/// @param   {Bool} should_round : If the slider's value should be rounded. true = round, false = no rounding.
		/// @returns {Struct.WWSlider}
		#endregion
		static set_rounding = function(_round=false) {
				
			round_value = _round
			set_value(value);
				
			return self;
		}
		#region jsDoc
		/// @func    set_lerp_target()
		/// @desc    This function will smoothly set the slider's value to a target value.
		/// @self    WWSlider
		/// @param   {Real} lerp_target : The target value the slider should smooth towards.
		/// @returns {Struct.WWSlider}
		#endregion
		static set_lerp_target = function(_lerp_target) {
			
			lerp_target = clamp(_lerp_target, min_value, max_value);
			
			if (round_value) {
				lerp_target = floor(lerp_target + 0.5);
			}
			
			return self;
		}
		#region jsDoc
		/// @func    set_input_enabled()
		/// @desc    Sets the slider to take or reject inputs
		/// @self    WWSlider
		/// @param   {Bool} input_enabled : If thee slider is allowed to take in inputs.
		/// @returns {Struct.WWSlider}
		#endregion
		static set_input_enabled = function(_input_enabled) {
			input_enabled = _input_enabled;
				
			return self;
		}
		
		#region jsDoc
		/// @func set_inverted()
		/// @desc Flips the bar's growth direction (top-to-bottom vs bottom-to-top)
		/// @self WWSliderVert
		/// @param {Bool} _invert : If true, the slider will scale from top-to-bottom instead.
		/// @returns {Struct.WWSliderVert}
		#endregion
		static set_inverted = function(_invert) {
			is_inverted = _invert;
			return self;
		}
		
		#region jsDoc
		/// @func    set_bar_size()
		/// @desc    Set the reletive region for the bar sub component. Reletive to the x,y of the component.
		/// @self    WWCore
		/// @param   {real} left : The left side of the bounding box
		/// @param   {real} top : The top side of the bounding box
		/// @param   {real} right : The right side of the bounding box
		/// @param   {real} bottom : The bottom side of the bounding box
		/// @returns {Struct.WWCore}
		#endregion
		static set_bar_size = function(_left, _top, _right, _bottom) {
			bar.set_size(_left, _top, _right, _bottom)
			return self;
		}
		#region jsDoc
		/// @func    set_background_size()
		/// @desc    Set the reletive region for the background. Reletive to the x,y of the component.
		/// @self    WWCore
		/// @param   {real} left : The left side of the bounding box
		/// @param   {real} top : The top side of the bounding box
		/// @param   {real} right : The right side of the bounding box
		/// @param   {real} bottom : The bottom side of the bounding box
		/// @returns {Struct.WWCore}
		#endregion
		static set_background_size = function(_left, _top, _right, _bottom) {
			background.set_size(_left, _top, _right, _bottom)
			return self;
		}
		
		#endregion
        
        #region Events
			
			self.events.value_input       = variable_get_hash("value_input"); //if a value was input in any way, this will trigger every frame the slider is interacted wtih
			self.events.value_changed     = variable_get_hash("value_changed"); //if a value was changed in any way, this will trigger only when the previous frame's value does not equal the current frames value
			self.events.value_incremented = variable_get_hash("value_incremented"); //if a value was incremented, this will trigger only when the previous frame's value is less than the current frames value
			self.events.value_decremented = variable_get_hash("value_decremented"); //if a value was decremented, this will trigger only when the previous frame's value greater than the current frames value
			
			on_post_step(function(_input) {
				//apply smoothing from target value
				if (lerp_target != value) {
					if ( abs(lerp_target - value) < 0.0025 ) {
						__set_value__(lerp_target);
						trigger_event(self.events.value_input, self.value);
					}
					else {
						__set_value__(value + (lerp_target - value) * 0.175);
						trigger_event(self.events.value_input, self.value);
					}
				}
			})
			
        #endregion
        
        #region Variables
			
			min_value = 0;
			max_value = 1;
			value = 0.5;
			lerp_target = value;
			normalized_value = (0.5-min_value) / (max_value-min_value);
			round_value = false;
			input_enabled = true;
			is_inverted = false;
			
			//dont render
			set_sprite(undefined)
			visible = false;
			
			background = new WWSliderBackgroud()
				.set_sprite(s9GUIPixel)
				.set_sprite_color(c_grey)
			bar = new WWSliderBar()
				.set_sprite(s9GUIPixel)
				.set_sprite_color(c_orange)
			
			add([background, bar]);
        #endregion

        #region Functions
        
        #region jsDoc
		/// @func    get_value()
		/// @desc    Returns the value of the component
		/// @self    WWSlider
		/// @returns {Real}
		#endregion
		static get_value = function() {
			return value;
		}
		
        #endregion

    #endregion
	
	#region Private
		
		#region Variables
			
			__prev_value__ = value;
			
		#endregion
		
		#region Functions
			
			static __set_value__ = function(_value) {
				value = clamp(_value, min_value, max_value);
				
				if (round_value) {
					value = floor(value + 0.5);
				}
				normalized_value = (value-min_value) / (max_value-min_value);
				
				// trigger events
				trigger_event(self.events.value_input, self.value);
				if (__prev_value__ != value) {
					trigger_event(self.events.value_changed, self.value);
					if (__prev_value__ < value) {
						trigger_event(self.events.value_incremented, self.value);
					}
					else {
						trigger_event(self.events.value_decremented, self.value);
					}
				}
				
				__prev_value__ = value;
			}
			
			static __set_normalized_value__ = function(_value) {
				__prev_value__ = value;
				
				normalized_value = clamp(_value, 0, 1);
				
				value = lerp(min_value, max_value, normalized_value)
				if (round_value) {
					value = floor(value + 0.5);
				}
				normalized_value = (value-min_value) / (max_value-min_value);
				
				// trigger events
				trigger_event(self.events.value_input, self.value);
				if (__prev_value__ != value) {
					trigger_event(self.events.value_changed, self.value);
					if (__prev_value__ < value) {
						trigger_event(self.events.value_incremented, self.value);
					}
					else {
						trigger_event(self.events.value_decremented, self.value);
					}
				}
				
				__prev_value__ = value;
			}
			
		#endregion
		
	#endregion
}
#region jsDoc
/// @func    WWSliderBackgroud()
/// @desc    The bar used inside of sliders
/// @returns {Struct.WWSliderBackgroud}
#endregion
function WWSliderBackgroud() : WWSprite() constructor {
	debug_name = "WWSliderBackgroud";
}
#region jsDoc
/// @func    WWSliderBar()
/// @desc    The bar used inside of sliders
/// @returns {Struct.WWSliderBar}
#endregion
function WWSliderBar() : WWSprite() constructor {
	debug_name = "WWSliderBar";
}
#region jsDoc
/// @func    WWSliderThumb()
/// @desc    The bar used inside of sliders
/// @returns {Struct.WWSliderThumb}
#endregion
function WWSliderThumb() : WWButton() constructor {
	debug_name = "WWSliderThumb";
}

