#region jsDoc
/// @func    WWScrollbarHorz()
/// @desc    Creates a horizontal scrollbar using a slider with a thumb.
/// @returns {Struct.WWScrollbarHorz}
#endregion
function WWScrollbarHorz() : WWScrollbarBase() constructor {
    debug_name = "WWScrollbarHorz";

    // Overrides
    __get_mouse_pos__      = function() { return device_mouse_x_to_gui(0); };
    __get_available_size__ = function() { return region.get_width() - thumb.region.get_width(); };
    __get_thumb_pos__      = function() { return x + (region.get_width() - thumb.region.get_width()) * normalized_value; };
    __get_thumb_size__     = function() { return thumb.region.get_width(); };
    __get_scroll_origin__  = function() { return x; };
    __set_thumb_offset__   = function(_pos) { thumb.set_offset(_pos, 0); };
	__set_thumb_size__ = function(_size) { thumb.set_size(_size, region.get_height()); };
}
#region jsDoc
/// @func    WWScrollbarVert()
/// @desc    Creates a vertical scrollbar using a slider with a thumb.
/// @returns {Struct.WWScrollbarVert}
#endregion
function WWScrollbarVert() : WWScrollbarBase() constructor {
    debug_name = "WWScrollbarVert";

    // Overrides
    __get_mouse_pos__ = function() { return device_mouse_y_to_gui(0); };
    __get_available_size__ = function() { return region.get_height() - thumb.region.get_height(); };
    __get_thumb_pos__ = function() { return y + (region.get_height() - thumb.region.get_height()) * normalized_value; };
    __get_thumb_size__ = function() { return thumb.region.get_height(); };
    __get_scroll_origin__ = function() { return y; };
    __set_thumb_offset__ = function(_pos) { thumb.set_offset(0, _pos); };
	__set_thumb_size__ = function(_size) { thumb.set_size(region.get_width(), _size); };
}

#region jsDoc
/// @func    WWScrollbarBase()
/// @desc    Base class for horizontal and vertical scrollbars.
/// @returns {Struct.WWScrollbarBase}
#endregion
function WWScrollbarBase() : WWSliderBase() constructor {
    debug_name = "WWScrollbarBase";
	
    #region Public

        #region Builder Functions

            #region jsDoc
            /// @func    set_size()
            /// @desc    Sets the component's size (i.e., its interactive boundaries) as specified by the user.
            ///          This updates the region and marks the size as user-preferred so that future internal updates won’t override it.
            /// @self    WWScrollbarBase
            /// @param   {real} left : The left side of the bounding box.
            /// @param   {real} top : The top side of the bounding box.
            /// @param   {real} right : The right side of the bounding box.
            /// @param   {real} bottom : The bottom side of the bounding box.
            /// @returns {Struct.WWScrollbarBase}
            #endregion
            static set_size = function(_left, _top, _right=undefined, _bottom=undefined) {
                // Support width/height shorthand
                if (_right == undefined && _bottom == undefined) {
                    _right  = _left;
                    _bottom = _top;
                    _left   = 0;
                    _top    = 0;
                }

                __size_set__ = true;
                __set_size__(_left, _top, _right, _bottom);

                if (!thumb.__size_set__) {
                    var _w = _right - _left;
                    var _h = _bottom - _top;
                    var _square = min(_w, _h);
                    thumb.__set_size__(0, 0, _square, _square);
                }

                return self;
            }
			#region jsDoc
            /// @func    set_canvas_size()
            /// @desc    Sets the total size of the scrollable canvas.
            ///          This determines how large the thumb should be relative to the visible region.
            /// @self    WWScrollbarBase
            /// @param   {Real} size : The size of the scrollable content.
            /// @returns {Struct.WWScrollbarBase}
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
            /// @desc    Sets the visible portion of the scrollable area.
            ///          This affects how much movement occurs when clicking the scrollbar background.
            /// @self    WWScrollbarBase
            /// @param   {Real} size : The size of the viewport.
            /// @returns {Struct.WWScrollbarBase}
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
            /// @desc    Enables or disables smooth scrolling.
            /// @self    WWScrollbarBase
            /// @param   {Bool} smooth : If true, scrolling will be animated instead of instant.
            /// @returns {Struct.WWScrollbarBase}
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
	            .set_sprite(s9GUIPixel)
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
			/// @desc    Decrements the scroll bar's value by a ratio of the coverage size, usually the view.
			/// @self    GUICompScrollBar
			/// @param   {Real} amount_of_view : The total amount of the view which should be moved, be default this is 0.06 which is a general standard but if you wish to include a faster scroll rate you can increase this value.
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
			
			// Dynamically adjust the scrollbar thumb size based on content size
            static __adjust_thumb_size__ = function() {
                var _ratio = coverage_size / canvas_size;
                var _thumb_size = __get_available_size__() * _ratio;
                _thumb_size = max(_thumb_size, 10); // Ensure minimum thumb size
				
				__set_thumb_size__(_thumb_size);
            };
			
			#region Overwrites
			
            /// @desc Returns the position of the mouse in the relevant axis.
            static __get_mouse_pos__ = function() { return 0; }; // Overridden in subclass
			/// @desc Returns the available space the thumb can move within.
            static __get_available_size__ = function() { return 0; }; // Overridden in subclass
            /// @desc Returns the current position of the thumb.
            static __get_thumb_pos__ = function() { return 0; }; // Overridden in subclass
            /// @desc Returns the size of the thumb.
            static __get_thumb_size__ = function() { return 0; }; // Overridden in subclass
            /// @desc Returns the scroll region’s origin (left for horizontal, top for vertical).
            static __get_scroll_origin__ = function() { return 0; }; // Overridden in subclass
            /// @desc Updates the thumb's position.
            static __set_thumb_offset__ = function(_pos) {}; // Overridden in subclass
			/// @desc Updates the thumb size appropriately based on the scroll direction.
			static __set_thumb_size__ = function(_size) {}; // Overridden in subclass
			
			#endregion
			
        #endregion

    #endregion
	
}

