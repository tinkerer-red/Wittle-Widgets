function __wwThemeBuild05States(_theme, _out) {
	if (!is_struct(_out)) return;

	static __out_get = function(_dst, _path) {
		var _v = __wwThemePathGet(_dst, _path);
		if (_v == __WW_THEME_PATH_NOT_FOUND) return undefined;
		return _v;
	};

	static __set_color_states = function(_dst, _prefix, _base, _hover_delta, _active_delta, _disabled, _nav_override = undefined, _derive_nav = true) {
		if (_base == undefined) return;

		var _hover = is_numeric(_base) ? merge_color(_base, c_white, max(0, _hover_delta)) : _base;
		var _active = is_numeric(_base) ? merge_color(_base, c_black, max(0, -_active_delta)) : _base;
		var _nav = _hover;
		if (_derive_nav && is_numeric(_base)) {
			// Keep nav distinct from idle/hover, but avoid extreme black/white jumps.
			var _luma = __wwColorGetLuma(_base);
			var _target_luma = (_luma < 0.52)
				? min(0.78, _luma + 0.22)
				: max(0.22, _luma - 0.22);
			_nav = __wwColorSetLuma(_base, _target_luma);
			var _target = (_luma < 0.52) ? c_white : c_black;
			_nav = merge_color(_nav, _target, 0.08);
		}
		if (_nav_override != undefined) {
			_nav = _nav_override;
		}
		var _disabled_v = _disabled;
		if (_disabled_v == undefined) {
			_disabled_v = is_numeric(_base) ? merge_color(_base, c_black, 0.20) : _base;
		}

		__wwThemeSetPath(_dst, _prefix + ".idle", _base);
		__wwThemeSetPath(_dst, _prefix + ".hover", _hover);
		__wwThemeSetPath(_dst, _prefix + ".active", _active);
		__wwThemeSetPath(_dst, _prefix + ".nav", _nav);
		__wwThemeSetPath(_dst, _prefix + ".disabled", _disabled_v);
	};

	static __set_alpha_states = function(_dst, _prefix, _base, _disabled_alpha) {
		if (!is_numeric(_base)) return;
		__wwThemeSetPath(_dst, _prefix + ".idle", _base);
		__wwThemeSetPath(_dst, _prefix + ".hover", _base);
		__wwThemeSetPath(_dst, _prefix + ".active", _base);
		__wwThemeSetPath(_dst, _prefix + ".nav", _base);
		__wwThemeSetPath(_dst, _prefix + ".disabled", _disabled_alpha);
	};

	static __set_sprite_states = function(_dst, _prefix, _main_sprite) {
		if (_main_sprite == undefined) return;
		__wwThemeSetPath(_dst, _prefix + ".idle", _main_sprite);
		__wwThemeSetPath(_dst, _prefix + ".hover", _main_sprite);
		__wwThemeSetPath(_dst, _prefix + ".active", _main_sprite);
		__wwThemeSetPath(_dst, _prefix + ".nav", _main_sprite);
		__wwThemeSetPath(_dst, _prefix + ".disabled", _main_sprite);
	};

	// Button states
	var _btn_main = __out_get(_out, "button.color.main");
	var _btn_txt = __out_get(_out, "button.color.text");
	var _txt_disabled = __out_get(_out, "colors.text.disabled.color");
	var _btn_nav_main = __out_get(_out, "button.color.main.nav");
	if (_btn_nav_main == undefined) {
		_btn_nav_main = _btn_main;
		if (is_numeric(_btn_main)) {
			var _btn_main_luma = __wwColorGetLuma(_btn_main);
			var _btn_main_target_luma = (_btn_main_luma < 0.52)
				? min(0.78, _btn_main_luma + 0.22)
				: max(0.22, _btn_main_luma - 0.22);
			_btn_nav_main = __wwColorSetLuma(_btn_main, _btn_main_target_luma);
			var _btn_main_target = (_btn_main_luma < 0.52) ? c_white : c_black;
			_btn_nav_main = merge_color(_btn_nav_main, _btn_main_target, 0.08);
		}
	}
	__set_color_states(_out, "button.color.main", _btn_main, 0.08, -0.10, _txt_disabled, _btn_nav_main, true);
	__set_alpha_states(_out, "button.alpha.main", __out_get(_out, "button.alpha.main"), 0.45);
	var _btn_txt_nav = _btn_txt;
	if (is_numeric(_btn_nav_main)) {
		var _n0 = __out_get(_out, "palette.n0");
		var _n100 = __out_get(_out, "palette.n100");
		if (!is_numeric(_n0)) _n0 = c_black;
		if (!is_numeric(_n100)) _n100 = c_white;
		_btn_txt_nav = (__wwColorGetLuma(_btn_nav_main) >= 0.55) ? _n0 : _n100;
	}
	__set_color_states(_out, "button.color.text", _btn_txt, 0.00, -0.00, _txt_disabled, _btn_txt_nav, false);
	__set_alpha_states(_out, "button.alpha.text", __out_get(_out, "button.alpha.text"), 0.55);
	var _btn_sprite_main = __out_get(_out, "button.sprite.main");
	__set_sprite_states(_out, "button.sprite.main", _btn_sprite_main);

	// Button text states
	var _btn_text_main = __out_get(_out, "button_text.color.main");
	var _btn_text_nav_main = __out_get(_out, "button_text.color.main.nav");
	if (_btn_text_nav_main == undefined) {
		_btn_text_nav_main = _btn_text_main;
		if (is_numeric(_btn_text_main)) {
			var _btn_text_main_luma = __wwColorGetLuma(_btn_text_main);
			var _btn_text_main_target_luma = (_btn_text_main_luma < 0.52)
				? min(0.78, _btn_text_main_luma + 0.22)
				: max(0.22, _btn_text_main_luma - 0.22);
			_btn_text_nav_main = __wwColorSetLuma(_btn_text_main, _btn_text_main_target_luma);
			var _btn_text_main_target = (_btn_text_main_luma < 0.52) ? c_white : c_black;
			_btn_text_nav_main = merge_color(_btn_text_nav_main, _btn_text_main_target, 0.08);
		}
	}
	__set_color_states(_out, "button_text.color.main", _btn_text_main, 0.08, -0.10, _txt_disabled, _btn_text_nav_main, true);
	__set_alpha_states(_out, "button_text.alpha.main", __out_get(_out, "button_text.alpha.main"), 0.45);
	var _btn_text_txt = __out_get(_out, "button_text.color.text");
	var _btn_text_txt_nav = _btn_text_txt;
	if (is_numeric(_btn_text_nav_main)) {
		var _btn_text_n0 = __out_get(_out, "palette.n0");
		var _btn_text_n100 = __out_get(_out, "palette.n100");
		if (!is_numeric(_btn_text_n0)) _btn_text_n0 = c_black;
		if (!is_numeric(_btn_text_n100)) _btn_text_n100 = c_white;
		_btn_text_txt_nav = (__wwColorGetLuma(_btn_text_nav_main) >= 0.55) ? _btn_text_n0 : _btn_text_n100;
	}
	__set_color_states(_out, "button_text.color.text", _btn_text_txt, 0.00, -0.00, _txt_disabled, _btn_text_txt_nav, false);
	__set_alpha_states(_out, "button_text.alpha.text", __out_get(_out, "button_text.alpha.text"), 0.55);
	var _btn_text_sprite_main = __out_get(_out, "button_text.sprite.main");
	__set_sprite_states(_out, "button_text.sprite.main", _btn_text_sprite_main);

	// Slider states
	__set_color_states(_out, "slider.color.track", __out_get(_out, "slider.color.track"), 0.05, -0.05, undefined);
	__set_alpha_states(_out, "slider.alpha.track", __out_get(_out, "slider.alpha.track"), 0.55);
	__set_color_states(_out, "slider.color.fill", __out_get(_out, "slider.color.fill"), 0.04, -0.08, undefined);
	__set_alpha_states(_out, "slider.alpha.fill", __out_get(_out, "slider.alpha.fill"), 0.55);
	__set_color_states(_out, "slider.color.thumb", __out_get(_out, "slider.color.thumb"), 0.08, -0.10, undefined);
	__set_alpha_states(_out, "slider.alpha.thumb", __out_get(_out, "slider.alpha.thumb"), 0.55);
	var _slider_track_main = __out_get(_out, "slider.sprite.track.main");
	var _slider_fill_main = __out_get(_out, "slider.sprite.fill.main");
	var _slider_thumb_main = __out_get(_out, "slider.sprite.thumb.main");
	__set_sprite_states(_out, "slider.sprite.track", _slider_track_main);
	__set_sprite_states(_out, "slider.sprite.fill", _slider_fill_main);
	__set_sprite_states(_out, "slider.sprite.thumb", _slider_thumb_main);

	// Scrollbar tray/gutter/trough/thumb states
	__set_color_states(_out, "scrollbar.color.tray", __out_get(_out, "scrollbar.color.tray"), 0.02, -0.03, undefined);
	__set_alpha_states(_out, "scrollbar.alpha.tray", __out_get(_out, "scrollbar.alpha.tray"), 0.55);
	__set_color_states(_out, "scrollbar.color.gutter", __out_get(_out, "scrollbar.color.gutter"), 0.02, -0.03, undefined);
	__set_alpha_states(_out, "scrollbar.alpha.gutter", __out_get(_out, "scrollbar.alpha.gutter"), 0.55);
	__set_color_states(_out, "scrollbar.color.trough", __out_get(_out, "scrollbar.color.trough"), 0.02, -0.03, undefined);
	__set_alpha_states(_out, "scrollbar.alpha.trough", __out_get(_out, "scrollbar.alpha.trough"), 0.55);
	__set_color_states(_out, "scrollbar.color.thumb", __out_get(_out, "scrollbar.color.thumb"), 0.08, -0.08, undefined);
	__set_alpha_states(_out, "scrollbar.alpha.thumb", __out_get(_out, "scrollbar.alpha.thumb"), 0.45);
	var _scrollbar_tray_main = __out_get(_out, "scrollbar.sprite.tray.main");
	var _scrollbar_gutter_main = __out_get(_out, "scrollbar.sprite.gutter.main");
	var _scrollbar_trough_main = __out_get(_out, "scrollbar.sprite.trough.main");
	var _scrollbar_thumb_main = __out_get(_out, "scrollbar.sprite.thumb.main");
	__set_sprite_states(_out, "scrollbar.sprite.tray", _scrollbar_tray_main);
	__set_sprite_states(_out, "scrollbar.sprite.gutter", _scrollbar_gutter_main);
	__set_sprite_states(_out, "scrollbar.sprite.trough", _scrollbar_trough_main);
	__set_sprite_states(_out, "scrollbar.sprite.thumb", _scrollbar_thumb_main);

	// Scrollbar direction button states
	var _dirs = ["left", "right", "up", "down"];
	for (var _i = 0; _i < array_length(_dirs); _i++) {
		var _dir = _dirs[_i];
		var _c_prefix = "scrollbar.color.button." + _dir;
		var _a_prefix = "scrollbar.alpha.button." + _dir;
		var _s_prefix = "scrollbar.sprite.button." + _dir;
		__set_color_states(_out, _c_prefix, __out_get(_out, _c_prefix), 0.08, -0.08, undefined);
		__set_alpha_states(_out, _a_prefix, __out_get(_out, _a_prefix), 0.45);
		var _dir_sprite_main = __out_get(_out, _s_prefix + ".main");
		__set_sprite_states(_out, _s_prefix, _dir_sprite_main);
	}

	// Container roles (canvas/frame/panel/inset/container):
	// keep hover/active equal to idle (no button-like hover) but make NAV distinctly visible.
	var _roles = ["canvas", "frame", "panel", "inset", "container"];
	var _nav_border = __out_get(_out, "colors.accent.primary.color");
	for (var _ri = 0; _ri < array_length(_roles); _ri++) {
		var _role = _roles[_ri];
		var _fill_prefix = _role + ".color.main";
		var _fill_base = __out_get(_out, _fill_prefix);
		var _fill_nav = __out_get(_out, _fill_prefix + ".nav");
		if (_fill_nav == undefined) {
			_fill_nav = _fill_base;
			if (is_numeric(_fill_base)) {
				var _fill_luma = __wwColorGetLuma(_fill_base);
				var _fill_target_luma = (_fill_luma < 0.52)
					? min(0.78, _fill_luma + 0.22)
					: max(0.22, _fill_luma - 0.22);
				_fill_nav = __wwColorSetLuma(_fill_base, _fill_target_luma);
				var _fill_target = (_fill_luma < 0.52) ? c_white : c_black;
				_fill_nav = merge_color(_fill_nav, _fill_target, 0.08);
			}
		}
		__set_color_states(_out, _fill_prefix, _fill_base, 0.00, -0.00, undefined, _fill_nav, true);
		__set_alpha_states(_out, _role + ".alpha.main", __out_get(_out, _role + ".alpha.main"), 0.55);
		var _border_prefix = _role + ".color.border";
		var _border_base = __out_get(_out, _border_prefix);
		var _border_nav = __out_get(_out, _border_prefix + ".nav");
		if (_border_nav == undefined) {
			_border_nav = _nav_border;
			if (_border_nav == undefined) {
				_border_nav = _border_base;
				if (is_numeric(_border_base)) {
					var _border_luma = __wwColorGetLuma(_border_base);
					var _border_target_luma = (_border_luma < 0.52)
						? min(0.78, _border_luma + 0.22)
						: max(0.22, _border_luma - 0.22);
					_border_nav = __wwColorSetLuma(_border_base, _border_target_luma);
					var _border_target = (_border_luma < 0.52) ? c_white : c_black;
					_border_nav = merge_color(_border_nav, _border_target, 0.08);
				}
			}
		}
		__set_color_states(_out, _border_prefix, _border_base, 0.00, -0.00, undefined, _border_nav, false);
		__set_alpha_states(_out, _role + ".alpha.border", __out_get(_out, _role + ".alpha.border"), 0.55);
		__set_sprite_states(_out, _role + ".sprite.main", __out_get(_out, _role + ".sprite.main"));
	}
}
