#region jsDoc
/// @func    WWPanel()
/// @desc    A generic container that groups and organizes related UI elements.
/// @returns {Struct.WWPanel}
#endregion
function WWPanel() : WWCore() constructor {
    debug_name = "WWPanel";
    
    #region Public
        
        #region Builder Functions
        static set_border_color = function(_color) {
            borderColor = _color;
            return self;
        }
        #endregion
        
        #region Components
        // No extra sub-components by default.
        #endregion
        
        #region Events
        // Inherits base events.
        #endregion
        
        #region Variables
        borderColor = c_black;
        #endregion
        
        #region Functions
        on_pre_draw(function(_input) {
            // Draw a border
            draw_set_color(borderColor);
            draw_rectangle(x, y, x + width, y + height, false);
        })
        #endregion
        
    #endregion
    
    #region Private
        
        #region Variables
        #endregion
        
        #region Functions
        #endregion
        
    #endregion
}
