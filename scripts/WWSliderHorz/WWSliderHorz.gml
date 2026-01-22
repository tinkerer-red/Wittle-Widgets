#region jsDoc
/// @func    WWSliderHorz()
/// @desc    Horizontal slider (bar grows left->right by default).
/// @returns {Struct.WWSliderHorz}
#endregion
function WWSliderHorz() : WWSliderBase() constructor {
	debug_name = "WWSliderHorz";
	
	on_interact(function(_input) {
		var _norm_val;
        if (is_inverted) {
            _norm_val = (x + width - device_mouse_x_to_gui(0)) / width;
        } else {
			_norm_val = (device_mouse_x_to_gui(0) - x) / width;
		}
		_norm_val = clamp(_norm_val, 0, 1);
				
		set_normalized_value(_norm_val);
    });
	on_pre_draw(function(_input) {
		var _bar_width = width * normalized_value;
		if (is_inverted) {
            bar.set_size(width - _bar_width, 0, width, height);
        } else {
			bar.set_size(_bar_width, height);
		}
    });
	
}
