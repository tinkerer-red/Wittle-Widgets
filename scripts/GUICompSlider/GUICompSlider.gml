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
	
	#region Public
		
		#region Events
			
			
			
		#endregion
		
	#endregion
	
	#region Private Library
		
		#region Variables
			
			
		#endregion
		
		#region Functions
			
			static __apply_value = function() {
				
				var _norm_val = (device_mouse_x_to_gui(0) - x+region.left) / region.get_width()
				_norm_val = clamp(_norm_val, 0, 1);
						
				set_normalized_value(_norm_val);
				
			}
			
		#endregion
		
	#endregion
	
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
	
	#region Public
		
		#region Events
			
				
		#endregion
		
	#endregion
	
	#region Private Library
		
		#region Variables
			
			
		#endregion
		
		#region Functions
			
			static __apply_value = function() {
				
				var _norm_val = (y+region.bottom - device_mouse_y_to_gui(0)) / region.get_height();
				_norm_val = clamp(_norm_val, 0, 1);
						
				set_normalized_value(_norm_val);
			}
			
		#endregion
		
	#endregion
	
}



#region jsDoc
/// @func    WWSliderWithThumbBase()
/// @desc    Creates a horizontal slider with an interactive thumb button.
/// @returns {Struct.WWSliderWithThumbBase}
#endregion
function WWSliderWithThumbBase() : WWCore() constructor {
	debug_name = "WWSliderHorzWithThumb";
	
	#region Public

		// Create the thumb as a button
		thumb = new WWButton()
			.set_sprite(s9SliderThumb)
			.set_alignment(fa_center, fa_middle)
		
		add(thumb);
		
		#region Events
			
			// Update the thumb position dynamically
			on_post_step(function(_input) {
				var _x = x + region.left + (region.get_width() * normalized_value);
				var _y = y + region.top + (region.get_height() * 0.5);
				thumb.set_position(_x, _y);
			});

		#endregion

	#endregion
}


