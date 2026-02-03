#region jsDoc
/// @func    WWToast()
/// @desc    A transient notification element for brief, unobtrusive messages.
/// @returns {Struct.WWToast}
#endregion
function WWToast() : WWCore() constructor {
    debug_name = "WWToast";
    
    #region Public
        
        #region Builder Functions
            #region jsDoc
            /// @func    set_message()
            /// @desc    Sets the toast message text.
            /// @self    WWToast
            /// @param   {String} msg : Toast message.
            /// @returns {Struct.WWToast}
            #endregion
            static set_message = function(_msg) {
            messageText.set_text(_msg);
            return self;
            }
            #region jsDoc
            /// @func    set_duration()
            /// @desc    Sets the duration (in steps/frames) before the toast auto-hides.
            /// @self    WWToast
            /// @param   {Real} dur : Duration in frames.
            /// @returns {Struct.WWToast}
            #endregion
            static set_duration = function(_dur) {
            duration = _dur;
            return self;
            }
        #endregion
        
        #region Components
        messageText = new WWLabel()
            .set_offset(10, 10)
            .set_text("Toast Message");
        self.add(messageText);
        #endregion
        
        #region Events
        on_post_step(function(_input) {
            duration -= 1;
            if (duration <= 0) {
                self.set_enabled(false);
            }
        });
        #endregion
        
        #region Variables
        duration = 120; // Duration in frames.
        #endregion
        
        #region Functions
        // Additional functions if needed.
        #endregion
        
    #endregion
    
    #region Private
        #region Variables
        // Private variables.
        #endregion
        
        #region Functions
        // Private functions.
        #endregion
    #endregion
}
