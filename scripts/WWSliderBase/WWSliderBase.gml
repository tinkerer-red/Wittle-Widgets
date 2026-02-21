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
            /// @desc    Sets the slider size.
            /// @self    WWSliderBase
            /// @param   {Real} width : Width of the slider.
            /// @param   {Real} height : Height of the slider.
            /// @returns {Struct.WWSliderBase}
            #endregion
            static set_size = function(_width, _height) {
                static __set_size = WWCore.set_size;
                __set_size(_width, _height);

                if (!__bg_rect_user_set__) {
                    __bg_rect__.left = 0;
                    __bg_rect__.top = 0;
                    __bg_rect__.right = width;
                    __bg_rect__.bottom = height;
                }
                if (!__bar_rect_user_set__) {
                    __bar_rect__.left = 0;
                    __bar_rect__.top = 0;
                    __bar_rect__.right = width;
                    __bar_rect__.bottom = height;
                }
                return self;
            };

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
                return self;
            };

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
                return self;
            };

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
            };

            #region jsDoc
            /// @func    set_rounding()
            /// @desc    Enables or disables rounding (useful for integer sliders).
            /// @self    WWSliderBase
            /// @param   {Bool} round : True to round, false to keep fractional values.
            /// @returns {Struct.WWSliderBase}
            #endregion
            static set_rounding = function(_round=false) {
                round_value = _round;
                set_value(value);
                return self;
            };

            #region jsDoc
            /// @func    set_lerp_target()
            /// @desc    Sets the smoothing target value (the slider eases toward this value).
            /// @self    WWSliderBase
            /// @param   {Real} lerp_target : Target value to ease toward.
            /// @returns {Struct.WWSliderBase}
            #endregion
            static set_lerp_target = function(_lerp_target) {
                lerp_target = clamp(_lerp_target, min_value, max_value);
                if (round_value) {
                    lerp_target = floor(lerp_target + 0.5);
                }
                return self;
            };

            #region jsDoc
            /// @func    set_inverted()
            /// @desc    Flips the bar growth direction.
            /// @self    WWSliderBase
            /// @param   {Bool} invert : True to invert direction.
            /// @returns {Struct.WWSliderBase}
            #endregion
            static set_inverted = function(_invert) {
                is_inverted = _invert;
                return self;
            };

            #region jsDoc
            /// @func    set_bar_size()
            /// @desc    Sets the fill bar region relative to the slider.
            ///          Supports set_bar_size(width, height) and set_bar_size(left, top, right, bottom).
            /// @self    WWSliderBase
            /// @returns {Struct.WWSliderBase}
            #endregion
            static set_bar_size = function(_left, _top, _right=undefined, _bottom=undefined) {
                if (is_undefined(_right) || is_undefined(_bottom)) {
                    __bar_rect__.left = 0;
                    __bar_rect__.top = 0;
                    __bar_rect__.right = _left;
                    __bar_rect__.bottom = _top;
                }
                else {
                    __bar_rect__.left = _left;
                    __bar_rect__.top = _top;
                    __bar_rect__.right = _right;
                    __bar_rect__.bottom = _bottom;
                }
                __bar_rect_user_set__ = true;
                return self;
            };

            #region jsDoc
            /// @func    set_background_size()
            /// @desc    Sets the background region relative to the slider.
            ///          Supports set_background_size(width, height) and set_background_size(left, top, right, bottom).
            /// @self    WWSliderBase
            /// @returns {Struct.WWSliderBase}
            #endregion
            static set_background_size = function(_left, _top, _right=undefined, _bottom=undefined) {
                if (is_undefined(_right) || is_undefined(_bottom)) {
                    __bg_rect__.left = 0;
                    __bg_rect__.top = 0;
                    __bg_rect__.right = _left;
                    __bg_rect__.bottom = _top;
                }
                else {
                    __bg_rect__.left = _left;
                    __bg_rect__.top = _top;
                    __bg_rect__.right = _right;
                    __bg_rect__.bottom = _bottom;
                }
                __bg_rect_user_set__ = true;
                return self;
            };

            #region jsDoc
            /// @func    set_show_track()
            /// @desc    Shows/hides the slider track (background sprite).
            /// @self    WWSliderBase
            /// @param   {Bool} enabled
            /// @returns {Struct.WWSliderBase}
            #endregion
            static set_show_track = function(_enabled=true) {
                __show_track__ = _enabled;
                set_sprite_alpha(_enabled ? undefined : 0);
                return self;
            };

            #region jsDoc
            /// @func    set_show_fill()
            /// @desc    Shows/hides the slider fill bar.
            /// @self    WWSliderBase
            /// @param   {Bool} enabled
            /// @returns {Struct.WWSliderBase}
            #endregion
            static set_show_fill = function(_enabled=true) {
                __show_fill__ = _enabled;
                return self;
            };

            #region jsDoc
            /// @func    set_show_bar()
            /// @desc    Shows/hides all bar visuals (track + fill).
            /// @self    WWSliderBase
            /// @param   {Bool} enabled
            /// @returns {Struct.WWSliderBase}
            #endregion
            static set_show_bar = function(_enabled=true) {
                set_show_track(_enabled);
                set_show_fill(_enabled);
                return self;
            };
			
			#region jsDoc
			/// @func    set_track_theme_keys()
			/// @desc    Sets theme key prefixes for the slider track (inherited button-sprite surface).
			/// @self    WWSliderBase
			/// @param   {String} sprite_main
			/// @param   {String} sprite_state_prefix
			/// @param   {String} color_prefix
			/// @param   {String} alpha_prefix
			/// @returns {Struct.WWSliderBase}
			#endregion
			static set_track_theme_keys = function(_sprite_main, _sprite_state_prefix, _color_prefix, _alpha_prefix) {
				set_theme_keys(_sprite_main, _sprite_state_prefix, _color_prefix, _alpha_prefix);
				return self;
			};
			
			#region jsDoc
			/// @func    set_fill_theme_keys()
			/// @desc    Sets theme key prefixes used for slider fill (bar) rendering.
			/// @self    WWSliderBase
			/// @param   {String} sprite_prefix : e.g. "slider.sprite.fill"
			/// @param   {String} color_prefix : e.g. "slider.color.fill"
			/// @param   {String} alpha_prefix : e.g. "slider.alpha.fill"
			/// @returns {Struct.WWSliderBase}
			#endregion
			static set_fill_theme_keys = function(
				_sprite_prefix = "slider.sprite.fill",
				_color_prefix = "slider.color.fill",
				_alpha_prefix = "slider.alpha.fill"
			) {
				__theme_fill_sprite_prefix__ = _sprite_prefix;
				__theme_fill_color_prefix__ = _color_prefix;
				__theme_fill_alpha_prefix__ = _alpha_prefix;
				return self;
			};
        #endregion

        #region Events
            events.value_input       = variable_get_hash("value_input");
            events.value_changed     = variable_get_hash("value_changed");
            events.value_incremented = variable_get_hash("value_incremented");
            events.value_decremented = variable_get_hash("value_decremented");

            on_post_step(function(_input) {
                if (lerp_target != value) {
                    if (abs(lerp_target - value) < 0.0025) {
                        __set_value__(lerp_target);
                        trigger_event(events.value_input, value);
                    }
                    else {
                        __set_value__(value + (lerp_target - value) * 0.175);
                        trigger_event(events.value_input, value);
                    }
                }
            });

            on_pre_draw(function(_input) {
                __draw_bar__();
            });
        #endregion

        #region Variables
            min_value = 0;
            max_value = 1;
            value = 0.5;
            lerp_target = value;
            normalized_value = 0.5;
            round_value = false;
            is_inverted = false;

            __bar_rect__ = { left: 0, top: 0, right: width, bottom: height };
            __bg_rect__ = { left: 0, top: 0, right: width, bottom: height };
            __bar_rect_user_set__ = false;
            __bg_rect_user_set__ = false;
            __show_track__ = true;
            __show_fill__ = true;

            __bar_sprite__ = undefined;
            __bar_color__ = undefined;
            __bar_alpha__ = undefined;

            __theme_sprite_key_main__ = "slider.sprite.track.main";
            __theme_sprite_key_state_prefix__ = "slider.sprite.track";
            __theme_color_prefix__ = "slider.color.track";
            __theme_alpha_prefix__ = "slider.alpha.track";
			__theme_fill_sprite_prefix__ = "slider.sprite.fill";
			__theme_fill_color_prefix__ = "slider.color.fill";
			__theme_fill_alpha_prefix__ = "slider.alpha.fill";
        #endregion

        #region Functions
            static get_size = function() {
                static _core_get_size = WWCore.get_size;
                return _core_get_size();
            };

            static get_normalized_value = function() { return normalized_value; };
            static get_clamp_values = function() { return { min: min_value, max: max_value }; };
            static get_rounding = function() { return round_value; };
            static get_lerp_target = function() { return lerp_target; };
            static get_inverted = function() { return is_inverted; };
            static get_value = function() { return value; };
            static get_show_track = function() { return __show_track__; };
            static get_show_fill = function() { return __show_fill__; };
            static get_show_bar = function() { return __show_track__ && __show_fill__; };

            static get_bar_size = function() {
                return {
                    left: __bar_rect__.left,
                    top: __bar_rect__.top,
                    right: __bar_rect__.right,
                    bottom: __bar_rect__.bottom,
                };
            };

            static get_background_size = function() {
                return {
                    left: __bg_rect__.left,
                    top: __bg_rect__.top,
                    right: __bg_rect__.right,
                    bottom: __bg_rect__.bottom,
                };
            };
        #endregion

    #endregion

    #region Private
        #region Variables
            __prev_value__ = value;
        #endregion

        #region Functions
            static __draw_bar__ = function() {
                if (!__show_fill__) return;
                var _w = __bar_rect__.right - __bar_rect__.left;
                var _h = __bar_rect__.bottom - __bar_rect__.top;
                if (_w <= 0 || _h <= 0) return;
				var _state = __theme_state_specifier__();

                var _spr = __bar_sprite__;
                if (_spr == undefined || !sprite_exists(_spr)) {
					_spr = wwThemeGetSprite(
						__theme_fill_sprite_prefix__ + "." + _state,
						__theme_fill_sprite_prefix__ + ".idle",
						__theme_fill_sprite_prefix__ + ".main",
						__theme_fill_sprite_prefix__
					);
                }
                if (_spr == undefined || !sprite_exists(_spr)) return;

                var _col = __bar_color__;
				if (_col == undefined) _col = wwThemeGetColor(
					__theme_fill_color_prefix__ + "." + _state,
					__theme_fill_color_prefix__ + ".idle",
					__theme_fill_color_prefix__ + ".main",
					__theme_fill_color_prefix__
				);
				var _alp = __bar_alpha__;
				if (_alp == undefined) _alp = wwThemeGetAlpha(
					__theme_fill_alpha_prefix__ + "." + _state,
					__theme_fill_alpha_prefix__ + ".idle",
					__theme_fill_alpha_prefix__ + ".main",
					__theme_fill_alpha_prefix__
				);

                draw_sprite_stretched_ext(
                    _spr,
                    0,
                    x + __bar_rect__.left,
                    y + __bar_rect__.top,
                    _w,
                    _h,
                    _col,
                    _alp
                );
            };

            static __set_value__ = function(_value) {
                value = clamp(_value, min_value, max_value);

                if (round_value) {
                    value = floor(value + 0.5);
                }

                var _den = (max_value - min_value);
                normalized_value = (_den == 0) ? 0 : ((value - min_value) / _den);

                if (__prev_value__ != value) {
                    trigger_event(events.value_changed, value);
                    if (__prev_value__ < value) {
                        trigger_event(events.value_incremented, value);
                    }
                    else {
                        trigger_event(events.value_decremented, value);
                    }
                }

                __prev_value__ = value;
            };

            static __set_normalized_value__ = function(_value) {
                __prev_value__ = value;

                normalized_value = clamp(_value, 0, 1);
                value = lerp(min_value, max_value, normalized_value);

                if (round_value) {
                    value = floor(value + 0.5);
                }

                var _den = (max_value - min_value);
                normalized_value = (_den == 0) ? 0 : ((value - min_value) / _den);

                if (__prev_value__ != value) {
                    trigger_event(events.value_changed, value);
                    if (__prev_value__ < value) {
                        trigger_event(events.value_incremented, value);
                    }
                    else {
                        trigger_event(events.value_decremented, value);
                    }
                }

                __prev_value__ = value;
            };
        #endregion
    #endregion
}
