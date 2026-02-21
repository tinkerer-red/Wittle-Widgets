function __wwThemeBuild02Palette(_theme, _out) {
	if (!is_struct(_theme)) _theme = {};
	if (!is_struct(_out)) return;

	static __src_get = function(_src, _path) {
		var _v = __wwThemePathGet(_src, _path);
		if (_v == __WW_THEME_PATH_NOT_FOUND) return undefined;
		return _v;
	};

	static __out_get = function(_dst, _path) {
		var _v = __wwThemePathGet(_dst, _path);
		if (_v == __WW_THEME_PATH_NOT_FOUND) return undefined;
		return _v;
	};

	static __out_set = function(_dst, _path, _value) {
		if (_value == undefined) return;
		__wwThemeSetPath(_dst, _path, _value);
	};

	static __is_neutralish = function(_color, _margin = 5) {
		if (!is_numeric(_color)) return false;
		var _r = color_get_red(_color);
		var _g = color_get_green(_color);
		var _b = color_get_blue(_color);
		return (abs(_r - _g) <= _margin)
			&& (abs(_g - _b) <= _margin)
			&& (abs(_r - _b) <= _margin);
	};

	static __rgb_add = function(_color, _dr, _dg, _db) {
		var _r = clamp(color_get_red(_color) + _dr, 0, 255);
		var _g = clamp(color_get_green(_color) + _dg, 0, 255);
		var _b = clamp(color_get_blue(_color) + _db, 0, 255);
		return make_color_rgb(_r, _g, _b);
	};

	var _main = __out_get(_out, "derive_input.main_color");
	var _a1 = __out_get(_out, "derive_input.accent_color");
	var _a2 = __out_get(_out, "derive_input.accent_color_2");
	var _a3 = __out_get(_out, "derive_input.accent_color_3");
	var _mode = __out_get(_out, "meta.mode");

	if (!is_numeric(_a1)) _a1 = __src_get(_theme, "accent_color");
	if (!is_numeric(_a2)) _a2 = __src_get(_theme, "accent_color_2");
	if (!is_numeric(_a3)) _a3 = __src_get(_theme, "accent_color_3");

	if (!is_numeric(_main)) _main = #505050;
	var _a1_missing = !is_numeric(_a1);
	var _a2_missing = !is_numeric(_a2);
	var _a3_missing = !is_numeric(_a3);
	var _main_is_neutral = __is_neutralish(_main, 5);
	if (!is_string(_mode) || _mode == "") {
		_mode = (__wwColorGetLuma(_main) < 0.50) ? "dark" : "light";
	}

	// Keep mono themes proportional in dark mode:
	// derive accents from the same HSV distance-from-floor profile instead of hard white mixes.
	if (_a1_missing) {
		if (_mode == "dark") {
			if (_main_is_neutral) {
				_a1 = __rgb_add(_main, 6, 6, 6);
			}
			else {
				var _mh = color_get_hue(_main) / 255;
				var _ms = color_get_saturation(_main) / 255;
				var _mv = color_get_value(_main) / 255;
				var _s_floor = 0.10;
				var _v_floor = 0.10;
				var _ds = max(0, _ms - _s_floor);
				var _dv = max(0, _mv - _v_floor);
				var _a1_s = clamp(_s_floor + (_ds * 0.90), 0.20, 0.78);
				var _a1_v = clamp(_v_floor + (_dv * 1.05), 0.20, 0.62);
				_a1 = make_color_hsv(round(_mh * 255), round(_a1_s * 255), round(_a1_v * 255));
			}
		}
		else {
			if (_main_is_neutral) {
				// For light mono-neutral seeds, accent should stay neutral and slightly darker
				// so important controls stand out without introducing color.
				_a1 = __rgb_add(_main, -12, -12, -12);
			}
			else {
				_a1 = merge_color(_main, c_white, 0.20);
			}
		}
	}

	var _a1_h = color_get_hue(_a1) / 255;
	var _a1_s2 = color_get_saturation(_a1) / 255;
	var _a1_v2 = color_get_value(_a1) / 255;

	if (_a2_missing) {
		if (_mode == "dark") {
			if (_main_is_neutral) {
				// Slight cool lift used for selection/nav accent in mono-neutral themes.
				_a2 = __rgb_add(_main, 6, 10, 18);
			}
			else {
				var _a2_h = _a1_h + (8 / 255);
				if (_a2_h > 1) _a2_h -= 1;
				var _a2_s_norm = clamp(_a1_s2 * 0.92, 0.18, 0.72);
				var _a2_v_norm = clamp(_a1_v2 + 0.06, 0.24, 0.68);
				_a2 = make_color_hsv(round(_a2_h * 255), round(_a2_s_norm * 255), round(_a2_v_norm * 255));
			}
		}
		else {
			if (_main_is_neutral) {
				// Preserve neutral channel balance for light mono-neutral themes.
				_a2 = __rgb_add(_main, -20, -20, -20);
			}
			else {
				_a2 = merge_color(_a1, c_white, 0.12);
			}
		}
	}

	if (_a3_missing) {
		if (_mode == "dark") {
			if (_main_is_neutral) {
				// Stronger cool edge used rarely (focused/active edges).
				_a3 = __rgb_add(_main, 23, 31, 39);
			}
			else {
				var _a3_h = _a1_h - (10 / 255);
				if (_a3_h < 0) _a3_h += 1;
				var _a3_s_norm = clamp(_a1_s2 * 0.88, 0.16, 0.70);
				var _a3_v_norm = clamp(_a1_v2 + 0.10, 0.28, 0.72);
				_a3 = make_color_hsv(round(_a3_h * 255), round(_a3_s_norm * 255), round(_a3_v_norm * 255));
			}
		}
		else {
			if (_main_is_neutral) {
				// Rare stronger edge for active/strong outline in light neutral themes.
				_a3 = __rgb_add(_main, -32, -32, -32);
			}
			else {
				_a3 = merge_color(_a1, c_white, 0.22);
			}
		}
	}

	var _defaults = {};
	if (_mode == "dark") {
		if (_main_is_neutral) {
			// Keep mono-neutral dark themes in the same gray edge-space as the seed.
			// For #393939 this lands close to GM dark sampled ranges.
			_defaults.n0 = __rgb_add(_main, -27, -27, -27);
			_defaults.n5 = __rgb_add(_main, -24, -24, -24);
			_defaults.n10 = __rgb_add(_main, -23, -23, -23);
			_defaults.n20 = __rgb_add(_main, -18, -18, -18);
			_defaults.n30 = __rgb_add(_main, -11, -11, -11);
			_defaults.n40 = __rgb_add(_main, -3, -3, -3);
			_defaults.n70 = __rgb_add(_main, 95, 95, 95);
			_defaults.n90 = __rgb_add(_main, 180, 180, 180);
			_defaults.n100 = c_white;
		}
		else {
			_defaults.n0 = merge_color(_main, c_black, 0.88);
			_defaults.n5 = merge_color(_main, c_black, 0.80);
			_defaults.n10 = merge_color(_main, c_black, 0.70);
			_defaults.n20 = merge_color(_main, c_black, 0.55);
			_defaults.n30 = merge_color(_main, c_black, 0.35);
			_defaults.n40 = merge_color(_main, c_white, 0.18);
			_defaults.n70 = merge_color(_main, c_white, 0.62);
			_defaults.n90 = merge_color(_main, c_white, 0.86);
			_defaults.n100 = c_white;
		}
	}
	else {
		if (_main_is_neutral) {
			// Light mono-neutral ramp tuned to resemble practical IDE light ramps:
			// bright large surfaces, darker readable text ladder, neutral controls.
			_defaults.n0 = __rgb_add(_main, -212, -212, -212);
			_defaults.n5 = __rgb_add(_main, -160, -160, -160);
			_defaults.n10 = __rgb_add(_main, -142, -142, -142);
			_defaults.n20 = __rgb_add(_main, -122, -122, -122);
			_defaults.n30 = __rgb_add(_main, -96, -96, -96);
			_defaults.n40 = __rgb_add(_main, -74, -74, -74);
			_defaults.n70 = __rgb_add(_main, -12, -12, -12);
			_defaults.n90 = _main;
			_defaults.n100 = __rgb_add(_main, 26, 26, 26);
		}
		else {
			_defaults.n0 = merge_color(_main, c_black, 0.92);
			_defaults.n5 = merge_color(_main, c_black, 0.80);
			_defaults.n10 = merge_color(_main, c_black, 0.65);
			_defaults.n20 = merge_color(_main, c_black, 0.45);
			_defaults.n30 = merge_color(_main, c_black, 0.25);
			_defaults.n40 = merge_color(_main, c_black, 0.12);
			_defaults.n70 = merge_color(_main, c_white, 0.52);
			_defaults.n90 = merge_color(_main, c_white, 0.86);
			_defaults.n100 = c_white;
		}
	}

	var _primary_accent = _a1;
	if (!_a2_missing && _a3_missing) {
		_primary_accent = merge_color(_a1, _a2, 0.45);
	}
	else if (!_a2_missing && !_a3_missing) {
		_primary_accent = merge_color(merge_color(_a1, _a2, 0.40), _a3, 0.28);
	}

	var _secondary_accent = _a2_missing
		? (
			_main_is_neutral
				? ((_mode == "dark") ? #039D5B : __rgb_add(_main, -42, -42, -42))
				: merge_color(_a1, make_color_rgb(0, 220, 120), 0.50)
		)
		: _a2;

	var _tertiary_accent = _a3_missing
		? (
			_main_is_neutral
				? ((_mode == "dark") ? #4E453F : __rgb_add(_main, -52, -52, -52))
				: merge_color(_a1, make_color_rgb(255, 140, 0), 0.35)
		)
		: _a3;

	_defaults.blue = _primary_accent;
	_defaults.green = _secondary_accent;
	if (_main_is_neutral) {
		if (_mode == "dark") {
			_defaults.yellow = #4E453F;
			_defaults.orange = #4E453F;
			_defaults.red = #4E453F;
			_defaults.purple = _a2;
		}
		else {
			_defaults.yellow = __rgb_add(_main, -22, -22, -22);
			_defaults.orange = __rgb_add(_main, -28, -28, -28);
			_defaults.red = __rgb_add(_main, -34, -34, -34);
			_defaults.purple = __rgb_add(_main, -26, -26, -26);
		}
	}
	else {
		_defaults.yellow = merge_color(_secondary_accent, _tertiary_accent, 0.50);
		_defaults.orange = _tertiary_accent;
		_defaults.red = merge_color(_main, make_color_rgb(220, 40, 40), 0.55);
		_defaults.purple = merge_color(_secondary_accent, make_color_rgb(160, 80, 240), 0.55);
	}

	var _keys = [
		"n0","n5","n10","n20","n30","n40","n70","n90","n100",
		"blue","green","yellow","orange","red","purple"
	];

	for (var _i = 0; _i < array_length(_keys); _i++) {
		var _k = _keys[_i];
		var _v = __src_get(_theme, "palette." + _k);
		if (!is_numeric(_v)) _v = variable_struct_get(_defaults, _k);
		__out_set(_out, "palette." + _k, _v);
	}
}
