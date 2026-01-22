#region jsDoc
/// @func    WWScrollbar()
/// @desc    Base class for horizontal and vertical scrollbars.
/// @returns {Struct.WWScrollbar}
#endregion
function WWScrollbar() : WWSliderBase() constructor {
    debug_name = "WWScrollbar";
	
    #region Public

        #region Builder Functions

            #region jsDoc
			/// @func    set_size()
			/// @desc    Sets the scrollbar size. Also updates the thumb size unless the thumb was user-sized.
			/// @self    WWScrollbar
			/// @param   {Real} _width : Width of the scrollbar.
			/// @param   {Real} _height : Height of the scrollbar.
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
			/// @param   {Real} _size : Total content size.
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
			/// @param   {Real} _size : Visible size (viewport size).
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
			/// @param   {Bool} _smooth : True to animate scroll changes.
			/// @returns {Struct.WWScrollbar}
			#endregion
            static set_smooth_scrolling = function(_smooth=false) {
                smooth_scrolling = _smooth;
                return self;
            }
			
        #endregion
		
		#region Variables
			
			canvas_size = 0;
	        coverage_size = 0;
	        max_scroll = 0;
	        smooth_scrolling = false;
			
	        // 📌 Create Thumb
	        thumb = new WWSliderThumb()
	            .set_sprite(spr_ww_pixel)
	            .set_sprite_color(c_white);
	        add(thumb);
			
	    #endregion
		
        #region Events

            // Clicking on Bar Moves the Thumb by %
            var __scroll_by_percent = method(self, function(_input) {
                var _mouse_pos = __get_mouse_pos__();
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
                thumb_offset = __get_mouse_pos__() - __get_thumb_pos__();
            });

            // Dragging the Thumb (Accounts for Mouse Offset)
            thumb.on_interact(function(_input) {
                var _available_size = __get_available_size__();
                if (_available_size <= 0) return;

                var _mouse_pos = __get_mouse_pos__() - thumb_offset;
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
			
        #endregion
		
		#region Functions
			
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
			/// @desc    Increments the scroll bar's value by a ratio of the coverage size, usually the view.
			/// @self    GUICompScrollBar
			/// @param   {Real} amount_of_view : The total amount of the view which should be moved, be default this is 0.06 which is a general standard but if you wish to include a faster scroll rate you can increase this value.
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
					trigger_event(self.events.value_changed, value)
				}
				
			}
			#region jsDoc
			/// @func    decrement_scroll()
			/// @desc    Moves the scroll backward by a fraction of the coverage size (page step).
			/// @self    WWScrollbar
			/// @param   {Real} _amount_of_view : Fraction of coverage size to move (default ~0.0666).
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
					trigger_event(self.events.value_changed, value)
				}
			}
			
		#endregion
		
    #endregion
	
    #region Private

        #region Functions
			
			#region jsDoc
			/// @func    __adjust_thumb_size__()
			/// @desc    Recomputes the thumb size from canvas/coverage ratio and available track size.
			/// @returns {Undefined}
			///@ignore
			#endregion
            static __adjust_thumb_size__ = function() {
                var _ratio = coverage_size / canvas_size;
                var _thumb_size = __get_available_size__() * _ratio;
                _thumb_size = max(_thumb_size, 10); // Ensure minimum thumb size
				
				__set_thumb_size__(_thumb_size);
            };
			
			#region Overwrites
			
			#region jsDoc
			/// @func    __get_mouse_pos__()
			/// @desc    Returns the mouse position projected onto the scrollbar's primary axis.
			/// @returns {Real} mouse_position
			///@ignore
			#endregion
			static __get_mouse_pos__ = function() { return 0; };
			#region jsDoc
			/// @func    __get_available_size__()
			/// @desc    Returns the total distance the thumb is allowed to travel along the track.
			/// @returns {Real} available_size
			///@ignore
			#endregion
			static __get_available_size__ = function() { return 0; };
			#region jsDoc
			/// @func    __get_thumb_pos__()
			/// @desc    Returns the current position of the thumb along the scroll axis.
			/// @returns {Real} thumb_position
			///@ignore
			#endregion
			static __get_thumb_pos__ = function() { return 0; };
			#region jsDoc
			/// @func    __get_thumb_size__()
			/// @desc    Returns the current size of the thumb along the scroll axis.
			/// @returns {Real} thumb_size
			///@ignore
			#endregion
			static __get_thumb_size__ = function() { return 0; };
			#region jsDoc
			/// @func    __get_scroll_origin__()
			/// @desc    Returns the origin of the scroll region along the primary axis
			///          (left for horizontal, top for vertical).
			/// @returns {Real} scroll_origin
			///@ignore
			#endregion
			static __get_scroll_origin__ = function() { return 0; };
			#region jsDoc
			/// @func    __set_thumb_offset__()
			/// @desc    Sets the thumb position along the scroll axis.
			/// @param   {Real} _pos : New thumb position.
			/// @returns {Undefined}
			///@ignore
			#endregion
			static __set_thumb_offset__ = function(_pos) {};
			#region jsDoc
			/// @func    __set_thumb_size__()
			/// @desc    Sets the thumb size along the scroll axis.
			/// @param   {Real} _size : New thumb size.
			/// @returns {Undefined}
			///@ignore
			#endregion
			static __set_thumb_size__ = function(_size) {};

			
			#endregion
			
        #endregion

    #endregion
	
}

