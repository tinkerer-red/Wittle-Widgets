#macro __WW_THEME_PATH_NOT_FOUND -987654321

function wwThemeBuild(_theme_or_layers = undefined, _opts = undefined) {
	/// Builds a "compiled" theme struct for fast access.
	///
	/// - Accepts either a single theme struct or an array of layers.
	/// - If an array is provided, layers are composed in order (later overrides earlier).
	/// - Produces a NEW struct where any dotted-path strings that point into the theme
	///   are replaced by direct struct/value references.
	/// - Optionally derives missing colors/palette entries (YUI-inspired).
	///
	/// NOTE: Regular strings like IDs/names remain strings. Only resolvable dotted-path
	/// references are replaced.

	var opts = __wwThemeBuildApplyOpts(_opts);

	// 1) compose layers (if needed)
	var theme;
	if (_theme_or_layers == undefined) {
		theme = wwThemeDefault();
	}
	else if (is_array(_theme_or_layers)) {
		theme = wwThemeCompose(_theme_or_layers);
	}
	else {
		theme = _theme_or_layers;
	}

	// 2) clone so we can safely add derived values + resolve references in-place
	var built = variable_clone(theme);

	// 3) derive missing paints/palette
	if (opts[$ "derive_missing_colors"]) {
		__wwThemeDeriveMissing(built, opts);
	}

	// 4) resolve any dotted-path strings to direct values/struct references
	if (opts[$ "resolve_paths"]) {
		__wwThemeResolveAll(built, opts[$ "max_resolve_passes"]);
	}

	// 5) compile typography conveniences (optional)
	if (opts[$ "resolve_typography"]) {
		__wwThemeCompileTypography(built, opts);
		if (opts[$ "resolve_paths"]) {
			// Typography compilation can introduce/retain references; resolve once more.
			__wwThemeResolveAll(built, 2);
		}
	}

	// 6) optional strict check
	if (opts[$ "strict_no_path_strings"]) {
		var _left = __wwThemeCountResolvablePathStrings(built);
		if (_left > 0) {
			show_debug_message("wwThemeBuild strict: unresolved path strings remaining: " + string(_left));
		}
	}

	return built;
}

#region Helpers

function __wwThemeBuildApplyOpts(_opts) {
	var opts = {
		derive_missing_colors: true,
		resolve_paths: true,
		resolve_typography: true,
		apply_text_scale: true,
		max_resolve_passes: 6,
		strict_no_path_strings: false,
		mode_override: undefined
	};
	if (is_struct(_opts)) {
		var _k = variable_struct_get_names(_opts);
		var _n = array_length(_k);
		for (var i = 0; i < _n; i++) {
			var name = _k[i];
			variable_struct_set(opts, name, variable_struct_get(_opts, name));
		}
	}
	return opts;
}

function __wwThemeComposeFallback(_layers) {
	var _count = array_length(_layers);
	if (_count <= 0) { return {}; }
	var _out = variable_clone(_layers[0]);
	for (var i = 1; i < _count; i++) {
		_out = wwThemeMerge(_out, _layers[i]);
	}
	return _out;
}

function __wwThemeResolveAll(_root, _max_passes) {
	_max_passes = max(1, _max_passes);
	for (var pass = 0; pass < _max_passes; pass++) {
		var changed = __wwThemeResolveNode(_root, _root);
		if (changed <= 0) { break; }
	}
}

function __wwThemeResolveNode(_root, _node) {
	var changed = 0;
	if (is_struct(_node)) {
		var keys = variable_struct_get_names(_node);
		var n = array_length(keys);
		for (var i = 0; i < n; i++) {
			var k = keys[i];
			var v = variable_struct_get(_node, k);
			var nv = __wwThemeMaybeResolvePathValue(_root, v);
			if (nv != v) {
				variable_struct_set(_node, k, nv);
				changed += 1;
				v = nv;
			}
			changed += __wwThemeResolveNode(_root, v);
		}
		return changed;
	}
	if (is_array(_node)) {
		var n = array_length(_node);
		for (var i = 0; i < n; i++) {
			var v = _node[i];
			var nv = __wwThemeMaybeResolvePathValue(_root, v);
			if (nv != v) {
				_node[i] = nv;
				changed += 1;
				v = nv;
			}
			changed += __wwThemeResolveNode(_root, v);
		}
	}
	return changed;
}

