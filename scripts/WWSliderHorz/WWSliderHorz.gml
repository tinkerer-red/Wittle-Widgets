#region jsDoc
/// @func    WWSliderHorz()
/// @desc    Horizontal slider (bar grows left->right by default).
/// @returns {Struct.WWSliderHorz}
#endregion
function WWSliderHorz() : WWSliderBase() constructor {
	debug_name = "WWSliderHorz";
	
	on_interact(function(_input) {
		if (width == 0) return;
		var _norm_val;
        if (is_inverted) {
            _norm_val = (x + width - _input.pointer.x) / width;
        } else {
			_norm_val = (_input.pointer.x - x) / width;
		}
		_norm_val = clamp(_norm_val, 0, 1);
				
		set_normalized_value(_norm_val);
    });
	on_post_step(function(_input) {
		var _bar_width = width * normalized_value;
		if (is_inverted) {
            set_bar_size(width - _bar_width, 0, width, height);
        } else {
			set_bar_size(_bar_width, height);
		}
    });
	
}

