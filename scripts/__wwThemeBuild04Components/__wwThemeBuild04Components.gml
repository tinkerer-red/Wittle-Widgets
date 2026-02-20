function __wwThemeBuild04Components(_theme, _out) {
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

	static __pick_from_src = function(_src, _src_path, _fallback_value) {
		var _v = __wwThemePathGet(_src, _src_path);
		if (_v == __WW_THEME_PATH_NOT_FOUND) _v = undefined;
		if (_v != undefined) return _v;
		return _fallback_value;
	};

	var _surface_panel = __out_get(_out, "colors.surface.panel.color");
	var _surface_panel_alt = __out_get(_out, "colors.surface.panel_alt.color");
	var _surface_control = __out_get(_out, "colors.surface.control.color");
	var _surface_control_alt = __out_get(_out, "colors.surface.control_alt.color");
	var _outline_subtle = __out_get(_out, "colors.outline.subtle.color");
	var _outline_normal = __out_get(_out, "colors.outline.normal.color");
	var _outline_strong = __out_get(_out, "colors.outline.strong.color");
	var _text_primary = __out_get(_out, "colors.text.primary.color");
	var _text_dim = __out_get(_out, "colors.text.dim.color");
	var _text_disabled = __out_get(_out, "colors.text.disabled.color");
	var _accent = __out_get(_out, "colors.accent.primary.color");
	var _on_accent = __out_get(_out, "colors.accent.on_accent.color");

	var _alpha1 = 1;
	var _disabled_alpha = 0.45;

	var _fallback_sprite = __out_get(_out, "fallback.sprite");

	var _button_sprite = __src_get(_theme, "button.sprite.main");
	if (_button_sprite == undefined) _button_sprite = spr_ww_rr9_r4_all;

	var _button_text_sprite = __src_get(_theme, "button_text.sprite.main");
	if (_button_text_sprite == undefined) _button_text_sprite = spr_ww_rr9_r4_all;

	var _slider_track_sprite = __src_get(_theme, "slider.sprite.track.main");
	if (_slider_track_sprite == undefined) _slider_track_sprite = spr_ww_slider_background;

	var _slider_fill_sprite = __src_get(_theme, "slider.sprite.fill.main");
	if (_slider_fill_sprite == undefined) _slider_fill_sprite = spr_ww_slider_bar;

	var _slider_thumb_sprite = __src_get(_theme, "slider.sprite.thumb.main");
	if (_slider_thumb_sprite == undefined) _slider_thumb_sprite = spr_ww_slider_thumb;

	var _scrollbar_tray_sprite = __src_get(_theme, "scrollbar.sprite.tray.main");
	if (_scrollbar_tray_sprite == undefined) _scrollbar_tray_sprite = spr_ww_pixel;

	var _scrollbar_gutter_sprite = __src_get(_theme, "scrollbar.sprite.gutter.main");
	if (_scrollbar_gutter_sprite == undefined) _scrollbar_gutter_sprite = spr_ww_pixel;

	var _scrollbar_trough_sprite = __src_get(_theme, "scrollbar.sprite.trough.main");
	if (_scrollbar_trough_sprite == undefined) _scrollbar_trough_sprite = spr_ww_pixel;

	var _scrollbar_thumb_sprite = __src_get(_theme, "scrollbar.sprite.thumb.main");
	if (_scrollbar_thumb_sprite == undefined) _scrollbar_thumb_sprite = spr_ww_rr9_r2_all;

	var _scrollbar_left_sprite = __src_get(_theme, "scrollbar.sprite.button.left.main");
	if (_scrollbar_left_sprite == undefined) _scrollbar_left_sprite = spr_ww_rr9_r2_left;

	var _scrollbar_right_sprite = __src_get(_theme, "scrollbar.sprite.button.right.main");
	if (_scrollbar_right_sprite == undefined) _scrollbar_right_sprite = spr_ww_rr9_r2_right;

	var _scrollbar_up_sprite = __src_get(_theme, "scrollbar.sprite.button.up.main");
	if (_scrollbar_up_sprite == undefined) _scrollbar_up_sprite = spr_ww_rr9_r2_top;

	var _scrollbar_down_sprite = __src_get(_theme, "scrollbar.sprite.button.down.main");
	if (_scrollbar_down_sprite == undefined) _scrollbar_down_sprite = spr_ww_rr9_r2_bottom;

	var _canvas_sprite = __src_get(_theme, "canvas.sprite.main");
	if (_canvas_sprite == undefined) _canvas_sprite = _fallback_sprite;

	var _frame_sprite = __src_get(_theme, "frame.sprite.main");
	if (_frame_sprite == undefined) _frame_sprite = _fallback_sprite;

	var _panel_sprite = __src_get(_theme, "panel.sprite.main");
	if (_panel_sprite == undefined) _panel_sprite = _fallback_sprite;

	var _inset_sprite = __src_get(_theme, "inset.sprite.main");
	if (_inset_sprite == undefined) _inset_sprite = _fallback_sprite;

	var _container_sprite = __src_get(_theme, "container.sprite.main");
	if (_container_sprite == undefined) _container_sprite = _fallback_sprite;

	__out_set(_out, "button.sprite.main", _button_sprite);
	__out_set(_out, "button.color.main", _accent);
	__out_set(_out, "button.alpha.main", _alpha1);
	__out_set(_out, "button.color.text", _on_accent);
	__out_set(_out, "button.alpha.text", _alpha1);

	__out_set(_out, "button_text.sprite.main", _button_text_sprite);
	__out_set(_out, "button_text.color.main", _accent);
	__out_set(_out, "button_text.alpha.main", _alpha1);
	__out_set(_out, "button_text.color.text", _on_accent);
	__out_set(_out, "button_text.alpha.text", _alpha1);

	__out_set(_out, "slider.sprite.track.main", _slider_track_sprite);
	__out_set(_out, "slider.sprite.fill.main", _slider_fill_sprite);
	__out_set(_out, "slider.sprite.thumb.main", _slider_thumb_sprite);
	__out_set(_out, "slider.color.track", _surface_control_alt);
	__out_set(_out, "slider.alpha.track", _alpha1);
	__out_set(_out, "slider.color.fill", _accent);
	__out_set(_out, "slider.alpha.fill", _alpha1);
	__out_set(_out, "slider.color.thumb", _surface_control);
	__out_set(_out, "slider.alpha.thumb", _alpha1);

	__out_set(_out, "scrollbar.sprite.tray.main", _scrollbar_tray_sprite);
	__out_set(_out, "scrollbar.sprite.gutter.main", _scrollbar_gutter_sprite);
	__out_set(_out, "scrollbar.sprite.trough.main", _scrollbar_trough_sprite);
	__out_set(_out, "scrollbar.sprite.thumb.main", _scrollbar_thumb_sprite);
	__out_set(_out, "scrollbar.sprite.button.left.main", _scrollbar_left_sprite);
	__out_set(_out, "scrollbar.sprite.button.right.main", _scrollbar_right_sprite);
	__out_set(_out, "scrollbar.sprite.button.up.main", _scrollbar_up_sprite);
	__out_set(_out, "scrollbar.sprite.button.down.main", _scrollbar_down_sprite);

	__out_set(_out, "scrollbar.color.tray", _surface_panel_alt);
	__out_set(_out, "scrollbar.alpha.tray", _alpha1);
	__out_set(_out, "scrollbar.color.gutter", _surface_panel_alt);
	__out_set(_out, "scrollbar.alpha.gutter", _alpha1);
	__out_set(_out, "scrollbar.color.trough", _surface_panel_alt);
	__out_set(_out, "scrollbar.alpha.trough", _alpha1);
	__out_set(_out, "scrollbar.color.thumb", _outline_strong);
	__out_set(_out, "scrollbar.alpha.thumb", (__out_get(_out, "meta.mode") == "dark") ? 0.70 : 0.90);

	var _dirs = ["left", "right", "up", "down"];
	for (var _d = 0; _d < array_length(_dirs); _d++) {
		var _dir = _dirs[_d];
		__out_set(_out, "scrollbar.color.button." + _dir, _surface_control_alt);
		__out_set(_out, "scrollbar.alpha.button." + _dir, _alpha1);
	}

	__out_set(_out, "canvas.sprite.main", _canvas_sprite);
	__out_set(_out, "canvas.color.main", __out_get(_out, "colors.app.bg.color"));
	__out_set(_out, "canvas.alpha.main", __out_get(_out, "colors.app.bg.alpha"));
	__out_set(_out, "canvas.color.border", _outline_subtle);
	__out_set(_out, "canvas.alpha.border", _alpha1);
	__out_set(_out, "canvas.size.border", 0);

	__out_set(_out, "frame.sprite.main", _frame_sprite);
	__out_set(_out, "frame.color.main", _surface_panel);
	__out_set(_out, "frame.alpha.main", _alpha1);
	__out_set(_out, "frame.color.border", _outline_strong);
	__out_set(_out, "frame.alpha.border", _alpha1);
	__out_set(_out, "frame.size.border", 1);

	__out_set(_out, "panel.sprite.main", _panel_sprite);
	__out_set(_out, "panel.color.main", _surface_panel_alt);
	__out_set(_out, "panel.alpha.main", _alpha1);
	__out_set(_out, "panel.color.border", _outline_normal);
	__out_set(_out, "panel.alpha.border", _alpha1);
	__out_set(_out, "panel.size.border", 1);

	__out_set(_out, "inset.sprite.main", _inset_sprite);
	__out_set(_out, "inset.color.main", _surface_control_alt);
	__out_set(_out, "inset.alpha.main", _alpha1);
	__out_set(_out, "inset.color.border", _outline_subtle);
	__out_set(_out, "inset.alpha.border", _alpha1);
	__out_set(_out, "inset.size.border", 1);

	__out_set(_out, "container.sprite.main", _container_sprite);
	__out_set(_out, "container.color.main", _surface_control);
	__out_set(_out, "container.alpha.main", _alpha1);
	__out_set(_out, "container.color.border", _outline_subtle);
	__out_set(_out, "container.alpha.border", _alpha1);
	__out_set(_out, "container.size.border", 0);

	var _text_renderer_font = __src_get(_theme, "text_renderer.font.main");
	if (!is_numeric(_text_renderer_font)) _text_renderer_font = __out_get(_out, "text_renderer.font.main");
	if (!is_numeric(_text_renderer_font)) _text_renderer_font = __out_get(_out, "fallback.font");
	__out_set(_out, "text_renderer.font.main", _text_renderer_font);

	var _text_renderer_code_font = __src_get(_theme, "text_renderer.font.code");
	if (!is_numeric(_text_renderer_code_font)) _text_renderer_code_font = __out_get(_out, "text_renderer.font.code");
	if (!is_numeric(_text_renderer_code_font)) _text_renderer_code_font = _text_renderer_font;
	__out_set(_out, "text_renderer.font.code", _text_renderer_code_font);

	__out_set(_out, "text_renderer.color.main", __pick_from_src(_theme, "text_renderer.color.main", _text_primary));
	__out_set(_out, "text_renderer.alpha.main", __pick_from_src(_theme, "text_renderer.alpha.main", _alpha1));
	__out_set(_out, "text_renderer.color.dim", __pick_from_src(_theme, "text_renderer.color.dim", _text_dim));
	__out_set(_out, "text_renderer.color.disabled", __pick_from_src(_theme, "text_renderer.color.disabled", _text_disabled));
	__out_set(_out, "text_renderer.alpha.disabled", __pick_from_src(_theme, "text_renderer.alpha.disabled", _disabled_alpha));
}
