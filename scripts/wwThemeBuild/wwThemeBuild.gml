#macro __WW_THEME_PATH_NOT_FOUND -987654321

function wwThemeBuild(_theme_or_layers = undefined, _opts = undefined) {
	/// Stage builder:
	/// 01 derive -> 02 palette -> 03 tokens -> 04 components -> 05 states
	/// Returns nested built theme. Use wwThemeCompile() for runtime flat map.
	var _opts_norm = __wwThemeBuildApplyOpts(_opts);
	var _source = undefined;

	if (_theme_or_layers == undefined) {
		_source = wwThemeDefault();
	}
	else if (is_array(_theme_or_layers)) {
		var _layers = [];
		if (_opts_norm[$ "use_default_base"]) {
			array_push(_layers, wwThemeDefault());
		}
		var _src_count = array_length(_theme_or_layers);
		for (var _li = 0; _li < _src_count; _li++) {
			array_push(_layers, _theme_or_layers[_li]);
		}
		_source = wwThemeCompose(_layers);
	}
	else {
		if (_opts_norm[$ "use_default_base"]) {
			_source = wwThemeCompose([wwThemeDefault(), _theme_or_layers]);
		}
		else {
			_source = _theme_or_layers;
		}
	}

	var _out = {};

	__wwThemeBuild01Derive(_source, _out);
	__wwThemeBuild02Palette(_source, _out);
	__wwThemeBuild03Tokens(_source, _out);
	__wwThemeBuild04Components(_source, _out);
	__wwThemeBuild05States(_source, _out);

	return _out;
}

