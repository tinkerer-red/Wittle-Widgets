#region jsDoc
/// @func    WWDivider()
/// @desc    Provides a visual separator between UI sections.
/// @returns {Struct.WWDivider}
#endregion
function WWDivider() : WWCore() constructor {
    debug_name = "WWDivider";
    
    #region Public
        
        #region Builder Functions
        #region jsDoc
        /// @func    set_thickness()
        /// @desc    Sets the divider thickness in pixels.
        /// @self    WWDivider
        /// @param   {Real} thickness : The divider thickness.
        /// @returns {Struct.WWDivider}
        #endregion
        static set_thickness = function(_thickness) {
            thickness = _thickness;
            return self;
        }
        #region jsDoc
        /// @func    set_color()
        /// @desc    Sets the divider color used when drawing.
        /// @self    WWDivider
        /// @param   {Real} color : The divider draw color.
        /// @returns {Struct.WWDivider}
        #endregion
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
        #region jsDoc
        /// @func    draw()
        /// @desc    Draws the divider as a simple rectangle.
        /// @self    WWDivider
        /// @param   {Struct} input : Per-frame input state (unused).
        /// @returns {Undefined}
        #endregion
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
