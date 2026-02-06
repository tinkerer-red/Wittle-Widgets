#region jsDoc
/// @func    WWScrollbarButtons()
/// @desc    A vertical scrollbar that includes up and down buttons for incrementing/decrementing the scroll value.
///         It uses a vertical slider in between the buttons to represent the current scroll position.
/// @returns {Struct.WWScrollbarButtons}
#endregion
function WWScrollbarButtons() : WWCore() constructor {
    debug_name = "WWScrollbarButtons";
    
    #region Public
        
        #region Builder Functions
			#region jsDoc
            /// @func    set_size()
            /// @desc    Sets the component's size (i.e., its interactive boundaries) as specified by the user.
            ///          This updates the region and marks the size as user–preferred so that future internal updates won't override it.
            /// @self    WWScrollbarButtons
            /// @param   {Real} width : The new width.
            /// @param   {Real} height : The new height.
            /// @returns {Struct.WWScrollbarButtons}
            #endregion
            static set_size = function(_width, _height) {
                __size_set__ = true;
                __set_size__(_width, _height);
                upButton.set_size(width, 30);
                slider.set_size(width, height-60);
                downButton.set_size(width, 30);
                
                return self;
            }
            
            #region jsDoc
            /// @func    set_canvas_size()
            /// @desc    Sets the full height of the scrollable content.
            /// @self    WWScrollbarButtons
            /// @param   {Real} height : The height of the scrollable canvas.
            /// @returns {Struct.WWScrollbarButtons}
            #endregion
            static set_canvas_size = function(_height) {
                canvasHeight = _height;
                update_slider_range();
                return self;
            }
            
            #region jsDoc
            /// @func    set_coverage_size()
            /// @desc    Sets the visible (viewport) height for the scroll area.
            /// @self    WWScrollbarButtons
            /// @param   {Real} height : The height of the visible area.
            /// @returns {Struct.WWScrollbarButtons}
            #endregion
            static set_coverage_size = function(_height) {
                coverageHeight = _height;
                update_slider_range();
                return self;
            }
			
            #region jsDoc
            /// @func    set_callback()
            /// @desc    Sets an additional callback invoked when either arrow button is pressed.
            ///          This chains after the built-in scroll step behavior.
            /// @self    WWScrollbarButtons
            /// @param   {Function} callback : User callback.
            /// @returns {Struct.WWScrollbarButtons}
            #endregion
            static set_callback = function(_callback) {
                __user_callback__ = _callback;
				
                upButton.set_callback(function() {
                    if (is_callable(__default_up_callback__)) {
                        __default_up_callback__();
                    }
                    if (is_callable(__user_callback__)) {
                        __user_callback__();
                    }
                });
				
                downButton.set_callback(function() {
                    if (is_callable(__default_down_callback__)) {
                        __default_down_callback__();
                    }
                    if (is_callable(__user_callback__)) {
                        __user_callback__();
                    }
                });
				
                return self;
            }
			
            #region jsDoc
            /// @func    set_value()
            /// @desc    Forwards to the internal slider's set_value.
            /// @self    WWScrollbarButtons
            /// @param   {Real} value : New slider value.
            /// @returns {Struct.WWScrollbarButtons}
            #endregion
            static set_value = function(_value) {
                slider.set_value(_value);
                return self;
            }
			
            #region jsDoc
            /// @func    set_normalized_value()
            /// @desc    Forwards to the internal slider's set_normalized_value.
            /// @self    WWScrollbarButtons
            /// @param   {Real} value : Normalized value (0..1).
            /// @returns {Struct.WWScrollbarButtons}
            #endregion
            static set_normalized_value = function(_value) {
                slider.set_normalized_value(_value);
                return self;
            }
			
            #region jsDoc
            /// @func    set_clamp_values()
            /// @desc    Forwards to the internal slider's set_clamp_values.
            /// @self    WWScrollbarButtons
            /// @param   {Real} min : Minimum clamp.
            /// @param   {Real} max : Maximum clamp.
            /// @returns {Struct.WWScrollbarButtons}
            #endregion
            static set_clamp_values = function(_min, _max) {
                slider.set_clamp_values(_min, _max);
                return self;
            }
			
            #region jsDoc
            /// @func    set_rounding()
            /// @desc    Forwards to the internal slider's set_rounding.
            /// @self    WWScrollbarButtons
            /// @param   {Bool} round : True to round values.
            /// @returns {Struct.WWScrollbarButtons}
            #endregion
            static set_rounding = function(_round) {
                slider.set_rounding(_round);
                return self;
            }
			
            #region jsDoc
            /// @func    set_lerp_target()
            /// @desc    Forwards to the internal slider's set_lerp_target.
            /// @self    WWScrollbarButtons
            /// @param   {Real} lerp_target : New lerp target.
            /// @returns {Struct.WWScrollbarButtons}
            #endregion
            static set_lerp_target = function(_lerp_target) {
                slider.set_lerp_target(_lerp_target);
                return self;
            }
			
            #region jsDoc
            /// @func    set_inverted()
            /// @desc    Forwards to the internal slider's set_inverted.
            /// @self    WWScrollbarButtons
            /// @param   {Bool} invert : True to invert slider direction.
            /// @returns {Struct.WWScrollbarButtons}
            #endregion
            static set_inverted = function(_invert) {
                slider.set_inverted(_invert);
                return self;
            }
			
            #region jsDoc
            /// @func    set_bar_size()
            /// @desc    Forwards to the internal slider's set_bar_size.
            /// @self    WWScrollbarButtons
            /// @param   {Real} left
            /// @param   {Real} top
            /// @param   {Real} right
            /// @param   {Real} bottom
            /// @returns {Struct.WWScrollbarButtons}
            #endregion
            static set_bar_size = function(_left, _top, _right, _bottom) {
                slider.set_bar_size(_left, _top, _right, _bottom);
                return self;
            }
			
            #region jsDoc
            /// @func    set_background_size()
            /// @desc    Forwards to the internal slider's set_background_size.
            /// @self    WWScrollbarButtons
            /// @param   {Real} left
            /// @param   {Real} top
            /// @param   {Real} right
            /// @param   {Real} bottom
            /// @returns {Struct.WWScrollbarButtons}
            #endregion
            static set_background_size = function(_left, _top, _right, _bottom) {
                slider.set_background_size(_left, _top, _right, _bottom);
                return self;
            }
        #endregion
        
        #region Components
            // Up Arrow Button
            upButton = new WWButtonSprite()
                .set_offset(0, 0)
                .set_size(width, 30)
                .set_callback(function() {
                    // Decrease the slider's value by a fixed step.
                    slider.set_value(slider.get_value() - 0.05);
                });
            
            // Vertical Slider between the buttons.
            // Its height is the total height minus the up and down button areas.
            slider = new WWSliderVert()
                .set_offset(0, 30)
                .set_size(width, height - 60)
                .set_value(0.0)
                .set_callback(function() {
                    // Fire a custom event with the new scroll value.
                    trigger_event(events.scroll_changed, slider.get_value());
                });
            
            // Down Arrow Button
            downButton = new WWButtonSprite()
                .set_alignment(fa_left, fa_bottom)
                .set_offset(0, -30)
                .set_size(width, 30)
                .set_callback(function() {
                    // Increase the slider's value by a fixed step.
                    slider.set_value(slider.get_value() + 0.05);
                });
            
            add(upButton);
            add(slider);
            add(downButton);
			//__adopt_children_events__();
        #endregion
        
        #region Events
            // Custom event fired whenever the slider's value changes.
            events.scroll_changed = variable_get_hash("scroll_changed");
        #endregion
        
        #region Variables
            // Full content height and visible area height.
            canvasHeight = height;    // Defaults to window height (can be set via builder)
            coverageHeight = height - 60;  // Visible area = total height minus button areas.
			
			__user_callback__ = undefined;
			__default_up_callback__ = upButton.get_callback();
			__default_down_callback__ = downButton.get_callback();
        #endregion
        
        #region Functions
			#region jsDoc
			/// @func    get_callback()
			/// @desc    Returns the user callback set via set_callback (does not include internal step callbacks).
			/// @self    WWScrollbarButtons
			/// @returns {Function|Undefined}
			#endregion
			static get_callback = function() {
				return __user_callback__;
			}
			
            #region jsDoc
            /// @func    get_value()
            /// @desc    Forwards to the internal slider's get_value.
            /// @self    WWScrollbarButtons
            /// @returns {Real}
            #endregion
            static get_value = function() {
                return slider.get_value();
            }
			
            #region jsDoc
            /// @func    get_normalized_value()
            /// @desc    Forwards to the internal slider's get_normalized_value.
            /// @self    WWScrollbarButtons
            /// @returns {Real}
            #endregion
            static get_normalized_value = function() {
                return slider.get_normalized_value();
            }
			
            #region jsDoc
            /// @func    get_clamp_values()
            /// @desc    Forwards to the internal slider's get_clamp_values.
            /// @self    WWScrollbarButtons
            /// @returns {Struct}
            #endregion
            static get_clamp_values = function() {
                return slider.get_clamp_values();
            }
			
            #region jsDoc
            /// @func    get_rounding()
            /// @desc    Forwards to the internal slider's get_rounding.
            /// @self    WWScrollbarButtons
            /// @returns {Bool}
            #endregion
            static get_rounding = function() {
                return slider.get_rounding();
            }
			
            #region jsDoc
            /// @func    get_lerp_target()
            /// @desc    Forwards to the internal slider's get_lerp_target.
            /// @self    WWScrollbarButtons
            /// @returns {Real}
            #endregion
            static get_lerp_target = function() {
                return slider.get_lerp_target();
            }
			
            #region jsDoc
            /// @func    get_inverted()
            /// @desc    Forwards to the internal slider's get_inverted.
            /// @self    WWScrollbarButtons
            /// @returns {Bool}
            #endregion
            static get_inverted = function() {
                return slider.get_inverted();
            }
			
            #region jsDoc
            /// @func    get_bar_size()
            /// @desc    Forwards to the internal slider's get_bar_size.
            /// @self    WWScrollbarButtons
            /// @returns {Struct}
            #endregion
            static get_bar_size = function() {
                return slider.get_bar_size();
            }
			
            #region jsDoc
            /// @func    get_background_size()
            /// @desc    Forwards to the internal slider's get_background_size.
            /// @self    WWScrollbarButtons
            /// @returns {Struct}
            #endregion
            static get_background_size = function() {
                return slider.get_background_size();
            }
			
            #region jsDoc
            /// @func    get_canvas_size()
            /// @desc    Returns the full (scrollable) canvas height used by this scrollbar.
            /// @self    WWScrollbarButtons
            /// @returns {Real} height
            #endregion
            static get_canvas_size = function() {
                return canvasHeight;
            }
			
            #region jsDoc
            /// @func    get_coverage_size()
            /// @desc    Returns the visible (viewport) height used by this scrollbar.
            /// @self    WWScrollbarButtons
            /// @returns {Real} height
            #endregion
            static get_coverage_size = function() {
                return coverageHeight;
            }
			
			#region jsDoc
			/// @func    update_slider_range()
			/// @desc    Recomputes the slider scroll range from canvas/coverage sizes.
			/// @self    WWScrollbarButtons
			/// @returns {Undefined}
			#endregion
            static update_slider_range = function() {
                // Calculate the maximum scrollable offset.
                var maxScroll = max(0, canvasHeight - coverageHeight);
                // The slider's normalized value (0 to 1) will map to a scroll range of 0 to maxScroll.
                // (In this example, we assume the slider's internal logic handles normalization.)
                // For now, we'll force an update.
                slider.set_value(slider.get_value());
            }
        #endregion
        
    #endregion
        
    #region Private
        #region Variables
            // Private variables can be added here if needed.
        #endregion
        
        #region Functions
            // Private helper functions can be added here if needed.
        #endregion
    #endregion
}
