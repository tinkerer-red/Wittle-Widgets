#region jsDoc
/// @func    WWSliderVertThumb()
/// @desc    Creates a vertical slider with a draggable thumb.
/// @returns {Struct.WWSliderVertThumb}
#endregion
function WWSliderVertThumb() : WWSliderVert() constructor {
    debug_name = "WWSliderVertThumb";

    thumb = new WWButtonSprite();
	thumb.__theme_sprite_key_main__ = "slider.sprite.thumb.main";
	thumb.__theme_sprite_key_state_prefix__ = "slider.sprite.thumb";
	thumb.__theme_color_prefix__ = "slider.color.thumb";
	thumb.__theme_alpha_prefix__ = "slider.alpha.thumb";

    add(thumb);

	static __ensure_thumb_size__ = function() {
		if (thumb.__size_set__) return;
		var _s = max(1, min(width, height));
		thumb.__set_size__(_s, _s);
	};

    on_post_step(function(_input) {
		__ensure_thumb_size__();
		var _avail = max(1, height - thumb.height);
		var _thumb_y = _avail * (is_inverted ? normalized_value : (1 - normalized_value));
        thumb.set_offset((width - thumb.width) / 2, _thumb_y);
    });

    thumb.on_interact(function(_input) {
		__ensure_thumb_size__();
		var _avail = max(1, height - thumb.height);
		var _rel = _input.pointer.y - y - (thumb.height * 0.5);
        var _norm_val = _rel / _avail;
		if (!is_inverted) _norm_val = 1 - _norm_val;
		_norm_val = clamp(_norm_val, 0, 1);
		set_normalized_value(_norm_val);
    });
}

