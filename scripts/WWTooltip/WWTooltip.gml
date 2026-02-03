#region jsDoc
/// @func    WWTooltip()
/// @desc    A hover-activated helper that displays additional context.
/// @returns {Struct.WWTooltip}
#endregion
function WWTooltip() : WWLabel() constructor {
    debug_name = "WWTooltip";
    
    #region Public
        
        #region Builder Functions
            #region jsDoc
            /// @func    set_delay()
            /// @desc    Sets the delay (in steps/frames) before the tooltip appears.
            /// @self    WWTooltip
            /// @param   {Real} delay : Delay in frames.
            /// @returns {Struct.WWTooltip}
            #endregion
            static set_delay = function(_delay) {
            delay = _delay;
            return self;
            }
        #endregion
        
        #region Components
        // Inherits text functionality from WWLabel.
        #endregion
        
        #region Events
        on_mouse_over(function() {
            tooltipVisible = true;
            update_visibility();
        });
        on_mouse_off(function() {
            tooltipVisible = false;
            update_visibility();
        });
        #endregion
        
        #region Variables
        delay = 30; // Frames before showing tooltip.
        tooltipVisible = false;
        #endregion
        
        #region Functions
            #region jsDoc
            /// @func    update_visibility()
            /// @desc    Enables/disables the tooltip based on hover state.
            /// @self    WWTooltip
            /// @returns {Undefined}
            #endregion
            static update_visibility = function() {
            if (tooltipVisible) {
                self.set_enabled(true);
            } else {
                self.set_enabled(false);
            }
            }
        #endregion
        
    #endregion
    
    #region Private
        #region Variables
        // Private tooltip variables.
        #endregion
        
        #region Functions
        // Private functions.
        #endregion
    #endregion
}
