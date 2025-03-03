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
            ///          This updates the region and marks the size as user–preferred so that future internal updates won’t override it.
            /// @self    WWCore
            /// @param   {real} width : The new width.
            /// @param   {real} height : The new height.
            /// @returns {Struct.WWCore}
            #endregion
            static set_size = function(_width, _height) {
                __size_set__ = true;
                __set_size__(_width, _height);
                upButton.set_size(self.width, 30);
                slider.set_size(self.width, self.height-60);
                downButton.set_size(self.width, 30);
                
                return self;
            }
            
            #region jsDoc
            /// @func    set_canvas_size()
            /// @desc    Sets the full height of the scrollable content.
            /// @self    WWScrollbarButtons
            /// @param   {Real} _height : The height of the scrollable canvas.
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
            /// @param   {Real} _height : The height of the visible area.
            /// @returns {Struct.WWScrollbarButtons}
            #endregion
            static set_coverage_size = function(_height) {
                coverageHeight = _height;
                update_slider_range();
                return self;
            }
        #endregion
        
        #region Components
            // Up Arrow Button
            upButton = new WWButtonText()
                .set_offset(0, 0)
                .set_size(self.width, 30)
                .set_text("▲")
                .set_callback(function() {
                    // Decrease the slider's value by a fixed step.
                    slider.set_value(slider.get_value() - 0.05);
                });
            
            // Vertical Slider between the buttons.
            // Its height is the total height minus the up and down button areas.
            slider = new WWSliderVert()
                .set_offset(0, 30)
                .set_size(self.width, self.height - 60)
                .set_value(0.0)
                .set_callback(function() {
                    // Fire a custom event with the new scroll value.
                    trigger_event(self.events.scroll_changed, slider.get_value());
                });
            
            // Down Arrow Button
            downButton = new WWButtonText()
                .set_alignment(fa_left, fa_bottom)
                .set_offset(0, -30)
                .set_size(self.width, 30)
                .set_text("▼")
                .set_callback(function() {
                    // Increase the slider's value by a fixed step.
                    slider.set_value(slider.get_value() + 0.05);
                });
            
            self.add(upButton);
            self.add(slider);
            self.add(downButton);
			__adopt_children_events__();
        #endregion
        
        #region Events
            // Custom event fired whenever the slider's value changes.
            self.events.scroll_changed = variable_get_hash("scroll_changed");
        #endregion
        
        #region Variables
            // Full content height and visible area height.
            canvasHeight = self.height;    // Defaults to window height (can be set via builder)
            coverageHeight = self.height - 60;  // Visible area = total height minus button areas.
        #endregion
        
        #region Functions
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
