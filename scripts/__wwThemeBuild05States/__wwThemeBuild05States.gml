function __wwThemeBuild05States(_theme, _out) {
	if (!is_struct(_out)) return;

	static __out_get = function(_dst, _path) {
		var _v = __wwThemePathGet(_dst, _path);
		if (_v == __WW_THEME_PATH_NOT_FOUND) return undefined;
		return _v;
	};

	static __set_color_states = function(_dst, _prefix, _base, _hover_delta, _active_delta, _disabled) {
		if (_base == undefined) return;

		var _hover = is_numeric(_base) ? merge_color(_base, c_white, max(0, _hover_delta)) : _base;
		var _active = is_numeric(_base) ? merge_color(_base, c_black, max(0, -_active_delta)) : _base;
		var _nav = _hover;
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
	__set_color_states(_out, "button.color.main", _btn_main, 0.08, -0.10, _txt_disabled);
	__set_alpha_states(_out, "button.alpha.main", __out_get(_out, "button.alpha.main"), 0.45);
	__set_color_states(_out, "button.color.text", _btn_txt, 0.00, -0.00, _txt_disabled);
	__set_alpha_states(_out, "button.alpha.text", __out_get(_out, "button.alpha.text"), 0.55);
	var _btn_sprite_main = __out_get(_out, "button.sprite.main");
	__set_sprite_states(_out, "button.sprite.main", _btn_sprite_main);

	// Button text states
	__set_color_states(_out, "button_text.color.main", __out_get(_out, "button_text.color.main"), 0.08, -0.10, _txt_disabled);
	__set_alpha_states(_out, "button_text.alpha.main", __out_get(_out, "button_text.alpha.main"), 0.45);
	__set_color_states(_out, "button_text.color.text", __out_get(_out, "button_text.color.text"), 0.00, -0.00, _txt_disabled);
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
}
