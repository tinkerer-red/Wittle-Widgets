#region jsDoc
/// @func    WWScrollbarHorz()
/// @desc    Creates a horizontal scrollbar using a slider with a thumb.
/// @returns {Struct.WWScrollbarHorz}
#endregion
function WWScrollbarHorz() : WWScrollbar() constructor {
    debug_name = "WWScrollbarHorz";

    // Overrides
    #region jsDoc
    /// @func    __get_mouse_pos__()
    /// @desc    Returns the current mouse position projected onto the scrollbar axis (X).
    /// @self    WWScrollbarHorz
    /// @returns {Real} mouse_pos
    /// @ignore
    #endregion
    static __get_mouse_pos__      = function(_input) { return _input.pointer.x; };
    #region jsDoc
    /// @func    __get_available_size__()
    /// @desc    Returns the distance the thumb can travel along the track.
    /// @self    WWScrollbarHorz
    /// @returns {Real} available_size
    /// @ignore
    #endregion
    static __get_available_size__ = function() { return width - thumb.width; };
    #region jsDoc
    /// @func    __get_thumb_pos__()
    /// @desc    Returns the thumb position along the track.
    /// @self    WWScrollbarHorz
    /// @returns {Real} thumb_pos
    /// @ignore
    #endregion
    static __get_thumb_pos__      = function() { return x + (width - thumb.width) * normalized_value; };
    #region jsDoc
    /// @func    __get_thumb_size__()
    /// @desc    Returns the thumb size along the track.
    /// @self    WWScrollbarHorz
    /// @returns {Real} thumb_size
    /// @ignore
    #endregion
    static __get_thumb_size__     = function() { return thumb.width; };
    #region jsDoc
    /// @func    __get_scroll_origin__()
    /// @desc    Returns the scroll origin (left edge) along the track.
    /// @self    WWScrollbarHorz
    /// @returns {Real} scroll_origin
    /// @ignore
    #endregion
    static __get_scroll_origin__  = function() { return x; };
    #region jsDoc
    /// @func    __set_thumb_offset__()
    /// @desc    Sets the thumb position along the track.
    /// @self    WWScrollbarHorz
    /// @param   {Real} pos : New thumb position.
    /// @returns {Undefined}
    /// @ignore
    #endregion
    static __set_thumb_offset__   = function(_pos) { thumb.set_offset(_pos, 0); };
    #region jsDoc
    /// @func    __set_thumb_size__()
    /// @desc    Sets the thumb size along the track.
    /// @self    WWScrollbarHorz
    /// @param   {Real} size : New thumb size.
    /// @returns {Undefined}
    /// @ignore
    #endregion
    static __set_thumb_size__     = function(_size) { thumb.set_size(_size, height); };
}