function __wwThemeMaybeResolvePathValue(_root, _value) {
	if (!is_string(_value)) { return _value; }
	if (string_pos(".", _value) <= 0) { return _value; }

	// Only treat as a theme-path if it resolves.
	var resolved = __wwThemePathGet(_root, _value);
	if (resolved != __WW_THEME_PATH_NOT_FOUND) { return resolved; }

	// Shorthand aliases (keep theme definitions clean/readable).
	// e.g. "fonts.ui.strong" -> "typography.fonts.ui.strong"
	var alias = __wwThemeExpandAliasPath(_value);
	if (alias != _value) {
		resolved = __wwThemePathGet(_root, alias);
		if (resolved != __WW_THEME_PATH_NOT_FOUND) { return resolved; }
	}

	return _value;
}

function __wwThemeExpandAliasPath(_path) {
	// Expand common shorthand roots used in theme definitions.
	// If no alias matches, returns the original string.
	if (!is_string(_path)) return _path;

	if (string_pos("fonts.", _path) == 1) return "typography." + _path;
	if (string_pos("text_styles.", _path) == 1) return "typography." + _path;
	if (string_pos("sizes_px.", _path) == 1) return "typography." + _path;
	if (string_pos("line_height.", _path) == 1) return "typography." + _path;

	return _path;
}

function __wwThemePathGet(_root, _path) {
	if (!is_struct(_root) || !is_string(_path) || _path == "") { return __WW_THEME_PATH_NOT_FOUND; }

	var cur = _root;
	var start = 1;
	var len = string_length(_path);
	for (var i = 1; i <= len + 1; i++) {
		var is_end = (i == len + 1);
		if (!is_end && string_char_at(_path, i) != ".") { continue; }

		var part = string_copy(_path, start, i - start);
		start = i + 1;
		if (part == "") { return __WW_THEME_PATH_NOT_FOUND; }
		if (!is_struct(cur)) { return __WW_THEME_PATH_NOT_FOUND; }
		if (!variable_struct_exists(cur, part)) { return __WW_THEME_PATH_NOT_FOUND; }
		cur = variable_struct_get(cur, part);
	}
	return cur;
}

function __wwThemeCountResolvablePathStrings(_root) {
	return __wwThemeCountResolvablePathStringsNode(_root, _root);
}

function __wwThemeCountResolvablePathStringsNode(_root, _node) {
	var count = 0;
	if (is_struct(_node)) {
		var keys = variable_struct_get_names(_node);
		var n = array_length(keys);
		for (var i = 0; i < n; i++) {
			var v = variable_struct_get(_node, keys[i]);
			if (is_string(v) && string_pos(".", v) > 0) {
				if (__wwThemePathGet(_root, v) != __WW_THEME_PATH_NOT_FOUND) {
					count += 1;
				}
			}
			count += __wwThemeCountResolvablePathStringsNode(_root, v);
		}
		return count;
	}
	if (is_array(_node)) {
		var n = array_length(_node);
		for (var i = 0; i < n; i++) {
			count += __wwThemeCountResolvablePathStringsNode(_root, _node[i]);
		}
	}
	return count;
}

