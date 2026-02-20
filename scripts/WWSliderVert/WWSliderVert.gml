#region jsDoc
/// @func    WWSliderVert()
/// @desc    Vertical slider (bar grows bottom->top by default).
/// @returns {Struct.WWSliderVert}
#endregion
function WWSliderVert() : WWSliderBase() constructor {
	debug_name = "WWSliderVert";
	
	on_interact(function(_input) {
		if (height == 0) return;
		var _norm_val;
		if (is_inverted) {
            _norm_val = (_input.pointer.y - y) / height;
        } else {
            _norm_val = (y + height - _input.pointer.y) / height;
        }
		
		_norm_val = clamp(_norm_val, 0, 1);
				
		set_normalized_value(_norm_val);
    });
	on_post_step(function(_input) {
		var _bar_height = height * normalized_value;
		if (is_inverted) {
            set_bar_size(width, _bar_height);
        } else {
            set_bar_size(0, height - _bar_height, width, height);
        }
    });
}

