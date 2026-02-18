#region jsDoc
/// @func    WWSliderVertThumb()
/// @desc    Creates a vertical slider with a draggable thumb.
/// @returns {Struct.WWSliderVertThumb}
#endregion
function WWSliderVertThumb() : WWSliderVert() constructor {
    debug_name = "WWSliderVertThumb";

    thumb = new WWSliderThumb()
        .set_sprite(undefined)
        .set_sprite_color(c_white)
        .set_size(16, 16);

    add(thumb);

    on_post_step(function(_input) {
        var _thumb_y;
        if (is_inverted) {
            _thumb_y = height * normalized_value - thumb.height / 2;
        } else {
            _thumb_y = height * (1 - normalized_value) - thumb.height / 2;
        }
        thumb.set_offset((width - thumb.width) / 2, _thumb_y);
    });

    thumb.on_interact(function(_input) {
        var _norm_val;
		if (is_inverted) {
            _norm_val = (device_mouse_y_to_gui(0) - y) / height;
        } else {
            _norm_val = (y+height - device_mouse_y_to_gui(0)) / height;
        }
		
		_norm_val = clamp(_norm_val, 0, 1);
		set_normalized_value(_norm_val);
    });
}
