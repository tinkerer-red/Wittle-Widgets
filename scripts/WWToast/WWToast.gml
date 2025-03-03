#region jsDoc
/// @func    WWToast()
/// @desc    A transient notification element for brief, unobtrusive messages.
/// @returns {Struct.WWToast}
#endregion
function WWToast() : WWCore() constructor {
    debug_name = "WWToast";
    
    #region Public
        
        #region Builder Functions
        static set_message = function(_msg) {
            messageText.set_text(_msg);
            return self;
        }
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
