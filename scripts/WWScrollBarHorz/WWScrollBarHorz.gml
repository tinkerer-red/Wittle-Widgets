#region jsDoc
/// @func    WWScrollbarHorz()
/// @desc    Creates a horizontal scrollbar using a slider with a thumb.
/// @returns {Struct.WWScrollbarHorz}
#endregion
function WWScrollbarHorz() : WWScrollbar() constructor {
    debug_name = "WWScrollbarHorz";

    // Overrides
    static __get_mouse_pos__      = function() { return device_mouse_x_to_gui(0); };
    static __get_available_size__ = function() { return width - thumb.width; };
    static __get_thumb_pos__      = function() { return x + (width - thumb.width) * normalized_value; };
    static __get_thumb_size__     = function() { return thumb.width; };
    static __get_scroll_origin__  = function() { return x; };
    static __set_thumb_offset__   = function(_pos) { thumb.set_offset(_pos, 0); };
	static __set_thumb_size__     = function(_size) { thumb.set_size(_size, height); };
}
