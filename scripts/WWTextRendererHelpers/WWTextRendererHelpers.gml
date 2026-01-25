#region jsDoc
/// @func    WWTextRendererHelpers()
/// @desc    Shared helpers for WW text processors. Provides:
///          - state clone + patch apply
///          - context for building output text + spans without closures
#endregion

#region State

// Patch bitmask (compiled lazily into patch structs)
#macro __WW_TP_PATCH_COLOR      (1 << 0)
#macro __WW_TP_PATCH_ALPHA      (1 << 1)
#macro __WW_TP_PATCH_FONT       (1 << 2)
#macro __WW_TP_PATCH_STYLE      (1 << 3)
#macro __WW_TP_PATCH_SIZE_MUL   (1 << 4)
#macro __WW_TP_PATCH_UNDERLINE  (1 << 5)
#macro __WW_TP_PATCH_STRIKE     (1 << 6)
#macro __WW_TP_PATCH_BACK_COLOR (1 << 7)
#macro __WW_TP_PATCH_BACK_ALPHA (1 << 8)
#macro __WW_TP_PATCH_ALIGN      (1 << 9)

/// @func    __ww_textproc_patch_compile__()
/// @desc    Adds a cached bitmask onto a patch struct, so hot loops can avoid variable_struct_exists.
///          The mask is stored under key "__ww_tp_mask".
/// @param   {Struct} _patch
/// @returns {Struct} patch
function __ww_textproc_patch_compile__(_patch) {
	if (is_undefined(_patch)) { return _patch; }
	if (variable_struct_exists(_patch, "__ww_tp_mask")) { return _patch; }
	
	var _m = 0;
	if (variable_struct_exists(_patch, "color"))      { _m |= __WW_TP_PATCH_COLOR; }
	if (variable_struct_exists(_patch, "alpha"))      { _m |= __WW_TP_PATCH_ALPHA; }
	if (variable_struct_exists(_patch, "font_asset")) { _m |= __WW_TP_PATCH_FONT; }
	if (variable_struct_exists(_patch, "style"))      { _m |= __WW_TP_PATCH_STYLE; }
	if (variable_struct_exists(_patch, "size_mul"))   { _m |= __WW_TP_PATCH_SIZE_MUL; }
	if (variable_struct_exists(_patch, "underline"))  { _m |= __WW_TP_PATCH_UNDERLINE; }
	if (variable_struct_exists(_patch, "strike"))     { _m |= __WW_TP_PATCH_STRIKE; }
	if (variable_struct_exists(_patch, "back_color")) { _m |= __WW_TP_PATCH_BACK_COLOR; }
	if (variable_struct_exists(_patch, "back_alpha")) { _m |= __WW_TP_PATCH_BACK_ALPHA; }
	if (variable_struct_exists(_patch, "align_value")) { _m |= __WW_TP_PATCH_ALIGN; }

	_patch.__ww_tp_mask = _m;
	return _patch;
}

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
	_patch = __ww_textproc_patch_compile__(_patch);
	var _m = _patch.__ww_tp_mask;
	if (_m == 0) { return; }

	if (_m & __WW_TP_PATCH_COLOR)      { _state.color      = _patch.color; }
	if (_m & __WW_TP_PATCH_ALPHA)      { _state.alpha      = _patch.alpha; }
	if (_m & __WW_TP_PATCH_FONT)       { _state.font_asset = _patch.font_asset; }
	if (_m & __WW_TP_PATCH_STYLE)      { _state.style      = _patch.style; }
	if (_m & __WW_TP_PATCH_SIZE_MUL)   { _state.size_mul   = _patch.size_mul; }
	if (_m & __WW_TP_PATCH_UNDERLINE)  { _state.underline  = _patch.underline; }
	if (_m & __WW_TP_PATCH_STRIKE)     { _state.strike     = _patch.strike; }
	if (_m & __WW_TP_PATCH_BACK_COLOR) { _state.back_color = _patch.back_color; }
	if (_m & __WW_TP_PATCH_BACK_ALPHA) { _state.back_alpha = _patch.back_alpha; }
	if (_m & __WW_TP_PATCH_ALIGN)      { _state.align_value = _patch.align_value; }
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
		align_runs: [],
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
	_patch = __ww_textproc_patch_compile__(_patch);
	var _m = _patch.__ww_tp_mask;
	if (_m == 0) { return; }

	var _state = _ctx.state;
	var _needs_flush = false;

	if (_m & __WW_TP_PATCH_COLOR)      { if (_state.color      != _patch.color)      { _needs_flush = true; } }
	if (_m & __WW_TP_PATCH_ALPHA)      { if (_state.alpha      != _patch.alpha)      { _needs_flush = true; } }
	if (_m & __WW_TP_PATCH_FONT)       { if (_state.font_asset != _patch.font_asset) { _needs_flush = true; } }
	if (_m & __WW_TP_PATCH_STYLE)      { if (_state.style      != _patch.style)      { _needs_flush = true; } }
	if (_m & __WW_TP_PATCH_SIZE_MUL)   { if (_state.size_mul   != _patch.size_mul)   { _needs_flush = true; } }
	if (_m & __WW_TP_PATCH_UNDERLINE)  { if (_state.underline  != _patch.underline)  { _needs_flush = true; } }
	if (_m & __WW_TP_PATCH_STRIKE)     { if (_state.strike     != _patch.strike)     { _needs_flush = true; } }
	if (_m & __WW_TP_PATCH_BACK_COLOR) { if (_state.back_color != _patch.back_color) { _needs_flush = true; } }
	if (_m & __WW_TP_PATCH_BACK_ALPHA) { if (_state.back_alpha != _patch.back_alpha) { _needs_flush = true; } }
	if (_m & __WW_TP_PATCH_ALIGN)      { if (_state.align_value != _patch.align_value) { _needs_flush = true; } }

	if (_needs_flush) {
		__ww_textproc_ctx_flush_span__(_ctx, _ctx.out_len);
	}

	// Apply patch values (no extra variable_struct_exists checks).
	if (_m & __WW_TP_PATCH_COLOR)      { _state.color      = _patch.color; }
	if (_m & __WW_TP_PATCH_ALPHA)      { _state.alpha      = _patch.alpha; }
	if (_m & __WW_TP_PATCH_FONT)       { _state.font_asset = _patch.font_asset; }
	if (_m & __WW_TP_PATCH_STYLE)      { _state.style      = _patch.style; }
	if (_m & __WW_TP_PATCH_SIZE_MUL)   { _state.size_mul   = _patch.size_mul; }
	if (_m & __WW_TP_PATCH_UNDERLINE)  { _state.underline  = _patch.underline; }
	if (_m & __WW_TP_PATCH_STRIKE)     { _state.strike     = _patch.strike; }
	if (_m & __WW_TP_PATCH_BACK_COLOR) { _state.back_color = _patch.back_color; }
	if (_m & __WW_TP_PATCH_BACK_ALPHA) { _state.back_alpha = _patch.back_alpha; }
	if (_m & __WW_TP_PATCH_ALIGN)      { _state.align_value = _patch.align_value; }
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
