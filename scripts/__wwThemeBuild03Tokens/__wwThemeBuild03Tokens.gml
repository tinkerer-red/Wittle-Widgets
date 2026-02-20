function __wwThemeBuild03Tokens(_theme, _out) {
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

	static __token_set = function(_src, _dst, _path, _default_color, _default_alpha) {
		var _raw = __wwThemePathGet(_src, _path);
		if (_raw == __WW_THEME_PATH_NOT_FOUND) _raw = undefined;

		var _c = undefined;
		var _a = undefined;
		if (is_struct(_raw)) {
			if (variable_struct_exists(_raw, "color")) _c = _raw.color;
			if (variable_struct_exists(_raw, "alpha")) _a = _raw.alpha;
		}
		else if (is_numeric(_raw)) {
			_c = _raw;
		}

		if (_c == undefined) _c = _default_color;
		if (_a == undefined) _a = _default_alpha;

		__wwThemeSetPath(_dst, _path + ".color", _c);
		__wwThemeSetPath(_dst, _path + ".alpha", _a);
	};

	var _mode = __out_get(_out, "meta.mode");
	var p = {
		n0: __out_get(_out, "palette.n0"),
		n5: __out_get(_out, "palette.n5"),
		n10: __out_get(_out, "palette.n10"),
		n20: __out_get(_out, "palette.n20"),
		n30: __out_get(_out, "palette.n30"),
		n40: __out_get(_out, "palette.n40"),
		n70: __out_get(_out, "palette.n70"),
		n90: __out_get(_out, "palette.n90"),
		n100: __out_get(_out, "palette.n100"),
		blue: __out_get(_out, "palette.blue"),
		green: __out_get(_out, "palette.green"),
		yellow: __out_get(_out, "palette.yellow"),
		orange: __out_get(_out, "palette.orange"),
		red: __out_get(_out, "palette.red"),
		purple: __out_get(_out, "palette.purple")
	};

	if (_mode == "dark") {
		__token_set(_theme, _out, "colors.app.bg", p.n0, 1);
		__token_set(_theme, _out, "colors.app.bg_alt", p.n5, 1);
		__token_set(_theme, _out, "colors.surface.panel", p.n5, 1);
		__token_set(_theme, _out, "colors.surface.panel_alt", p.n10, 1);
		__token_set(_theme, _out, "colors.surface.control", p.n10, 1);
		__token_set(_theme, _out, "colors.surface.control_alt", p.n20, 1);
		__token_set(_theme, _out, "colors.surface.popup", p.n5, 1);
		__token_set(_theme, _out, "colors.surface.tooltip", p.n5, 0.93);
		__token_set(_theme, _out, "colors.text.primary", p.n90, 1);
		__token_set(_theme, _out, "colors.text.secondary", p.n70, 1);
		__token_set(_theme, _out, "colors.text.dim", p.n40, 1);
		__token_set(_theme, _out, "colors.text.disabled", p.n30, 1);
		__token_set(_theme, _out, "colors.text.inverse", p.n0, 1);
		__token_set(_theme, _out, "colors.overlay.modal_shade", c_black, 0.50);
	}
	else {
		__token_set(_theme, _out, "colors.app.bg", p.n90, 1);
		__token_set(_theme, _out, "colors.app.bg_alt", p.n100, 1);
		__token_set(_theme, _out, "colors.surface.panel", p.n100, 1);
		__token_set(_theme, _out, "colors.surface.panel_alt", p.n90, 1);
		__token_set(_theme, _out, "colors.surface.control", p.n100, 1);
		__token_set(_theme, _out, "colors.surface.control_alt", merge_color(p.n90, p.n70, 0.25), 1);
		__token_set(_theme, _out, "colors.surface.popup", p.n100, 1);
		__token_set(_theme, _out, "colors.surface.tooltip", p.n100, 0.95);
		__token_set(_theme, _out, "colors.text.primary", p.n0, 1);
		__token_set(_theme, _out, "colors.text.secondary", p.n20, 1);
		__token_set(_theme, _out, "colors.text.dim", p.n40, 1);
		__token_set(_theme, _out, "colors.text.disabled", p.n40, 1);
		__token_set(_theme, _out, "colors.text.inverse", p.n100, 1);
		__token_set(_theme, _out, "colors.overlay.modal_shade", c_black, 0.30);
	}

	__token_set(_theme, _out, "colors.outline.subtle", (_mode == "dark") ? p.n20 : merge_color(p.n70, p.n90, 0.30), 1);
	__token_set(_theme, _out, "colors.outline.normal", (_mode == "dark") ? p.n30 : p.n70, 1);
	__token_set(_theme, _out, "colors.outline.strong", (_mode == "dark") ? p.n40 : p.n40, 1);

	__token_set(_theme, _out, "colors.accent.primary", p.blue, 1);
	__token_set(_theme, _out, "colors.accent.on_accent", (__wwColorGetLuma(p.blue) >= 0.55) ? p.n0 : p.n100, 1);
	__token_set(_theme, _out, "colors.accent.subtle", p.blue, (_mode == "dark") ? 0.30 : 0.20);
	__token_set(_theme, _out, "colors.text.link", p.blue, 1);

	__token_set(_theme, _out, "colors.state.focus_ring", p.blue, (_mode == "dark") ? 0.80 : 0.60);
	__token_set(_theme, _out, "colors.state.selection_bg", p.blue, (_mode == "dark") ? 0.40 : 0.20);
	__token_set(_theme, _out, "colors.state.selection_text", (_mode == "dark") ? p.n100 : p.n0, 1);
	__token_set(_theme, _out, "colors.state.success_fg", p.green, 1);
	__token_set(_theme, _out, "colors.state.success_bg", p.green, 0.20);
	__token_set(_theme, _out, "colors.state.warning_fg", p.yellow, 1);
	__token_set(_theme, _out, "colors.state.warning_bg", p.yellow, 0.20);
	__token_set(_theme, _out, "colors.state.danger_fg", p.red, 1);
	__token_set(_theme, _out, "colors.state.danger_bg", p.red, 0.20);

	var _tr_font = __src_get(_theme, "text_renderer.font.main");
	if (!is_numeric(_tr_font)) _tr_font = __out_get(_out, "fallback.font");
	__out_set(_out, "text_renderer.font.main", _tr_font);

	var _tr_code_font = __src_get(_theme, "text_renderer.font.code");
	if (!is_numeric(_tr_code_font)) _tr_code_font = _tr_font;
	__out_set(_out, "text_renderer.font.code", _tr_code_font);

	var _tr_color = __src_get(_theme, "text_renderer.color.main");
	if (!is_numeric(_tr_color)) _tr_color = __out_get(_out, "colors.text.primary.color");
	__out_set(_out, "text_renderer.color.main", _tr_color);

	var _tr_alpha = __src_get(_theme, "text_renderer.alpha.main");
	if (!is_numeric(_tr_alpha)) _tr_alpha = __out_get(_out, "colors.text.primary.alpha");
	__out_set(_out, "text_renderer.alpha.main", _tr_alpha);
}
