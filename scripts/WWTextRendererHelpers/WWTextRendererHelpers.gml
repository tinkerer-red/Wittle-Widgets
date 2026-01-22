#region jsDoc
/// @func    WWTextRendererHelpers()
/// @desc    Shared helpers for WW text processors. Provides:
///          - state clone + patch apply
///          - context for building output text + spans without closures
#endregion

#region State

/// @func    __ww_textproc_state_clone__()
/// @param   {Struct} _state
/// @returns {Struct} cloned_state
function __ww_textproc_state_clone__(_state) {

	var _clone = {
		color: _state.color,
		alpha: _state.alpha,

		font_asset: _state.font_asset,
		style: _state.style,
		size_mul: _state.size_mul,

		underline: _state.underline,
		strike: _state.strike,

		back_color: _state.back_color,
		back_alpha: _state.back_alpha,

		align_value: (variable_struct_exists(_state, "align_value") ? _state.align_value : __WW_Text_Alignment.Left)
	};

	return _clone;
}

/// @func    __ww_textproc_state_apply_patch__()
/// @desc    Applies keys that exist in _patch onto _state.
/// @param   {Struct} _state
/// @param   {Struct} _patch
function __ww_textproc_state_apply_patch__(_state, _patch) {

	if (is_undefined(_patch)) { return; }

	if (variable_struct_exists(_patch, "color")) { _state.color = _patch.color; }
	if (variable_struct_exists(_patch, "alpha")) { _state.alpha = _patch.alpha; }

	if (variable_struct_exists(_patch, "font_asset")) { _state.font_asset = _patch.font_asset; }
	if (variable_struct_exists(_patch, "style")) { _state.style = _patch.style; }
	if (variable_struct_exists(_patch, "size_mul")) { _state.size_mul = _patch.size_mul; }

	if (variable_struct_exists(_patch, "underline")) { _state.underline = _patch.underline; }
	if (variable_struct_exists(_patch, "strike")) { _state.strike = _patch.strike; }

	if (variable_struct_exists(_patch, "back_color")) { _state.back_color = _patch.back_color; }
	if (variable_struct_exists(_patch, "back_alpha")) { _state.back_alpha = _patch.back_alpha; }
	if (variable_struct_exists(_patch, "align_value")) { _state.align_value = _patch.align_value; }
}

#endregion

#region Spans

/// @func    __ww_textproc_span_make__()
/// @param   {Real} _start_index
/// @param   {Real} _end_index
/// @param   {Struct} _state
/// @returns {Struct} span
function __ww_textproc_span_make__(_start_index, _end_index, _state) {

	var _span = {
		start_index: _start_index,
		end_index: _end_index,

		color: _state.color,
		alpha: _state.alpha,

		font_asset: _state.font_asset,
		style: _state.style,
		size_mul: _state.size_mul,

		underline: _state.underline,
		strike: _state.strike,

		back_color: _state.back_color,
		back_alpha: _state.back_alpha
	};

	return _span;
}

/// @func    __ww_textproc_span_flush__()
/// @desc    Flushes the current span state into _spans.
/// @param   {Array} _spans
/// @param   {Struct} _state
/// @param   {Real} _span_start
/// @param   {Real} _end_index
/// @returns {Real} new_span_start
function __ww_textproc_span_flush__(_spans, _state, _span_start, _end_index) {

	if (_end_index < _span_start) { return _span_start; }

	array_push(_spans, __ww_textproc_span_make__(_span_start, _end_index, _state));
	return _end_index;
}

#endregion

#region Context

/// @func    __ww_textproc_ctx_begin__()
/// @desc    Creates a parsing context for building processed text + spans.
/// @param   {Struct} _default_state
/// @returns {Struct} ctx
function __ww_textproc_ctx_begin__(_default_state) {

	var _ctx = {
		out_chunks: [],
		out_len: 0,

		spans: [],
		state: __ww_textproc_state_clone__(_default_state),
		span_start: 0
	};

	return _ctx;
}

/// @func    __ww_textproc_ctx_append_text__()
/// @desc    Appends to output and advances out_len.
/// @param   {Struct} _ctx
/// @param   {String} _text
function __ww_textproc_ctx_append_text__(_ctx, _text) {

	if (_text == "") { return; }

	array_push(_ctx.out_chunks, _text);
	_ctx.out_len += string_length(_text);
}

/// @func    __ww_textproc_ctx_flush_span__()
/// @param   {Struct} _ctx
/// @param   {Real} _end_index
function __ww_textproc_ctx_flush_span__(_ctx, _end_index) {

	_ctx.span_start = __ww_textproc_span_flush__(_ctx.spans, _ctx.state, _ctx.span_start, _end_index);
}