function wwThemeCompile(_theme) {
	/// Flattens a built theme into a leaf-only key/value map for runtime fetches.
	var _flat = {};
	if (!is_struct(_theme)) return _flat;
	var _visit_key = "__ww_compile_visit__";
	var _visit_token = string(current_time) + "_" + string(irandom(1000000000));
	var _stack = [{ node: _theme, path: "", enter: true }];
	var _marked = [];
	var _had_cycle = false;
	var _cycle_path = "";
	while (array_length(_stack) > 0) {
		var _idx = array_length(_stack) - 1;
		var _record = _stack[_idx];
		array_resize(_stack, _idx);

		var _node = _record.node;
		var _path = _record.path;
		var _enter = _record.enter;

		if (is_struct(_node)) {
			if (_enter) {
				if (variable_struct_exists(_node, _visit_key) && variable_struct_get(_node, _visit_key) == _visit_token) {
					_had_cycle = true;
					_cycle_path = _path;
					break;
				}

				variable_struct_set(_node, _visit_key, _visit_token);
				array_push(_marked, _node);

				// Exit marker pass for unmarking after children.
				array_push(_stack, { node: _node, path: _path, enter: false });

				var _names = variable_struct_get_names(_node);
				for (var _i = 0; _i < array_length(_names); _i++) {
					var _k = _names[_i];
					if (_k == _visit_key) continue;

					var _child = variable_struct_get(_node, _k);
					var _next = (_path == "") ? string(_k) : (_path + "." + string(_k));
					array_push(_stack, { node: _child, path: _next, enter: true });
				}
			}
			else {
				if (variable_struct_exists(_node, _visit_key)) {
					variable_struct_remove(_node, _visit_key);
				}
			}
			continue;
		}

		if (_enter) {
			if (is_array(_node)) continue;
			if (_path == "" || _node == undefined) continue;

			variable_struct_set(_flat, _path, _node);
		}
	}

	// Ensure temporary marker cleanup even after early cycle break.
	for (var _m = 0; _m < array_length(_marked); _m++) {
		var _marked_node = _marked[_m];
		if (is_struct(_marked_node) && variable_struct_exists(_marked_node, _visit_key)) {
			variable_struct_remove(_marked_node, _visit_key);
		}
	}

	if (_had_cycle) {
		show_error("wwThemeCompile: recursive struct reference detected at path '" + _cycle_path + "'.", true);
	}

	__wwThemeAddIdleAliases(_flat);

	if (!variable_struct_exists(_flat, "fallback.sprite")) variable_struct_set(_flat, "fallback.sprite", spr_ww_pixel);
	if (!variable_struct_exists(_flat, "fallback.color")) variable_struct_set(_flat, "fallback.color", #FF00FF);
	if (!variable_struct_exists(_flat, "fallback.alpha")) variable_struct_set(_flat, "fallback.alpha", 1);
	if (!variable_struct_exists(_flat, "fallback.size")) variable_struct_set(_flat, "fallback.size", 0);
	if (!variable_struct_exists(_flat, "fallback.icon")) variable_struct_set(_flat, "fallback.icon", -1);
	if (!variable_struct_exists(_flat, "fallback.font")) variable_struct_set(_flat, "fallback.font", fnt_ww_default_small_msdf);

	return _flat;
}

#region Helpers

function __wwThemeBuildApplyOpts(_opts) {
	var opts = {
		use_default_base: true,
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

function __wwThemeEnsureRequiredFallbacks(_theme) {
	if (!is_struct(_theme)) return;

	__wwEnsureStructPath(_theme, "fallback");
	var _fallback = _theme.fallback;

	if (!variable_struct_exists(_fallback, "sprite") || _fallback.sprite == undefined) {
		var _spr = spr_ww_pixel;
		_fallback.sprite = _spr;
	}

	if (!variable_struct_exists(_fallback, "color") || _fallback.color == undefined) {
		_fallback.color = #FF00FF;
	}
	if (!variable_struct_exists(_fallback, "alpha") || _fallback.alpha == undefined) {
		_fallback.alpha = 1;
	}
	if (!variable_struct_exists(_fallback, "size") || _fallback.size == undefined) {
		_fallback.size = 0;
	}
	if (!variable_struct_exists(_fallback, "icon") || _fallback.icon == undefined) {
		_fallback.icon = -1;
	}
	if (!variable_struct_exists(_fallback, "font") || _fallback.font == undefined) {
		var _font = fnt_ww_default_small_msdf;
		_fallback.font = _font;
	}
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

function __wwThemeSetPath(_root, _path, _value) {
	if (!is_struct(_root) || !is_string(_path) || _path == "") return false;

	var _parts = __wwSplitPath(_path);
	var _n = array_length(_parts);
	if (_n <= 0) return false;

	var _cur = _root;
	for (var _i = 0; _i < _n - 1; _i++) {
		var _part = _parts[_i];
		if (!variable_struct_exists(_cur, _part) || !is_struct(variable_struct_get(_cur, _part))) {
			variable_struct_set(_cur, _part, {});
		}
		_cur = variable_struct_get(_cur, _part);
	}

	variable_struct_set(_cur, _parts[_n - 1], _value);
	return true;
}

function __wwThemeAddIdleAliases(_flat) {
	if (!is_struct(_flat)) return;

	var _keys = variable_struct_get_names(_flat);
	var _n = array_length(_keys);
	for (var _i = 0; _i < _n; _i++) {
		var _key = _keys[_i];
		if (!is_string(_key) || _key == "") continue;
		if (string_pos("__meta__", _key) == 1) continue;

		var _value = variable_struct_get(_flat, _key);
		if (is_struct(_value) || is_array(_value)) continue;

		var _last = __wwThemePathLastSegment(_key);
		if (__wwThemeIsStateSegment(_last)) continue;

		if (!__wwThemePathSupportsIdleAlias(_key)) continue;

		var _idle_key = _key + ".idle";
		if (!variable_struct_exists(_flat, _idle_key)) {
			variable_struct_set(_flat, _idle_key, _value);
		}
	}
}

function __wwThemePathLastSegment(_path) {
	if (!is_string(_path) || _path == "") return "";

	var _len = string_length(_path);
	for (var _i = _len; _i >= 1; _i--) {
		if (string_char_at(_path, _i) == ".") {
			return string_copy(_path, _i + 1, _len - _i);
		}
	}
	return _path;
}

function __wwThemeIsStateSegment(_segment) {
	if (!is_string(_segment) || _segment == "") return false;

	switch (_segment) {
		case "idle":
		case "hover":
		case "active":
		case "focused":
		case "disabled":
		case "checked":
		case "unchecked":
		case "selected":
		case "warning":
		case "error":
			return true;
	}
	return false;
}

function __wwThemePathSupportsIdleAlias(_path) {
	if (!is_string(_path) || _path == "") return false;

	var _parts = __wwSplitPath(_path);
	var _count = array_length(_parts);
	if (_count < 3) return false;

	var _root = _parts[0];
	if (_root == "fallback"
	|| _root == "meta"
	|| _root == "schema"
	|| _root == "palette"
	|| _root == "colors"
	|| _root == "compiled") {
		return false;
	}

	var _type = _parts[1];
	return (_type == "sprite"
		|| _type == "color"
		|| _type == "alpha"
		|| _type == "size"
		|| _type == "font"
		|| _type == "icon");
}

#endregion
