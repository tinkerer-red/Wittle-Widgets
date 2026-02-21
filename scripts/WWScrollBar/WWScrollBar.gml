#region jsDoc
/// @func    WWScrollbar()
/// @desc    Base class for horizontal and vertical scrollbars.
/// @returns {Struct.WWScrollbar}
#endregion
function WWScrollbar() : WWSliderBase() constructor {
    debug_name = "WWScrollbar";

	// Scrollbar surface (track/tray) should resolve from scrollbar keyspace, not slider/button.
	set_track_theme_keys(
		"scrollbar.sprite.tray.main",
		"scrollbar.sprite.tray",
		"scrollbar.color.tray",
		"scrollbar.alpha.tray"
	);
	
    #region Public

        #region Builder Functions
            #region jsDoc
			/// @func    set_debug_thumb_gizmo()
			/// @desc    Enables a debug thumb overlay and temporarily disables scissor clipping while drawing this scrollbar.
			/// @self    WWScrollbar
			/// @param   {Bool} enabled
			/// @returns {Struct.WWScrollbar}
			#endregion
            static set_debug_thumb_gizmo = function(_enabled=true) {
				__debug_thumb_gizmo__ = !!_enabled;
				return self;
            }

            #region jsDoc
			/// @func    set_callback()
			/// @desc    Sets callback invoked when scrollbar value changes.
			/// @self    WWScrollbar
			/// @param   {Function} callback
			/// @returns {Struct.WWScrollbar}
			#endregion
            static set_callback = function(_callback) {
				__user_callback__ = _callback;
				return self;
            }

            #region jsDoc
			/// @func    set_size()
			/// @desc    Sets the scrollbar size. Also updates the thumb size unless the thumb was user-sized.
			/// @self    WWScrollbar
			/// @param   {Real} width : Width of the scrollbar.
			/// @param   {Real} height : Height of the scrollbar.
			/// @returns {Struct.WWScrollbar}
			#endregion
            static set_size = function(_width, _height) {
                __size_set__ = true;
                __set_size__(_width, _height);

                if (!thumb.__size_set__) {
                    var _square = min(_width, _height);
                    thumb.__set_size__(_square, _square);
                }

                return self;
            }
			#region jsDoc
			/// @func    set_canvas_size()
			/// @desc    Sets the total scrollable content size used to compute scroll range and thumb size.
			/// @self    WWScrollbar
			/// @param   {Real} size : Total content size.
			/// @returns {Struct.WWScrollbar}
			#endregion
            static set_canvas_size = function(_size) {
                canvas_size = _size;
                max_scroll = max(0, canvas_size - coverage_size);
                set_clamp_values(0, max_scroll);
                __adjust_thumb_size__();
                return self;
            }
            #region jsDoc
			/// @func    set_coverage_size()
			/// @desc    Sets the visible coverage size used to compute scroll range, paging, and thumb size.
			/// @self    WWScrollbar
			/// @param   {Real} size : Visible size (viewport size).
			/// @returns {Struct.WWScrollbar}
			#endregion
            static set_coverage_size = function(_size) {
                coverage_size = _size;
                max_scroll = clamp(canvas_size - coverage_size, 0, canvas_size);
                set_clamp_values(0, max_scroll);
                __adjust_thumb_size__();
                return self;
            }
            #region jsDoc
			/// @func    set_smooth_scrolling()
			/// @desc    Enables or disables smooth scrolling (value changes ease toward a target).
			/// @self    WWScrollbar
			/// @param   {Bool} smooth : True to animate scroll changes.
			/// @returns {Struct.WWScrollbar}
			#endregion
            static set_smooth_scrolling = function(_smooth=false) {
                smooth_scrolling = _smooth;
                return self;
            }
			
			#region jsDoc
			/// @func    set_thumb()
			/// @desc    Replaces the internal thumb component used for dragging the scrollbar.
			///          The new thumb is added as a child and wired to the drag behavior.
			/// @self    WWScrollbar
			/// @param   {Struct.WWButtonSprite} thumb : The new thumb component.
			/// @returns {Struct.WWScrollbar}
			#endregion
			static set_thumb = function(_thumb) {
				if (is_undefined(_thumb)) return self;
				
				if (!is_undefined(thumb)) {
					remove(thumb);
				}
				
				thumb = _thumb;
				add(thumb);
				thumb.set_theme_keys(
					__thumb_theme_sprite_main__,
					__thumb_theme_sprite_state_prefix__,
					__thumb_theme_color_prefix__,
					__thumb_theme_alpha_prefix__
				);
				thumb.set_navigable(false);
				
				// Keep default sizing behavior: if the bar was sized and the thumb wasn't user-sized,
				// match the bar thickness.
				if (__size_set__ && !thumb.__size_set__) {
					var _square = min(get_width(), get_height());
					thumb.__set_size__(_square, _square);
				}
				
				// Re-wire thumb interactions
				thumb.on_pressed(function(_input) {
					thumb_offset = __get_mouse_pos__(_input) - __get_thumb_pos__();
				});
				thumb.on_interact(function(_input) {
					var _available_size = __get_available_size__();
					if (_available_size <= 0) return;
					
					var _mouse_pos = __get_mouse_pos__(_input) - thumb_offset;
					var _thumb_pos = _mouse_pos - __get_scroll_origin__();
					var _norm_val = _thumb_pos / _available_size;
					
					_norm_val = clamp(_norm_val, 0, 1);
					set_normalized_value(_norm_val);
				});
				
				if (canvas_size > 0) {
					__adjust_thumb_size__();
				}
				return self;
			}
			
			#region jsDoc
			/// @func    set_thumb_theme_keys()
			/// @desc    Sets theme key prefixes used by the internal thumb button.
			/// @self    WWScrollbar
			/// @param   {String} sprite_main
			/// @param   {String} sprite_state_prefix
			/// @param   {String} color_prefix
			/// @param   {String} alpha_prefix
			/// @returns {Struct.WWScrollbar}
			#endregion
			static set_thumb_theme_keys = function(
				_sprite_main = "scrollbar.sprite.thumb.main",
				_sprite_state_prefix = "scrollbar.sprite.thumb",
				_color_prefix = "scrollbar.color.thumb",
				_alpha_prefix = "scrollbar.alpha.thumb"
			) {
				__thumb_theme_sprite_main__ = _sprite_main;
				__thumb_theme_sprite_state_prefix__ = _sprite_state_prefix;
				__thumb_theme_color_prefix__ = _color_prefix;
				__thumb_theme_alpha_prefix__ = _alpha_prefix;
				
				thumb.set_theme_keys(
					__thumb_theme_sprite_main__,
					__thumb_theme_sprite_state_prefix__,
					__thumb_theme_color_prefix__,
					__thumb_theme_alpha_prefix__
				);
				return self;
			}
			
        #endregion
		
		#region Variables
			
			canvas_size = 0;
	        coverage_size = 0;
	        max_scroll = 0;
	        smooth_scrolling = false;
			__thumb_theme_sprite_main__ = "scrollbar.sprite.thumb.main";
			__thumb_theme_sprite_state_prefix__ = "scrollbar.sprite.thumb";
			__thumb_theme_color_prefix__ = "scrollbar.color.thumb";
			__thumb_theme_alpha_prefix__ = "scrollbar.alpha.thumb";
			__user_callback__ = undefined;
			__debug_thumb_gizmo__ = false;
			__debug_prev_scissor__ = undefined;
			__debug_scissor_lifted__ = false;
			
	        // Create Thumb
	        thumb = new WWButtonSprite();
			thumb.set_theme_keys(
				__thumb_theme_sprite_main__,
				__thumb_theme_sprite_state_prefix__,
				__thumb_theme_color_prefix__,
				__thumb_theme_alpha_prefix__
			);
	        add(thumb);
	        thumb.set_navigable(false);
	        set_navigable(false);
			
	    #endregion
		
        #region Events
			on_pre_draw(function(_input) {
				if (!__debug_thumb_gizmo__) return;
				__debug_prev_scissor__ = gpu_get_scissor();
				gpu_set_scissor(0, 0, display_get_gui_width(), display_get_gui_height());
				__debug_scissor_lifted__ = true;
			});

            // Clicking on Bar Moves the Thumb by %
            var __scroll_by_percent = method(self, function(_input) {
                var _mouse_pos = __get_mouse_pos__(_input);
                var _available_size = __get_available_size__();
                var _thumb_pos = __get_thumb_pos__();

                if (_available_size <= 0) return;

                if (_mouse_pos < _thumb_pos) {
                    decrement_scroll();
					//set_normalized_value(clamp(normalized_value - 0.1, 0, 1));
                } else if (_mouse_pos > (_thumb_pos + __get_thumb_size__())) {
                    increment_scroll()
					//set_normalized_value(clamp(normalized_value + 0.1, 0, 1));
                }
            });
            on_released(__scroll_by_percent);
            on_long_press(__scroll_by_percent);

            // Track Mouse Offset when Pressing the Thumb
            thumb_offset = 0;
            thumb.on_pressed(function(_input) {
                thumb_offset = __get_mouse_pos__(_input) - __get_thumb_pos__();
            });

            // Dragging the Thumb (Accounts for Mouse Offset)
            thumb.on_interact(function(_input) {
                var _available_size = __get_available_size__();
                if (_available_size <= 0) return;

                var _mouse_pos = __get_mouse_pos__(_input) - thumb_offset;
                var _thumb_pos = _mouse_pos - __get_scroll_origin__();
                var _norm_val = _thumb_pos / _available_size;

                _norm_val = clamp(_norm_val, 0, 1);
                set_normalized_value(_norm_val);
            });

            // Update Thumb Position
            on_pre_draw(function(_input) {
                var _available_size = __get_available_size__();
                var _thumb_pos = _available_size * normalized_value;
                __set_thumb_offset__(_thumb_pos);
            });

            // Value-change callback path used by scroll regions.
			on_event(events.value_changed, function(_value) {
				if (is_callable(__user_callback__)) __user_callback__();
			});

			on_post_draw(function(_input) {
				if (__debug_thumb_gizmo__ && !is_undefined(thumb) && thumb != noone) {
					var _x1 = thumb.x;
					var _y1 = thumb.y;
					var _x2 = _x1 + thumb.width;
					var _y2 = _y1 + thumb.height;

					draw_set_color(c_lime);
					draw_rectangle(_x1, _y1, _x2, _y2, true);
					draw_line(_x1, _y1, _x2, _y2);
					draw_line(_x2, _y1, _x1, _y2);
				}

				if (__debug_scissor_lifted__) {
					gpu_set_scissor(__debug_prev_scissor__);
					__debug_prev_scissor__ = undefined;
					__debug_scissor_lifted__ = false;
				}
			});
			
        #endregion
		
		#region Functions
			
			#region jsDoc
			/// @func    get_thumb()
			/// @desc    Returns the internal thumb component.
			/// @self    WWScrollbar
			/// @returns {Struct.WWButtonSprite}
			#endregion
			static get_thumb = function() {
				return thumb;
			};

			#region jsDoc
			/// @func    get_callback()
			/// @desc    Returns the callback currently used for value-change updates.
			/// @self    WWScrollbar
			/// @returns {Function}
			#endregion
			static get_callback = function() {
				return __user_callback__;
			};
			
			#region jsDoc
			/// @func    get_canvas_size()
			/// @desc    Returns the total scrollable content size.
			/// @self    WWScrollbar
			/// @returns {Real} canvas_size
			#endregion
			static get_canvas_size = function() {
				return canvas_size;
			};
			#region jsDoc
			/// @func    get_coverage_size()
			/// @desc    Returns the visible coverage size.
			/// @self    WWScrollbar
			/// @returns {Real} coverage_size
			#endregion
			static get_coverage_size = function() {
				return coverage_size;
			};
			#region jsDoc
			/// @func    get_smooth_scrolling()
			/// @desc    Returns whether smooth scrolling is enabled.
			/// @self    WWScrollbar
			/// @returns {Bool} is_enabled
			#endregion
			static get_smooth_scrolling = function() {
				return smooth_scrolling;
			};
			#region jsDoc
			/// @func    increment_scroll()
			/// @desc    Moves the scroll forward by a fraction of the coverage size (page step).
			///          Amount is interpreted as coverage_size * amount_of_view.
			/// @self    WWScrollbar
			/// @param   {Real} amount_of_view : Fraction of coverage size to move (default ~0.0666).
			/// @returns {Undefined}
			#endregion
			static increment_scroll = function(_amount_of_view = 0.0666) {
				
				if (smooth_scrolling) {
					var _loc = lerp_target + coverage_size * _amount_of_view;
					set_lerp_target(_loc);
				}
				else {
					var _loc = value + coverage_size * _amount_of_view;
					set_value(_loc);
					trigger_event(events.value_changed, value)
				}
				
			}
			#region jsDoc
			/// @func    decrement_scroll()
			/// @desc    Moves the scroll backward by a fraction of the coverage size (page step).
			/// @self    WWScrollbar
			/// @param   {Real} amount_of_view : Fraction of coverage size to move (default ~0.0666).
			/// @returns {Undefined}
			#endregion
			static decrement_scroll = function(_amount_of_view = 0.0666) {
				if (smooth_scrolling) {
					var _loc = lerp_target - coverage_size * _amount_of_view;
					set_lerp_target(_loc);
				}
				else {
					var _loc = value - coverage_size * _amount_of_view;
					set_value(_loc);
					trigger_event(events.value_changed, value)
				}
			}
			
		#endregion
		
    #endregion
	
    #region Private

        #region Functions
			
			#region jsDoc
			/// @func    __adjust_thumb_size__()
			/// @desc    Recomputes the thumb size from canvas/coverage ratio and available track size.
			/// @self    WWScrollbar
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __adjust_thumb_size__ = function() {
				if (canvas_size <= 0 || coverage_size <= 0) {
					__set_thumb_size__(10);
					return;
				}
				// IMPORTANT:
				// Use full track length, not available travel distance.
				// available = track - thumb, so using available feeds back on itself
				// and causes thumb-size oscillation across sync calls.
				var _track_size = max(1, __get_available_size__() + __get_thumb_size__());
				var _ratio = clamp(coverage_size / canvas_size, 0, 1);
				var _thumb_min = min(10, _track_size);
				var _thumb_size = clamp(floor(_track_size * _ratio + 0.5), _thumb_min, _track_size);

				__set_thumb_size__(_thumb_size);
            };
			
			#region Overwrites
			
			#region jsDoc
			/// @func    __get_mouse_pos__()
			/// @desc    Returns the mouse position projected onto the scrollbar's primary axis.
			/// @self    WWScrollbar
			/// @returns {Real} mouse_position
			/// @ignore
			#endregion
			static __get_mouse_pos__ = function(_input) { return 0; };
			#region jsDoc
			/// @func    __get_available_size__()
			/// @desc    Returns the total distance the thumb is allowed to travel along the track.
			/// @self    WWScrollbar
			/// @returns {Real} available_size
			/// @ignore
			#endregion
			static __get_available_size__ = function() { return 0; };
			#region jsDoc
			/// @func    __get_thumb_pos__()
			/// @desc    Returns the current position of the thumb along the scroll axis.
			/// @self    WWScrollbar
			/// @returns {Real} thumb_position
			/// @ignore
			#endregion
			static __get_thumb_pos__ = function() { return 0; };
			#region jsDoc
			/// @func    __get_thumb_size__()
			/// @desc    Returns the current size of the thumb along the scroll axis.
			/// @self    WWScrollbar
			/// @returns {Real} thumb_size
			/// @ignore
			#endregion
			static __get_thumb_size__ = function() { return 0; };
			#region jsDoc
			/// @func    __get_scroll_origin__()
			/// @desc    Returns the origin of the scroll region along the primary axis
			///          (left for horizontal, top for vertical).
			/// @self    WWScrollbar
			/// @returns {Real} scroll_origin
			/// @ignore
			#endregion
			static __get_scroll_origin__ = function() { return 0; };
			#region jsDoc
			/// @func    __set_thumb_offset__()
			/// @desc    Sets the thumb position along the scroll axis.
			/// @self    WWScrollbar
			/// @param   {Real} pos : New thumb position.
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __set_thumb_offset__ = function(_pos) {};
			#region jsDoc
			/// @func    __set_thumb_size__()
			/// @desc    Sets the thumb size along the scroll axis.
			/// @self    WWScrollbar
			/// @param   {Real} size : New thumb size.
			/// @returns {Undefined}
			/// @ignore
			#endregion
			static __set_thumb_size__ = function(_size) {};

			
			#endregion
			
        #endregion

    #endregion
	
}

