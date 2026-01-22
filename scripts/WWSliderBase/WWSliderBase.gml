///@ignore
#region jsDoc
/// @func    WWSliderBase()
/// @desc    Creates a simple slider component.
/// @returns {Struct.WWSliderBase}
#endregion
function WWSliderBase() : WWButtonSprite() constructor {
    debug_name = "WWSliderBase";

    #region Public

        #region Builder Functions
		
		#region jsDoc
		/// @func    set_size()
		/// @desc    Sets the slider size. Also sizes the background if it has not been manually sized.
		/// @self    WWSliderBase
		/// @param   {Real} width : Width of the slider.
		/// @param   {Real} height : Height of the slider.
		/// @returns {Struct.WWSliderBase}
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
		/// @desc    Sets the slider value (clamped to min/max).
		/// @self    WWSliderBase
		/// @param   {Real} value : Value to set.
		/// @returns {Struct.WWSliderBase}
		#endregion
		static set_value = function(_value) {
			__set_value__(_value);
			lerp_target = value;
			//trigger_event(self.events.value_input, self.value);
			return self;
		}
		#region jsDoc
		/// @func    set_normalized_value()
		/// @desc    Sets the slider value using a normalized 0..1 input.
		/// @self    WWSliderBase
		/// @param   {Real} value : Normalized value (0..1).
		/// @returns {Struct.WWSliderBase}
		#endregion
		static set_normalized_value = function(_value) {
			__set_normalized_value__(_value);
			lerp_target = value;
			//trigger_event(self.events.value_input, self.value);
			return self;
		}
		#region jsDoc
		/// @func    set_clamp_values()
		/// @desc    Sets the slider min and max values.
		/// @self    WWSliderBase
		/// @param   {Real} min : Minimum value.
		/// @param   {Real} max : Maximum value.
		/// @returns {Struct.WWSliderBase}
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
		/// @desc    Enables or disables rounding (useful for integer sliders).
		/// @self    WWSliderBase
		/// @param   {Bool} _round : True to round, false to keep fractional values.
		/// @returns {Struct.WWSliderBase}
		#endregion
		static set_rounding = function(_round=false) {
				
			round_value = _round
			set_value(value);
				
			return self;
		}
		#region jsDoc
		/// @func    set_lerp_target()
		/// @desc    Sets the smoothing target value (the slider eases toward this value).
		/// @self    WWSliderBase
		/// @param   {Real} _lerp_target : Target value to ease toward.
		/// @returns {Struct.WWSliderBase}
		#endregion
		static set_lerp_target = function(_lerp_target) {
			
			lerp_target = clamp(_lerp_target, min_value, max_value);
			
			if (round_value) {
				lerp_target = floor(lerp_target + 0.5);
			}
			
			return self;
		}
		
		#region jsDoc
		/// @func    set_inverted()
		/// @desc    Flips the bar growth direction.
		/// @self    WWSliderBase
		/// @param   {Bool} _invert : True to invert direction.
		/// @returns {Struct.WWSliderBase}
		#endregion
		static set_inverted = function(_invert) {
			is_inverted = _invert;
			return self;
		}
		
		#region jsDoc
		/// @func    set_bar_size()
		/// @desc    Sets the bar component region relative to the slider.
		/// @self    WWSliderBase
		/// @param   {Real} _left : Left.
		/// @param   {Real} _top : Top.
		/// @param   {Real} _right : Right.
		/// @param   {Real} _bottom : Bottom.
		/// @returns {Struct.WWSliderBase}
		#endregion
		static set_bar_size = function(_left, _top, _right, _bottom) {
			bar.set_size(_left, _top, _right, _bottom)
			return self;
		}
		#region jsDoc
		/// @func    set_background_size()
		/// @desc    Sets the background component region relative to the slider.
		/// @self    WWSliderBase
		/// @param   {Real} _left : Left.
		/// @param   {Real} _top : Top.
		/// @param   {Real} _right : Right.
		/// @param   {Real} _bottom : Bottom.
		/// @returns {Struct.WWSliderBase}
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
			is_inverted = false;
			
			//dont render
			set_sprite(undefined)
			visible = false;
			
			background = new WWSliderBackgroud()
				.set_sprite(spr_ww_pixel)
				.set_sprite_color(c_grey)
			bar = new WWSliderBar()
				.set_sprite(spr_ww_pixel)
				.set_sprite_color(c_orange)
			
			add([background, bar]);
        #endregion

        #region Functions
        
		#region jsDoc
		/// @func    get_size()
		/// @desc    Returns the slider size.
		/// @self    WWSliderBase
		/// @returns {Struct} size_struct_with_width_height
		#endregion
		static get_size = function() {
			static _core_get_size = WWCore.get_size;
			return _core_get_size();
		};
		#region jsDoc
		/// @func    get_normalized_value()
		/// @desc    Returns the current normalized value (0..1).
		/// @self    WWSliderBase
		/// @returns {Real} normalized_value
		#endregion
		static get_normalized_value = function() {
			return normalized_value;
		};
		#region jsDoc
		/// @func    get_clamp_values()
		/// @desc    Returns the slider min and max values.
		/// @self    WWSliderBase
		/// @returns {Struct} clamp_struct_with_min_max
		#endregion
		static get_clamp_values = function() {
			return { min: min_value, max: max_value };
		};
		#region jsDoc
		/// @func    get_rounding()
		/// @desc    Returns whether rounding is enabled.
		/// @self    WWSliderBase
		/// @returns {Bool} is_enabled
		#endregion
		static get_rounding = function() {
			return round_value;
		};
		#region jsDoc
		/// @func    get_lerp_target()
		/// @desc    Returns the current smoothing target value.
		/// @self    WWSliderBase
		/// @returns {Real} lerp_target_value
		#endregion
		static get_lerp_target = function() {
			return lerp_target;
		};
		#region jsDoc
		/// @func    get_inverted()
		/// @desc    Returns whether the slider direction is inverted.
		/// @self    WWSliderBase
		/// @returns {Bool} is_inverted
		#endregion
		static get_inverted = function() {
			return is_inverted;
		};
		#region jsDoc
		/// @func    get_bar_size()
		/// @desc    Returns the bar component region.
		/// @self    WWSliderBase
		/// @returns {Struct} rect_struct_with_left_top_right_bottom
		#endregion
		static get_bar_size = function() {
			return {
				left: bar.__x__,
				top: bar.__y__,
				right: bar.__x__ + bar.width,
				bottom: bar.__y__ + bar.height,
			};
		};
		#region jsDoc
		/// @func    get_background_size()
		/// @desc    Returns the background component region.
		/// @self    WWSliderBase
		/// @returns {Struct} rect_struct_with_left_top_right_bottom
		#endregion
		static get_background_size = function() {
			return {
				left: background.__x__,
				top: background.__y__,
				right: background.__x__ + background.width,
				bottom: background.__y__ + background.height,
			};
		};
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
function WWSliderThumb() : WWButtonSprite() constructor {
	debug_name = "WWSliderThumb";
}

