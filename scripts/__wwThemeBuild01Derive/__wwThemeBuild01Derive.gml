function __wwThemeBuild01Derive(_theme, _out) {
	if (!is_struct(_theme)) _theme = {};
	if (!is_struct(_out)) return;

	static __src_get = function(_src, _path) {
		var _v = __wwThemePathGet(_src, _path);
		if (_v == __WW_THEME_PATH_NOT_FOUND) return undefined;
		return _v;
	};

	static __out_set = function(_dst, _path, _value) {
		if (_value == undefined) return;
		__wwThemeSetPath(_dst, _path, _value);
	};

	var _main_color = __src_get(_theme, "main_color");
	if (!is_numeric(_main_color)) {
		_main_color = __src_get(_theme, "color");
	}
	if (!is_numeric(_main_color)) {
		_main_color = __src_get(_theme, "colors.accent.primary.color");
	}
	if (!is_numeric(_main_color)) {
		_main_color = #505050;
	}

	var _accent_color = __src_get(_theme, "accent_color");

	var _accent_color_2 = __src_get(_theme, "accent_color_2");

	var _accent_color_3 = __src_get(_theme, "accent_color_3");

	var _mode = __src_get(_theme, "meta.mode");
	if (!is_string(_mode) || _mode == "") {
		_mode = (__wwColorGetLuma(_main_color) < 0.50) ? "dark" : "light";
	}

	__out_set(_out, "meta.id", __src_get(_theme, "meta.id") ?? "ww_theme_generated");
	__out_set(_out, "meta.name", __src_get(_theme, "meta.name") ?? "Generated Theme");
	__out_set(_out, "meta.mode", string_lower(string(_mode)));
	__out_set(_out, "meta.version", __src_get(_theme, "meta.version") ?? 1);

	__out_set(_out, "derive_input.main_color", _main_color);
	if (is_numeric(_accent_color)) __out_set(_out, "derive_input.accent_color", _accent_color);
	if (is_numeric(_accent_color_2)) __out_set(_out, "derive_input.accent_color_2", _accent_color_2);
	if (is_numeric(_accent_color_3)) __out_set(_out, "derive_input.accent_color_3", _accent_color_3);

	var _fallback_sprite = __src_get(_theme, "fallback.sprite");
	if (_fallback_sprite == undefined) _fallback_sprite = spr_ww_pixel;

	var _fallback_color = __src_get(_theme, "fallback.color");
	if (!is_numeric(_fallback_color)) _fallback_color = #FF00FF;

	var _fallback_alpha = __src_get(_theme, "fallback.alpha");
	if (!is_numeric(_fallback_alpha)) _fallback_alpha = 1;

	var _fallback_size = __src_get(_theme, "fallback.size");
	if (!is_numeric(_fallback_size)) _fallback_size = 0;

	var _fallback_icon = __src_get(_theme, "fallback.icon");
	if (!is_numeric(_fallback_icon)) _fallback_icon = -1;

	var _fallback_font = __src_get(_theme, "fallback.font");
	if (!is_numeric(_fallback_font)) _fallback_font = fnt_ww_default_small_msdf;

	__out_set(_out, "fallback.sprite", _fallback_sprite);
	__out_set(_out, "fallback.color", _fallback_color);
	__out_set(_out, "fallback.alpha", _fallback_alpha);
	__out_set(_out, "fallback.size", _fallback_size);
	__out_set(_out, "fallback.icon", _fallback_icon);
	__out_set(_out, "fallback.font", _fallback_font);
}