function __wwThemeDeriveMissing(_theme, _opts) {
	if (!is_struct(_theme)) { return; }
	if (!variable_struct_exists(_theme, "colors") || !is_struct(_theme.colors)) {
		_theme.colors = {};
	}
	if (!variable_struct_exists(_theme, "palette") || !is_struct(_theme.palette)) {
		_theme.palette = {};
	}
	if (!variable_struct_exists(_theme, "derive") || !is_struct(_theme.derive)) {
		_theme.derive = { enabled: false, tint_color: #FFFFFF, accent_color: #2F6BFF, lum_factor: 1.0, hue_shift: 0.0, sat_mul: 1.0, val_mul: 1.0 };
	}

	var mode = _opts[$ "mode_override"];
	if (mode == undefined) {
		mode = (variable_struct_exists(_theme, "meta") && is_struct(_theme.meta) && variable_struct_exists(_theme.meta, "mode"))
			? _theme.meta.mode
			: "";
	}
	if (mode == "") {
		// Detect based on app bg luma if available.
		var bg_paint = __wwThemeGetPaint(_theme, "colors.app.bg");
		if (bg_paint != undefined && bg_paint.color != undefined) {
			mode = (__wwColorGetLuma(bg_paint.color) >= 0.55) ? "light" : "dark";
		}
		else {
			mode = "dark";
		}
	}

	// Fill palette neutrals (n0..n100) if missing.
	__wwThemeDerivePaletteNeutrals(_theme, mode);
	__wwThemeDerivePaletteAccents(_theme);

	// Fill semantic paints if missing.
	__wwThemeDeriveColors(_theme, mode);
}

function __wwThemeGetPaint(_theme, _path) {
	var v = __wwThemePathGet(_theme, _path);
	if (v == __WW_THEME_PATH_NOT_FOUND) { return undefined; }
	return __wwPaintEnsure(v);
}

function __wwPaintEnsure(_v) {
	if (is_struct(_v) && variable_struct_exists(_v, "color") && variable_struct_exists(_v, "alpha")) {
		return _v;
	}
	if (is_numeric(_v)) {
		return { color: _v, alpha: 1 };
	}
	if (_v == undefined) {
		return { color: undefined, alpha: undefined };
	}
	// Unknown shape, preserve.
	return _v;
}

function __wwPaintFillMissing(_paint, _color, _alpha) {
	if (!is_struct(_paint) || !variable_struct_exists(_paint, "color") || !variable_struct_exists(_paint, "alpha")) { return; }
	if (_paint.color == undefined && _color != undefined) { _paint.color = _color; }
	if (_paint.alpha == undefined && _alpha != undefined) { _paint.alpha = _alpha; }
	if (_paint.alpha == undefined && _paint.color != undefined) { _paint.alpha = 1; }
}

function __wwThemeDerivePaletteNeutrals(_theme, _mode) {
	var p = _theme.palette;

	var n0 = p.n0;
	var n100 = p.n100;
	if (n0 == undefined) {
		var txt = __wwThemeGetPaint(_theme, "colors.text.primary");
		var bg = __wwThemeGetPaint(_theme, "colors.app.bg");
		if (_mode == "light" && txt != undefined && txt.color != undefined) n0 = txt.color;
		else if (_mode == "dark" && bg != undefined && bg.color != undefined) n0 = bg.color;
		else n0 = #0B0F17;
		p.n0 = n0;
	}
	if (n100 == undefined) {
		n100 = #FFFFFF;
		p.n100 = n100;
	}

	// Fill common steps by linear RGB mix between endpoints.
	// If some steps already exist, keep them.
	__wwPaletteFillNeutralStep(p, "n5", n0, n100, 0.05);
	__wwPaletteFillNeutralStep(p, "n10", n0, n100, 0.10);
	__wwPaletteFillNeutralStep(p, "n20", n0, n100, 0.20);
	__wwPaletteFillNeutralStep(p, "n30", n0, n100, 0.30);
	__wwPaletteFillNeutralStep(p, "n40", n0, n100, 0.40);
	__wwPaletteFillNeutralStep(p, "n70", n0, n100, 0.70);
	__wwPaletteFillNeutralStep(p, "n90", n0, n100, 0.90);
}

function __wwPaletteFillNeutralStep(_palette, _key, _n0, _n100, _t) {
	if (!variable_struct_exists(_palette, _key) || variable_struct_get(_palette, _key) == undefined) {
		variable_struct_set(_palette, _key, merge_color(_n0, _n100, _t));
	}
}

function __wwThemeDerivePaletteAccents(_theme) {
	var p = _theme.palette;
	var d = _theme.derive;
	if (p.blue == undefined) p.blue = (variable_struct_exists(d, "accent_color") && d.accent_color != undefined) ? d.accent_color : #2F6BFF;
	if (p.green == undefined) p.green = #1F9D55;
	if (p.yellow == undefined) p.yellow = #B7791F;
	if (p.orange == undefined) p.orange = #DD6B20;
	if (p.red == undefined) p.red = #E53E3E;
	if (p.purple == undefined) p.purple = #805AD5;
}

function __wwThemeDeriveColors(_theme, _mode) {
	// Ensure the expected nested structs exist (create minimal ones if needed).
	__wwEnsureStructPath(_theme, "colors.app");
	__wwEnsureStructPath(_theme, "colors.surface");
	__wwEnsureStructPath(_theme, "colors.outline");
	__wwEnsureStructPath(_theme, "colors.text");
	__wwEnsureStructPath(_theme, "colors.accent");
	__wwEnsureStructPath(_theme, "colors.state");
	__wwEnsureStructPath(_theme, "colors.overlay");

	var p = _theme.palette;
	var accent_paint = __wwPaintEnsure(_theme.colors.accent.primary);
	var accent = (is_struct(accent_paint) && variable_struct_exists(accent_paint, "color")) ? accent_paint.color : undefined;
	if (accent == undefined) accent = p.blue;

	// app
	__wwPaintFillMissing(__wwEnsurePaintPath(_theme, "colors.app.bg"), (_mode == "light") ? p.n90 : p.n0, 1);
	__wwPaintFillMissing(__wwEnsurePaintPath(_theme, "colors.app.bg_alt"), (_mode == "light") ? p.n100 : p.n5, 1);

	// surface
	__wwPaintFillMissing(__wwEnsurePaintPath(_theme, "colors.surface.panel"), (_mode == "light") ? p.n100 : p.n5, 1);
	__wwPaintFillMissing(__wwEnsurePaintPath(_theme, "colors.surface.panel_alt"), (_mode == "light") ? p.n90 : p.n10, 1);
	__wwPaintFillMissing(__wwEnsurePaintPath(_theme, "colors.surface.control"), (_mode == "light") ? p.n100 : p.n10, 1);
	__wwPaintFillMissing(__wwEnsurePaintPath(_theme, "colors.surface.control_alt"), (_mode == "light") ? merge_color(p.n90, p.n70, 0.35) : p.n20, 1);
	__wwPaintFillMissing(__wwEnsurePaintPath(_theme, "colors.surface.popup"), __wwEnsurePaintPath(_theme, "colors.surface.panel").color, 1);
	__wwPaintFillMissing(__wwEnsurePaintPath(_theme, "colors.surface.tooltip"), __wwEnsurePaintPath(_theme, "colors.surface.panel").color, (_mode == "light") ? 0.95 : 0.93);

	// outline
	__wwPaintFillMissing(__wwEnsurePaintPath(_theme, "colors.outline.subtle"), (_mode == "light") ? merge_color(p.n70, p.n90, 0.30) : p.n20, 1);
	__wwPaintFillMissing(__wwEnsurePaintPath(_theme, "colors.outline.normal"), (_mode == "light") ? p.n70 : p.n30, 1);
	__wwPaintFillMissing(__wwEnsurePaintPath(_theme, "colors.outline.strong"), (_mode == "light") ? p.n40 : p.n40, 1);

	// text
	__wwPaintFillMissing(__wwEnsurePaintPath(_theme, "colors.text.primary"), (_mode == "light") ? p.n0 : p.n90, 1);
	__wwPaintFillMissing(__wwEnsurePaintPath(_theme, "colors.text.secondary"), (_mode == "light") ? p.n20 : p.n70, 1);
	__wwPaintFillMissing(__wwEnsurePaintPath(_theme, "colors.text.dim"), (_mode == "light") ? p.n40 : merge_color(p.n40, p.n70, 0.50), 1);
	__wwPaintFillMissing(__wwEnsurePaintPath(_theme, "colors.text.disabled"), (_mode == "light") ? merge_color(p.n40, p.n70, 0.65) : p.n40, 1);
	__wwPaintFillMissing(__wwEnsurePaintPath(_theme, "colors.text.inverse"), (_mode == "light") ? p.n100 : p.n0, 1);
	__wwPaintFillMissing(__wwEnsurePaintPath(_theme, "colors.text.link"), accent, 1);

	// accent
	__wwPaintFillMissing(__wwEnsurePaintPath(_theme, "colors.accent.primary"), accent, 1);
	__wwPaintFillMissing(__wwEnsurePaintPath(_theme, "colors.accent.on_accent"), (__wwColorGetLuma(accent) >= 0.55) ? p.n0 : p.n100, 1);
	__wwPaintFillMissing(__wwEnsurePaintPath(_theme, "colors.accent.subtle"), accent, 0.20);

	// state (use accent hue shifted from a neutral base for nicer results)
	var focus_base = __wwEnsurePaintPath(_theme, "colors.outline.normal").color;
	var focus_col = __wwColorShiftHue(focus_base, accent, _theme.derive.lum_factor);
	__wwPaintFillMissing(__wwEnsurePaintPath(_theme, "colors.state.focus_ring"), focus_col, (_mode == "light") ? 0.60 : 0.80);

	var sel_base = __wwEnsurePaintPath(_theme, "colors.surface.control_alt").color;
	var sel_col = __wwColorShiftHue(sel_base, accent, _theme.derive.lum_factor);
	__wwPaintFillMissing(__wwEnsurePaintPath(_theme, "colors.state.selection_bg"), sel_col, (_mode == "light") ? 0.20 : 0.40);
	var sel_text = (_mode == "light") ? p.n0 : p.n100;
	__wwPaintFillMissing(__wwEnsurePaintPath(_theme, "colors.state.selection_text"), sel_text, 1);

	__wwPaintFillMissing(__wwEnsurePaintPath(_theme, "colors.state.success_fg"), p.green, 1);
	__wwPaintFillMissing(__wwEnsurePaintPath(_theme, "colors.state.success_bg"), p.green, 0.20);
	__wwPaintFillMissing(__wwEnsurePaintPath(_theme, "colors.state.warning_fg"), p.yellow, 1);
	__wwPaintFillMissing(__wwEnsurePaintPath(_theme, "colors.state.warning_bg"), p.yellow, 0.20);
	__wwPaintFillMissing(__wwEnsurePaintPath(_theme, "colors.state.danger_fg"), p.red, 1);
	__wwPaintFillMissing(__wwEnsurePaintPath(_theme, "colors.state.danger_bg"), p.red, 0.20);

	// overlay
	__wwPaintFillMissing(__wwEnsurePaintPath(_theme, "colors.overlay.modal_shade"), #000000, (_mode == "light") ? 0.30 : 0.50);
}

function __wwEnsureStructPath(_root, _path) {
	var parts = __wwSplitPath(_path);
	var cur = _root;
	var n = array_length(parts);
	for (var i = 0; i < n; i++) {
		var k = parts[i];
		if (!is_struct(cur)) { return; }
		if (!variable_struct_exists(cur, k) || !is_struct(variable_struct_get(cur, k))) {
			variable_struct_set(cur, k, {});
		}
		cur = variable_struct_get(cur, k);
	}
}

function __wwEnsurePaintPath(_root, _path) {
	var parts = __wwSplitPath(_path);
	var cur = _root;
	var n = array_length(parts);
	for (var i = 0; i < n - 1; i++) {
		var k = parts[i];
		if (!variable_struct_exists(cur, k) || !is_struct(variable_struct_get(cur, k))) {
			variable_struct_set(cur, k, {});
		}
		cur = variable_struct_get(cur, k);
	}
	var leaf = parts[n - 1];
	if (!variable_struct_exists(cur, leaf) || !is_struct(variable_struct_get(cur, leaf))) {
		variable_struct_set(cur, leaf, { color: undefined, alpha: undefined });
	}
	else {
		var p = variable_struct_get(cur, leaf);
		if (!variable_struct_exists(p, "color")) p.color = undefined;
		if (!variable_struct_exists(p, "alpha")) p.alpha = undefined;
	}
	return variable_struct_get(cur, leaf);
}

function __wwSplitPath(_path) {
	var parts = [];
	var start = 1;
	var len = string_length(_path);
	for (var i = 1; i <= len + 1; i++) {
		var is_end = (i == len + 1);
		if (!is_end && string_char_at(_path, i) != ".") { continue; }
		var part = string_copy(_path, start, i - start);
		start = i + 1;
		array_push(parts, part);
	}
	return parts;
}

function __wwColorGetLuma(_color) {
	// 0..1 perceptual-ish luma
	var r = color_get_red(_color) / 255;
	var g = color_get_green(_color) / 255;
	var b = color_get_blue(_color) / 255;
	return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

function __wwColorSetLuma(_color, _luma01) {
	// Inspired by YUI/Juju Adams approach: adjust brightness without destroying hue too much.
	_luma01 = clamp(_luma01, 0, 1);
	if (_color == c_black) {
		var v = round(255 * _luma01);
		return make_color_rgb(v, v, v);
	}
	if (_luma01 >= 1) { return c_white; }

	var r = color_get_red(_color);
	var g = color_get_green(_color);
	var b = color_get_blue(_color);
	var cur = 0.2126 * r + 0.7152 * g + 0.0722 * b;
	var target = 255 * _luma01;
	if (cur <= 0.0001) {
		var v = round(target);
		return make_color_rgb(v, v, v);
	}

	var max_channel = max(r, max(g, b));
	var max_factor = 255 / max_channel;
	var factor = target / cur;
	if (factor <= max_factor) {
		r = clamp(r * factor, 0, 255);
		g = clamp(g * factor, 0, 255);
		b = clamp(b * factor, 0, 255);
		return make_color_rgb(r, g, b);
	}

	// Saturate up, then reduce saturation by lerping towards white.
	r = clamp(r * max_factor, 0, 255);
	g = clamp(g * max_factor, 0, 255);
	b = clamp(b * max_factor, 0, 255);
	cur = 0.2126 * r + 0.7152 * g + 0.0722 * b;
	var t = clamp((target - cur) / (255 - cur), 0, 1);
	r = lerp(r, 255, t);
	g = lerp(g, 255, t);
	b = lerp(b, 255, t);
	return make_color_rgb(r, g, b);
}

function __wwColorShiftHue(_source_color, _hue_color, _luma_factor) {
	if (_source_color == undefined || _hue_color == undefined) return _source_color;
	_luma_factor = (_luma_factor == undefined) ? 1.0 : _luma_factor;
	var source_luma = __wwColorGetLuma(_source_color);
	var target_luma = clamp(source_luma * _luma_factor, 0, 1);
	return __wwColorSetLuma(_hue_color, target_luma);
}

function __wwThemeCompileTypography(_theme, _opts) {
	if (!variable_struct_exists(_theme, "typography") || !is_struct(_theme.typography)) return;
	var t = _theme.typography;
	if (!variable_struct_exists(t, "text_styles") || !is_struct(t.text_styles)) return;

	var scale = 1.0;
	if (_opts[$ "apply_text_scale"] && variable_struct_exists(_theme, "scale") && is_struct(_theme.scale) && variable_struct_exists(_theme.scale, "text")) {
		scale = _theme.scale.text;
	}

	// Normalize sizes: if size is a key like "md", replace with px value.
	var sizes = (variable_struct_exists(t, "sizes_px") && is_struct(t.sizes_px)) ? t.sizes_px : undefined;

	var style_keys = variable_struct_get_names(t.text_styles);
	var n = array_length(style_keys);
	for (var i = 0; i < n; i++) {
		var key = style_keys[i];
		var style = variable_struct_get(t.text_styles, key);
		if (!is_struct(style)) continue;

		// Resolve "size" symbolic tokens.
		if (sizes != undefined && variable_struct_exists(style, "size") && is_string(style.size)) {
			if (variable_struct_exists(sizes, style.size)) {
				style.size = round(variable_struct_get(sizes, style.size) * scale);
			}
		}
		else if (variable_struct_exists(style, "size") && is_numeric(style.size)) {
			style.size = round(style.size * scale);
		}
	}
}

#endregion