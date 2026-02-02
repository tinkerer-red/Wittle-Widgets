#region jsDoc
/// @func    WWScrollbarVert()
/// @desc    Creates a vertical scrollbar using a slider with a thumb.
/// @returns {Struct.WWScrollbarVert}
#endregion
function WWScrollbarVert() : WWScrollbar() constructor {
    debug_name = "WWScrollbarVert";

    // Overrides
    #region jsDoc
    /// @func    __get_mouse_pos__()
    /// @desc    Returns the current mouse position projected onto the scrollbar axis (Y).
    /// @returns {Real} mouse_pos
    /// @ignore
    #endregion
    static __get_mouse_pos__      = function() { return device_mouse_y_to_gui(0); };
    #region jsDoc
    /// @func    __get_available_size__()
    /// @desc    Returns the distance the thumb can travel along the track.
    /// @returns {Real} available_size
    /// @ignore
    #endregion
    static __get_available_size__ = function() { return height - thumb.height; };
    #region jsDoc
    /// @func    __get_thumb_pos__()
    /// @desc    Returns the thumb position along the track.
    /// @returns {Real} thumb_pos
    /// @ignore
    #endregion
    static __get_thumb_pos__      = function() { return y + (height - thumb.height) * normalized_value; };
    #region jsDoc
    /// @func    __get_thumb_size__()
    /// @desc    Returns the thumb size along the track.
    /// @returns {Real} thumb_size
    /// @ignore
    #endregion
    static __get_thumb_size__     = function() { return thumb.height; };
    #region jsDoc
    /// @func    __get_scroll_origin__()
    /// @desc    Returns the scroll origin (top edge) along the track.
    /// @returns {Real} scroll_origin
    /// @ignore
    #endregion
    static __get_scroll_origin__  = function() { return y; };
    #region jsDoc
    /// @func    __set_thumb_offset__()
    /// @desc    Sets the thumb position along the track.
    /// @param   {Real} pos : New thumb position.
    /// @returns {Undefined}
    /// @ignore
    #endregion
    static __set_thumb_offset__   = function(_pos) { thumb.set_offset(0, _pos); };
    #region jsDoc
    /// @func    __set_thumb_size__()
    /// @desc    Sets the thumb size along the track.
    /// @param   {Real} size : New thumb size.
    /// @returns {Undefined}
    /// @ignore
    #endregion
    static __set_thumb_size__     = function(_size) { thumb.set_size(width, _size); };
}

