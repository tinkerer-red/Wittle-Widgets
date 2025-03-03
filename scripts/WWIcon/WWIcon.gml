#region jsDoc
/// @func    WWIcon()
/// @desc    Renders an image or icon.
/// @returns {Struct.WWIcon}
#endregion
function WWIcon() : WWCore() constructor {
    debug_name = "WWIcon";
    
    #region Public
        
        #region Builder Functions
        static set_icon = function(_sprite) {
            set_sprite(_sprite);
            return self;
        }
        #endregion
        
        #region Components
        // No sub-components.
        #endregion
        
        #region Events
        // Inherits base events.
        #endregion
        
        #region Variables
        // Additional icon properties can be added here.
        #endregion
        
        #region Functions
        // Inherits draw from WWCore.
        #endregion
        
    #endregion
    
    #region Private
        
        #region Variables
        #endregion
        
        #region Functions
        #endregion
        
    #endregion
}
