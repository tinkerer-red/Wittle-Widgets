function wwThemeMerge(_base_theme, _overlay_theme) {
	/// Deep-merge two theme structs into a new theme.
	///
	/// Rules:
	/// - structs merge recursively
	/// - arrays replace by default
	/// - primitives replace
	/// - special-case: meta.tags arrays union (unique)
	///
	/// This does NOT mutate inputs.
	var _out = variable_clone(_base_theme);
	if (_overlay_theme != undefined) {
		__wwThemeMergeInto(_out, _overlay_theme, "");
	}
	return _out;
}

function wwThemeCompose(_themes) {
	/// Compose a full theme from an array of base + overlays.
	///
	/// Example:
	/// var theme = wwThemeCompose([
	/// 	wwThemeDefault(),
	/// 	wwThemeLight(),
	/// 	wwThemePixelArt(),
	/// 	wwThemeRounded()
	/// ]);
	///
	/// Later entries override earlier ones.
	if (!is_array(_themes)) { _themes = [_themes]; }
	var _count = array_length(_themes);
	if (_count <= 0) { return {}; }

	var _out = variable_clone(_themes[0]);
	for (var _i = 1; _i < _count; _i++) {
		var _overlay = _themes[_i];
		if (_overlay != undefined) {
			__wwThemeMergeInto(_out, _overlay, "");
		}
	}
	
	return _out;
}

function __wwThemeMergeInto(_dst, _src, _path) {
	var _keys = variable_struct_get_names(_src);
	var _key_count = array_length(_keys);
	for (var _i = 0; _i < _key_count; _i++) {
		var _k = _keys[_i];
		var _src_v = variable_struct_get(_src, _k);
		var _has_dst = variable_struct_exists(_dst, _k);
		var _dst_v = (_has_dst) ? variable_struct_get(_dst, _k) : undefined;
		var _next_path = (_path == "") ? string(_k) : (_path + "." + string(_k));

		if (_next_path == "meta.tags" && is_array(_src_v)) {
			var _merged = (_has_dst && is_array(_dst_v)) ? variable_clone(_dst_v) : [];
			var _src_len = array_length(_src_v);
			for (var _j = 0; _j < _src_len; _j++) {
				var _tag = _src_v[_j];
				if (!array_contains(_merged, _tag)) {
					array_push(_merged, _tag);
				}
			}
			variable_struct_set(_dst, _k, _merged);
			continue;
		}

		if (is_struct(_src_v) && _has_dst && is_struct(_dst_v)) {
			__wwThemeMergeInto(_dst_v, _src_v, _next_path);
			continue;
		}

		variable_struct_set(_dst, _k, variable_clone(_src_v));
	}
}

function wwThemeLayerRoundedRectangles() {
	/// Overlay-only layer: swaps in rounded-rectangle component sprite hooks.
	return {
		meta: {
			id: "ww_layer_rounded_rectangles",
			name: "Rounded Rectangles Layer",
			tags: ["layer", "rounded"]
		},
		button: {
			sprite: {
				main: spr_ww_rr9_r4_all
			}
		},
		button_text: {
			sprite: {
				main: spr_ww_rr9_r4_all
			}
		},
		slider: {
			sprite: {
				track: { main: spr_ww_slider_background },
				fill: { main: spr_ww_slider_bar },
				thumb: { main: spr_ww_slider_thumb }
			}
		},
		scrollbar: {
			sprite: {
				button: {
					up: { main: spr_ww_rr9_r2_top },
					down: { main: spr_ww_rr9_r2_bottom },
					left: { main: spr_ww_rr9_r2_left },
					right: { main: spr_ww_rr9_r2_right }
				},
				tray: { main: spr_ww_pixel },
				gutter: { main: spr_ww_pixel },
				trough: { main: spr_ww_pixel },
				thumb: { main: spr_ww_rr9_r2_all }
			}
		}
	};
}

function wwThemePresetLightRounded() {
	return wwThemeCompose([
		wwThemeDefault(),
		wwThemeLayerRoundedRectangles(),
		wwThemeLayerLight()
	]);
}

function wwThemePresetDarkRounded() {
	return wwThemeCompose([
		wwThemeDefault(),
		wwThemeLayerRoundedRectangles(),
		wwThemeLayerDark()
	]);
}

function wwThemeLayerDark() {
	/// Overlay-only dark layer (no asset overrides).
	var _dark = wwThemeDark();
	return {
		meta: _dark.meta,
		derive: _dark.derive,
		palette: _dark.palette,
		colors: _dark.colors,
		scrollbar: _dark.scrollbar
	};
}

function wwThemeLayerLight() {
	/// Overlay-only light layer (no asset overrides).
	var _light = wwThemeLight();
	return {
		meta: _light.meta,
		derive: _light.derive,
		palette: _light.palette,
		colors: _light.colors,
		scrollbar: _light.scrollbar
	};
}
