#region jsDoc
/// @func    WWSliderVertThumb()
/// @desc    Creates a vertical slider with a draggable thumb.
/// @returns {Struct.WWSliderVertThumb}
#endregion
function WWSliderVertThumb() : WWSliderVert() constructor {
    debug_name = "WWSliderVertThumb";
	
	__thumb_theme_sprite_main__ = "slider.sprite.thumb.main";
	__thumb_theme_sprite_state_prefix__ = "slider.sprite.thumb";
	__thumb_theme_color_prefix__ = "slider.color.thumb";
	__thumb_theme_alpha_prefix__ = "slider.alpha.thumb";
	
	static set_thumb_theme_keys = function(
		_sprite_main = "slider.sprite.thumb.main",
		_sprite_state_prefix = "slider.sprite.thumb",
		_color_prefix = "slider.color.thumb",
		_alpha_prefix = "slider.alpha.thumb"
	) {
		__thumb_theme_sprite_main__ = _sprite_main;
		__thumb_theme_sprite_state_prefix__ = _sprite_state_prefix;
		__thumb_theme_color_prefix__ = _color_prefix;
		__thumb_theme_alpha_prefix__ = _alpha_prefix;
		
		if (is_struct(thumb) && variable_struct_exists(thumb, "set_theme_keys")) {
			thumb.set_theme_keys(
				__thumb_theme_sprite_main__,
				__thumb_theme_sprite_state_prefix__,
				__thumb_theme_color_prefix__,
				__thumb_theme_alpha_prefix__
			);
		}
		return self;
	};

    thumb = new WWButtonSprite();
	thumb.set_theme_keys(
		__thumb_theme_sprite_main__,
		__thumb_theme_sprite_state_prefix__,
		__thumb_theme_color_prefix__,
		__thumb_theme_alpha_prefix__
	);
	thumb.set_navigable(false);

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

