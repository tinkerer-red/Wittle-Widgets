#region jsDoc
/// @func    WWScrollbarVert()
/// @desc    Creates a vertical scrollbar using a slider with a thumb.
/// @returns {Struct.WWScrollbarVert}
#endregion
function WWScrollbarVert() : WWScrollbar() constructor {
    debug_name = "WWScrollbarVert";

    // Overrides
    static __get_mouse_pos__      = function() { return device_mouse_y_to_gui(0); };
    static __get_available_size__ = function() { return height - thumb.height; };
    static __get_thumb_pos__      = function() { return y + (height - thumb.height) * normalized_value; };
    static __get_thumb_size__     = function() { return thumb.height; };
    static __get_scroll_origin__  = function() { return y; };
    static __set_thumb_offset__   = function(_pos) { thumb.set_offset(0, _pos); };
	static __set_thumb_size__     = function(_size) { thumb.set_size(width, _size); };
}

