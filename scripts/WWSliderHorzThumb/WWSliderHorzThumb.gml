#region jsDoc
/// @func    WWSliderHorzThumb()
/// @desc    Creates a horizontal slider with a draggable thumb.
/// @param   {Real} x : The x position of the component on screen.
/// @param   {Real} y : The y position of the component on screen.
/// @returns {Struct.WWSliderHorzThumb}
#endregion
function WWSliderHorzThumb() : WWSliderHorz() constructor {
    debug_name = "WWSliderHorzThumb";

    thumb = new WWSliderThumb()
        .set_sprite(spr_ww_pixel)
        .set_sprite_color(c_white)
        .set_size(16, 16);

    add(thumb);

    on_post_step(function(_input) {
		var _thumb_x;
		if (is_inverted) {
			_thumb_x = width * (1 - normalized_value) - thumb.width / 2;
		} else {
			_thumb_x = width * normalized_value - thumb.width / 2;
		}
		thumb.set_offset(_thumb_x, (height - thumb.height) / 2);
    });

    thumb.on_interact(function(_input) {
        var _norm_val;
        if (is_inverted) {
            _norm_val = (x + width - device_mouse_x_to_gui(0)) / width;
        } else {
            _norm_val = (device_mouse_x_to_gui(0) - x) / width;
        }
        _norm_val = clamp(_norm_val, 0, 1);
        set_normalized_value(_norm_val);
    });
}