/// @func    __ww_textproc_ctx_apply_patch__()
/// @desc    Flushes if any patch key would change the current state, then applies patch.
/// @param   {Struct} _ctx
/// @param   {Struct} _patch
function __ww_textproc_ctx_apply_patch__(_ctx, _patch) {

	if (is_undefined(_patch)) { return; }

	var _needs_flush = false;

	if (variable_struct_exists(_patch, "color") && _ctx.state.color != _patch.color) { _needs_flush = true; }
	if (variable_struct_exists(_patch, "alpha") && _ctx.state.alpha != _patch.alpha) { _needs_flush = true; }

	if (variable_struct_exists(_patch, "font_asset") && _ctx.state.font_asset != _patch.font_asset) { _needs_flush = true; }
	if (variable_struct_exists(_patch, "style") && _ctx.state.style != _patch.style) { _needs_flush = true; }
	if (variable_struct_exists(_patch, "size_mul") && _ctx.state.size_mul != _patch.size_mul) { _needs_flush = true; }

	if (variable_struct_exists(_patch, "underline") && _ctx.state.underline != _patch.underline) { _needs_flush = true; }
	if (variable_struct_exists(_patch, "strike") && _ctx.state.strike != _patch.strike) { _needs_flush = true; }

	if (variable_struct_exists(_patch, "back_color") && _ctx.state.back_color != _patch.back_color) { _needs_flush = true; }
	if (variable_struct_exists(_patch, "back_alpha") && _ctx.state.back_alpha != _patch.back_alpha) { _needs_flush = true; }

	if (_needs_flush) {
		__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
	}

	__ww_textproc_state_apply_patch__(_ctx.state, _patch);
}

/// @func    __ww_textproc_ctx_finish__()
/// @desc    Finalizes spans and returns result struct {text, spans}.
/// @param   {Struct} _ctx
/// @returns {Struct} result
function __ww_textproc_ctx_finish__(_ctx) {

    __ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);

    var _text = "";
    if (array_length(_ctx.out_chunks) > 0) {
        _text = string_join_ext("", _ctx.out_chunks);
    }

    return { text: _text, spans: _ctx.spans };
}

#endregion

#region jsDoc
/// @func   __ww_textproc_parse_html_color__
/// @desc   Parses a hex color using real().
///         Supports: #rgb, #rrggbb, 0xrrggbb, $rrggbb, rrggbb
///         Returns _fallback_color if invalid.
/// @param  {String} _text
/// @param  {Real}   _fallback_color
/// @returns {Real}
#endregion
function __ww_textproc_parse_html_color__(_text, _fallback_color) {

    if (is_undefined(_text)) { return _fallback_color; }

    var _value = string_trim(_text);
    if (_value == "") { return _fallback_color; }

    // Strip quotes
    var _len = string_length(_value);
    if (_len >= 2) {
        var _char_a = string_char_at(_value, 1);
        var _char_b = string_char_at(_value, _len);
        if ((_char_a == "\"" && _char_b == "\"") || (_char_a == "'" && _char_b == "'")) {
            _value = string_trim(string_copy(_value, 2, _len - 2));
            if (_value == "") { return _fallback_color; }
            _len = string_length(_value);
        }
    }

    // Normalize prefixes
    var _hex = "";

    if (string_char_at(_value, 1) == "#") {
        _hex = string_copy(_value, 2, _len - 1);

        // #rgb -> rrggbb
        if (string_length(_hex) == 3) {
            _hex =
                string_char_at(_hex, 1) + string_char_at(_hex, 1) +
                string_char_at(_hex, 2) + string_char_at(_hex, 2) +
                string_char_at(_hex, 3) + string_char_at(_hex, 3);
        }
    }
    else if (string_char_at(_value, 1) == "$") {
        _hex = string_copy(_value, 2, _len - 1);
    }
    else if (_len >= 2 && string_char_at(_value, 1) == "0" && (string_char_at(_value, 2) == "x" || string_char_at(_value, 2) == "X")) {
        _hex = string_copy(_value, 3, _len - 2);
    }
    else {
        _hex = _value;
    }

    if (string_length(_hex) != 6) { return _fallback_color; }

    // Validate hex chars only
    var _indx = 1;
    repeat (6) {
        var _code = ord(string_char_at(_hex, _indx));
        if (
            !((_code >= 48 && _code <= 57) ||    // 0-9
              (_code >= 65 && _code <= 70) ||    // A-F
              (_code >= 97 && _code <= 102))     // a-f
        ) {
            return _fallback_color;
        }
        _indx += 1;
    }

    // Parse as RRGGBB, then rebuild as a GM color via explicit channels
    var _rgbv = real("0x" + _hex);

    var _redc  = (_rgbv >> 16) & 255;
    var _grec  = (_rgbv >> 8) & 255;
    var _blue  = _rgbv & 255;

    return make_color_rgb(_redc, _grec, _blue);
}