#region jsDoc
/// @func    WWSliderWithThumbBase()
/// @desc    This is a template for building a new component from scratch, this should never be called by the user
/// @returns {Struct.WWSliderWithThumbBase}
#endregion
function WWSliderHorzWithThumb() : WWSliderHorz() constructor {
	debug_name = "WWSliderHorzWithThumb";
	
	#region Public
		
		#region Builder Functions
			
			#region jsDoc
			/// @func    set_thumb_only_input()
			/// @desc    Sets the slider to only accept inputs from the thumb. Normally used for when you which to have a scroll bar or lever style input.
			/// @self    WWSlider
			/// @param   {Bool} thumb_only_input : If the only available way to change the slider's value is with the thumb. true = thumb only, false = normal slider functionality.
			/// @returns {Struct.WWSlider}
			#endregion
			static set_thumb_only_input = function(_thumb_only_input) {
				input_enabled = !_thumb_only_input;
				
				return self;
			}
			
			#region Thumb
				
				#region jsDoc
				/// @func    set_thumb_enabled()
				/// @desc    Sets the thumb to be enabled
				/// @self    WWSlider
				/// @param   {Real} enabled : If the thumb is enabled
				/// @returns {Struct.WWSlider}
				#endregion
				static set_thumb_enabled = function(_enabled=true) {
					thumb.set_enabled(_enabled);
					
					return self;
				}
				#region jsDoc
				/// @func    set_thumb_sprite()
				/// @desc    Sets the thumb sprite to be used in the slider component.
				/// @self    WWSlider
				/// @param   {Asset.GMSprite} sprite : The sprite to use for the thumb.
				/// @returns {Struct.WWSlider}
				#endregion
				static set_thumb_sprite = function(_sprite=-1) {
					thumb.set_sprite(_sprite)
					
					return self;
				}
				#region jsDoc
				/// @func    set_thumb_alpha()
				/// @desc    Sets the alpha value of the thumb sprite in the slider component.
				/// @self    WWSlider
				/// @param   {Real} alpha : The alpha value to set for the thumb.
				/// @returns {Struct.WWSlider}
				#endregion
				static set_thumb_alpha = function(_alpha=1) {
					thumb.set_alpha(_alpha);
					
					return self;
				}
				#region jsDoc
				/// @func    set_thumb_scales()
				/// @desc    Sets the scales of the thumb sprite in the slider component.
				/// @self    WWSlider
				/// @param   {Real} width : The width to set for the thumb.
				/// @param   {Real} height : The height to set for the thumb.
				/// @returns {Struct.WWSlider}
				#endregion
				static set_thumb_size = function(_width=0, _height=0) {
					thumb.set_size(0, 0, _width, _height);
					
					return self;
				}
				#region jsDoc
				/// @func    set_thumb_clamped_in_bounds()
				/// @desc    Sets whether the thumb sprite is clamped within the bounds of the slider component or not. This is usually only used if you are attempting to create a scroll bar
				/// @self    WWSlider
				/// @param   {Real} clamped : If the thumb is clamped in bounds. true = clamped, false = not clamped.
				/// @returns {Struct.WWSlider}
				#endregion
				static set_thumb_clamped_in_bounds = function(_clamped=true) {
					thumb.clamped = _clamped;
					
					return self;
				}
				
			#endregion
			
		#endregion
		
		#region Events
			
			
			
		#endregion
		
		#region Variables
			
			
		#endregion
	
		#region Functions
			
		#endregion
		
	#endregion
	
	#region Private
		
		#region Variables
			
			__prev_value__ = value
			
		#endregion
		
		#region Functions
			
			add_event_listener(self.events.value_input, function() {
				if (value != __prev_value__) {
					trigger_event(self.events.value_changed, self.value);
						
					if (value > __prev_value__) trigger_event(self.events.value_incremented, self.value);
					if (value < __prev_value__) trigger_event(self.events.value_decremented, self.value);
				}
			});
			
		#endregion
		
	#endregion
	
}
#region jsDoc
/// @func    WWSliderVertWithThumb()
/// @desc    Creates a horizontal slider with an interactive thumb button.
/// @returns {Struct.WWSliderVertWithThumb}
#endregion
function WWSliderVertWithThumb() : WWSliderVert() constructor {
	debug_name = "WWSliderHorzWithThumb";
	
	#region Public

		// Create the thumb as a button
		thumb = new WWButton()
			.set_sprite(s9SliderThumb)
			.set_alignment(fa_center, fa_middle)
		
		add(thumb);
		
		#region Events
			
			// Update the thumb position dynamically
			on_post_step(function(_input) {
				var _x = x + region.left + (region.get_width() * normalized_value);
				var _y = y + region.top + (region.get_height() * 0.5);
				thumb.set_position(_x, _y);
			});

		#endregion

	#endregion
}





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
		/// @desc    Set the reletive region for all click selections. Reletive to the x,y of the component.
		/// @self    WWCore
		/// @param   {real} left : The left side of the bounding box
		/// @param   {real} top : The top side of the bounding box
		/// @param   {real} right : The right side of the bounding box
		/// @param   {real} bottom : The bottom side of the bounding box
		/// @returns {Struct.WWCore}
		#endregion
		static set_size = function(_left, _top, _right, _bottom) {
			static __set_size = WWCore.set_size;
			__set_size(_left, _top, _right, _bottom);
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
		
		#endregion
        
        #region Events
			
			self.events.value_input       = variable_get_hash("value_input"); //if a value was input in any way, this will trigger every frame the slider is interacted wtih
			self.events.value_changed     = variable_get_hash("value_changed"); //if a value was changed in any way, this will trigger only when the previous frame's value does not equal the current frames value
			self.events.value_incremented = variable_get_hash("value_incremented"); //if a value was incremented, this will trigger only when the previous frame's value is less than the current frames value
			self.events.value_decremented = variable_get_hash("value_decremented"); //if a value was decremented, this will trigger only when the previous frame's value greater than the current frames value
			
			on_interact(function(_input){
				__apply_value();
			})
			
        #endregion
        
        #region Variables
			
			min_value = 0;
			max_value = 1;
			value = 0.5;
			lerp_target = value;
			normalized_value = (0.5-min_value) / (max_value-min_value);
			round_value = false;
			input_enabled = false;
			
			set_sprite(undefined)
			set_visible
			background = new WWSliderBackgroud();
			bar = new WWSliderBar();
			
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
		
		#region Functions
			
			static __set_value__ = function(_value) {
				__prev_value__ = value;
				
				value = clamp(_value, min_value, max_value);
				
				if (round_value) {
					value = floor(value + 0.5);
				}
				normalized_value = (value-min_value) / (max_value-min_value);
				
			}
			
			static __set_normalized_value__ = function(_value) {
				__prev_value__ = value;
				
				normalized_value = clamp(_value, 0, 1);
				
				value = lerp(min_value, max_value, normalized_value)
				if (round_value) {
					value = floor(value + 0.5);
				}
				normalized_value = (value-min_value) / (max_value-min_value);
				
				trigger_event(self.events.value_input, self.value);
			}
			
		    static __calculate_color__ = function(_struct) {
		        switch (image_index) {
		            case GUI_IMAGE_HOVER:    return (!_struct.enabled)      ? 0 : __color_blend__(_struct.min_color.hover,    _struct.max_color.hover,    normalized_value);
		            case GUI_IMAGE_PRESSED:  return (!_struct.enabled)      ? 0 : __color_blend__(_struct.min_color.clicked,  _struct.max_color.clicked,  normalized_value);
		            case GUI_IMAGE_DISABLED: return (!_struct.enabled)      ? 0 : __color_blend__(_struct.min_color.disabled, _struct.max_color.disabled, normalized_value);
		            default:                 return (!_struct.enabled)      ? 0 : __color_blend__(_struct.min_color.idle,     _struct.max_color.idle,     normalized_value);;
		        }
		    },
			
			static __color_blend__ = function(_c1, _c2, _amt) {
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
			
		#endregion
		
	#endregion
}

///@ignore
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
