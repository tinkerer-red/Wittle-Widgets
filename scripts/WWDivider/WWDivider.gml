#region jsDoc
/// @func    WWDivider()
/// @desc    Provides a visual separator between UI sections.
/// @returns {Struct.WWDivider}
#endregion
function WWDivider() : WWCore() constructor {
    debug_name = "WWDivider";
    
    #region Public
        
        #region Builder Functions
        static set_thickness = function(_thickness) {
            thickness = _thickness;
            return self;
        }
        static set_color = function(_color) {
            dividerColor = _color;
            return self;
        }
        #endregion
        
        #region Components
        // No sub-components.
        #endregion
        
        #region Events
        // No additional events.
        #endregion
        
        #region Variables
        thickness = 2;
        dividerColor = c_gray;
        #endregion
        
        #region Functions
        static draw = function(_input) {
            draw_set_color(dividerColor);
            draw_rectangle(x, y, x + width, y + thickness, true);
        }
        #endregion
        
    #endregion
    
    #region Private
        
        #region Variables
        #endregion
        
        #region Functions
        #endregion
        
    #endregion
}
