#region jsDoc
/// @func    WWSliderVert()
/// @desc    Vertical slider (bar grows bottom->top by default).
/// @returns {Struct.WWSliderVert}
#endregion
function WWSliderVert() : WWSliderBase() constructor {
	debug_name = "WWSliderVert";
	
	on_interact(function(_input) {
		var _norm_val;
		if (is_inverted) {
            _norm_val = (device_mouse_y_to_gui(0) - y) / height;
        } else {
            _norm_val = (y + height - device_mouse_y_to_gui(0)) / height;
        }
		
		_norm_val = clamp(_norm_val, 0, 1);
				
		set_normalized_value(_norm_val);
    });
	on_pre_draw(function(_input) {
		var _bar_height = height * normalized_value;
		if (is_inverted) {
            bar.set_size(width, _bar_height);
        } else {
            bar.set_size(0, height - _bar_height, width, height);
        }
    });
}
